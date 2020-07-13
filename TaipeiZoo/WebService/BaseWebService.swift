//
//  WebService.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/25.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

enum DownloadState {
    case noneStart
    case downloading
    case finish
    case noResult
    case error
}

class BaseWebService {
    
    lazy var session = { return URLSession(configuration: .default) }()
    
    // API Paramters
    private lazy var baseURL   = "https://data.taipei/opendata/datalist/apiAccess"
    private lazy var scope     = "resourceAquire"
    private lazy var animalRid = "a3e2b221-75e0-45c1-8f97-75acbd43d613"
    private lazy var plantRid  = "f18de02f-b6c9-47c0-8cda-50efad621c14"
    
    // Species maximum's key for UserDefault
    let ANIMAL_MAXIMUM = "animal"
    let PLANT_MAXIMUM  = "plant"
    
    typealias animalsCallBack = (Bool, [Animal]?) -> ()
    typealias plantsCallBack  = (Bool, [Plant]?)  -> ()
    typealias imgCallBack     = (Bool, UIImage?) -> ()

    var state: DownloadState = .noneStart
    
    // MARK: - Process Function
        
    fileprivate func encodeUrl(baseURL: String,
                               params: [String:Any]) -> URL? {

        guard let url = URL(string: baseURL) else {
            print("URL is nil")
            return nil
        }

        if !params.isEmpty {
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                
                components.queryItems = [URLQueryItem]()
                for (key,value) in params {
                    let query = URLQueryItem(name: key, value: "\(value)")
                    components.queryItems?.append(query)
                }

                guard let okUrl = components.url else {
                    print("Can't Configure Params")
                    return nil
                }
                
                return okUrl
            }
            
            print("Can't Configure Component")
            return nil
            
        } else {
            print("Params were nil")
            return nil
        }
    }
    
    fileprivate func parseJson(isAnimal: Bool,
                               json: Any) -> [[String:Any]]? {  // Manual decoder
        
            if let jsonDic   = json as? [String:[String:Any]],
               let resultDic = jsonDic["result"],
               let maximum   = resultDic["count"] as? Int,
               let loadedArr = resultDic["results"] as? [[String:Any]] {
                
                let maxId = isAnimal ? ANIMAL_MAXIMUM : PLANT_MAXIMUM
                UserDefaults.standard.set(maximum, forKey: maxId)  // Save maximum to UserDefault
                
                return loadedArr
            }
        
        return nil
    }
    
    // MARK: - Download Function
    
    func fetchAnimals(limit: Int,
                      offset: Int,
                      startPoint: Int,
                      callBack: @escaping animalsCallBack) {

        let params: [String:Any] = ["scope":  scope,
                                    "rid":    animalRid,
                                    "limit":  limit,
                                    "offset": offset]

        guard let encodedURL = encodeUrl(baseURL: baseURL, params: params) else {
            print("Encode URL error")
            state = .error
            callBack(false,nil)
            return
        }

        var req = URLRequest(url: encodedURL)
        req.httpMethod = "GET"

        state = .downloading

        let task = session.downloadTask(with: req) { (url, response, error) in

            if error != nil {
                print("Fetch data error : \(error!.localizedDescription))")
                self.state = .error
                callBack(false, nil)
            }

            if let okUrl = url {

                do {
                    let data = try Data(contentsOf: okUrl)
                    let json = try JSONSerialization.jsonObject(with: data,
                                                                options: .fragmentsAllowed)
                    if let okArr = self.parseJson(isAnimal: true,
                                                  json: json) {
                        var animals = [Animal]()
                        
                        for i in 0 ..< okArr.count {
                            animals.append(Animal(dic: okArr[i],
                                                  indexRow: i + startPoint))
                        }
                        
                        self.state = animals.count > 0 ? .finish : .noResult
                        callBack(true, animals)
                        
                    } else {
                        callBack(false, nil)
                    }
                } catch  {
                    print("Configure data error : \(error.localizedDescription)")
                    self.state = .error
                    callBack(false, nil)
                }
            } else {
                print("Download Task URL error")
                self.state = .error
                callBack(false, nil)
            }
        }

        task.resume()
    }
    
    func fetchPlants(limit: Int,
                     offset: Int,
                     startPoint: Int,
                     callBack: @escaping plantsCallBack) {

        let params: [String:Any] = ["scope":  scope,
                                    "rid":    plantRid,
                                    "limit":  limit,
                                    "offset": offset]

        guard let encodedURL = encodeUrl(baseURL: baseURL, params: params) else {
            print("Encode URL error")
            state = .error
            callBack(false,nil)
            return
        }

        var req = URLRequest(url: encodedURL)
        req.httpMethod = "GET"

        state = .downloading

        let task = session.downloadTask(with: req) { (url, response, error) in

            if error != nil {
                print("Fetch data error : \(error!.localizedDescription))")
                self.state = .error
                callBack(false,nil)
            }

            if let okUrl = url {
                
               do {
                    let data = try Data(contentsOf: okUrl)
                    let json = try JSONSerialization.jsonObject(with: data,
                                                                options: .fragmentsAllowed)
                    if let okArr = self.parseJson(isAnimal: false,
                                                  json: json) {
                        var plants = [Plant]()
                        
                        for i in 0 ..< okArr.count {
                            plants.append(Plant(dic: okArr[i],
                                                indexRow: i + startPoint))
                        }
                        
                        self.state = plants.count > 0 ? .finish : .noResult
                        callBack(true, plants)
                        
                    } else {
                        callBack(false, nil)
                    }
                } catch  {
                    print("Configure data error : \(error.localizedDescription)")
                    self.state = .error
                    callBack(false, nil)
                }
            } else {
                print("Download Task URL error")
                self.state = .error
                callBack(false,nil)
            }
        }

        task.resume()
    }
    
    
    
    func downloadImg(imgUrl: URL?,
                     callBack: @escaping imgCallBack) {
        
        guard let okUrl = imgUrl else {
            print("Get URL error")
            state = .error
            callBack(false,nil)
            return
        }
        
        state = .downloading
        
        let task = session.downloadTask(with: okUrl) { (url, response, err) in
            
            if err != nil {
                print("Download Image Fail, error : \(err!.localizedDescription)")
                self.state = .error
                callBack(false,nil)
            }
            
            if let okUrl = url {
                
                do {
                    let loadedImg = UIImage(data: try Data(contentsOf: okUrl))
                    self.state = loadedImg != nil ? .finish : .noResult
                    callBack(true,loadedImg)
                } catch  {
                    print("Convert Image Fail, error : \(error.localizedDescription)")
                    self.state = .error
                    callBack(false,nil)
                }
            } else {
                print("Download Task URL error")
                self.state = .error
                callBack(false,nil)
            }
        }
        
        task.resume()
    }
}
