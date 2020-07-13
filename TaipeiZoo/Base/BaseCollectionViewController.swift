//
//  BaseCollectionViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/4.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 It write reuseful code for WebService,
 Image Download Delegate,
 Favorite button action,
 and common variable
 */
class BaseCollectionViewController: UIViewController {
    
    // Collection view cell register id
    let pageCellId        = "pageViewCell"
    let taxonomyCellId    = "taxonomyCell"
    let descriptionCellId = "descriptionCell"
    let speciesCellId     = "speciesCell"
    let footerViewId      = "footerView"
    
    // Species cell basic content height(chName, enName...)
    let speciesCellBasicH: CGFloat = 110
    
    // The data count of every fetch
    let normalLimit = 50
    let detailLimit = 10
    
    lazy var footerAi:        UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        ai.color = .black
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        return ai
    }()
    lazy var fullTextLb:      UILabel = {
        let lb = UILabel()
        lb.text = "找不到其他相關的物種。"
        lb.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    lazy var coreDataHandler: CoreDataHandler? = {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return CoreDataHandler(context: appDelegate.persistentContainer.viewContext)
        }
        return nil
    }()
    
    lazy var webService: BaseWebService = {
        return BaseWebService()
    }()
    lazy var animals:    [Animal] = {
        return [Animal]()
    }()
    lazy var plants:     [Plant] = {
        return [Plant]()
    }()
    
    var isAnimal = true   // Species flag
    var isFull   = false  // Data maximum flag
    var offset   = 0
    var maximum  = 0
    var limit    = 0
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    // MARK: - Favorite Action
    
    func postFavoriteNotification(species: Species?) {
        
        guard let okHandler = coreDataHandler,
              let okSpecies = species else { return }
        
        let isContain = okHandler.isContain(chName: okSpecies.chName)  // Check the species had contained CoreData or not
        
        if isContain {
            
            if okHandler.deleteFavorite(chName: okSpecies.chName) {  // Delete species
                
                NotificationCenter.default.post(name: Notification.Name.init("reloadForFavoriteAction"),
                                                object: ["isInsert": false,
                                                         "selectedSpecies": okSpecies])
                
                print("\(okSpecies.chName ?? "Error") delete favorite success")
            }
        } else {
            
            var speciesData: Data?
            var isAnimal = false
            let imgData = okSpecies.imgTasks.first?.loadedImg?.pngData()  //Get species image data
            
            // Encode species to data frist
            if let animal = okSpecies as? Animal,
                let data   = try? PropertyListEncoder().encode(animal) {
                
                speciesData = data
                isAnimal    = true
                
            } else if let plant = okSpecies as? Plant,
                let data  = try? PropertyListEncoder().encode(plant) {
                
                speciesData = data
                isAnimal    = false
            }
                        
            if okHandler.insertFavorite(chName: okSpecies.chName,
                                        imgData: imgData,
                                        speciesData: speciesData,
                                        isAnimal: isAnimal) {  // Insert species

                NotificationCenter.default.post(name: Notification.Name.init("reloadForFavoriteAction"),
                                                object: ["isInsert": true,
                                                         "selectedSpecies": okSpecies])

                print("\(okSpecies.chName ?? "Error") add favorite success")
            }
        }
    }
}

// MARK: - Web Service

extension BaseCollectionViewController {
    
    func firstFetch(callBack: @escaping (Bool) ->()) {  // Process the frist fetch species data
        
        if isAnimal {
            
            webService.fetchAnimals(limit: limit,
                                    offset: offset,
                                    startPoint: animals.count) { (isSuc, loadedAnimals) in
                if isSuc {
                    if let okAnimals = loadedAnimals,
                       let okMaximum = UserDefaults.standard.value(forKey: self.webService.ANIMAL_MAXIMUM) as? Int {
                        
                        self.maximum = okMaximum
                        self.animals = okAnimals
                        self.countOffset(dataCount: okAnimals.count)
                        callBack(true)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name.reachabilityChanged,
                                                    object: false)
                }
            }
        } else {
            
            webService.fetchPlants(limit: limit,
                                   offset: offset,
                                   startPoint: plants.count) { (isSuc, loadedPlants) in
                if isSuc {
                    if let okPlants  = loadedPlants,
                       let okMaximum = UserDefaults.standard.value(forKey: self.webService.PLANT_MAXIMUM) as? Int  {
                        
                        self.maximum = okMaximum
                        self.plants  = okPlants
                        self.countOffset(dataCount: okPlants.count)
                        callBack(true)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name.reachabilityChanged,
                                                    object: false)
                }
            }
        }
    }

    func fetchMore(collectionView: UICollectionView,
                   startPoint: Int,
                   isSearch: Bool,
                   section: Int) {  // Process the species fetching
        
        // Check state is available to fetch or data is full or not.
        if webService.state == .downloading ||
           webService.state == .noResult ||
           isFull { return }
        
        /*
         Loading data step :
         1. Update offset
         2. Append loaded data to data array
         3. Update collectionView
         */
        if isAnimal {
            
            webService.fetchAnimals(limit: limit,
                                    offset: offset,
                                    startPoint: startPoint) { (isSuc, loadedAnimals) in
                if isSuc {
                    if let okAnimals = loadedAnimals {
                        let from = self.animals.count
                        self.countOffset(dataCount: okAnimals.count)
                        self.animals.append(contentsOf: okAnimals)
                        self.updateCollectionView(collectionView: collectionView,
                                                  isSearch: isSearch,
                                                  from: from,
                                                  section: section,
                                                  loadedCount: self.animals.count)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name.reachabilityChanged,
                                                    object: false)
                }
            }
        } else {
            
            webService.fetchPlants(limit: limit,
                                   offset: offset,
                                   startPoint: startPoint) { (isSuc, loadedPlants) in
                if isSuc {
                    if let okPlants = loadedPlants {
                        let from = self.plants.count
                        self.countOffset(dataCount: okPlants.count)
                        self.plants.append(contentsOf: okPlants)
                        self.updateCollectionView(collectionView: collectionView,
                                                  isSearch: isSearch,
                                                  from: from,
                                                  section: section,
                                                  loadedCount: self.plants.count)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name.reachabilityChanged,
                                                                   object: false)
                }
            }
        }
    }
    
    func countOffset(dataCount: Int) {  // count offset
        
        if offset + dataCount == maximum {
            isFull = true
            offset = maximum
        } else {
            offset += dataCount
        }
    }
    
    func updateCollectionView(collectionView: UICollectionView,
                              isSearch: Bool,
                              from: Int,
                              section: Int,
                              loadedCount: Int) {  // Update collection view
        
        if isSearch { return }
        
        DispatchQueue.main.async {
            
            var insertArr = [IndexPath]()
            for row in from ..< loadedCount {
                insertArr.append(IndexPath(item: row, section: section))
            }
            
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: insertArr)
            }, completion: nil)
        }
    }
}

// MARK: - Image Download Delegate

extension BaseCollectionViewController {
    
    // Process ImageDownloadDelegate's callback fucntion for reload cell
    func readyToReloadCell(collectionView:UICollectionView,
                           indexPaths:[IndexPath]) {
        
        DispatchQueue.main.async {
            
            let isvisable = collectionView.indexPathsForVisibleItems.filter({$0 == indexPaths.first}).count == 1 ? true : false
            
            if !isvisable { return }
            
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates({
                    collectionView.reloadItems(at: indexPaths)
                }, completion: nil)
            }
        }
    }
}

// MARK: - UI ImageView

extension UIImageView {
    
    func configForImageDownloadTask(activityIndicator: UIActivityIndicatorView,
                                    imgTask: ImageDownloadTask?) {
        
        image = nil
        
        if let okImgTask = imgTask {
            
            if !NetworkHandler.shareInstance.isConnect() {  // If network is unavailable, set image for default
                
                activityIndicator.stopAnimating()
                image = okImgTask.loadedImg != nil ? okImgTask.loadedImg : UIImage(named: "pathetic")
            } else {
                
                switch okImgTask.state {
                    
                case .noneStart, .downloading:
                    activityIndicator.startAnimating()
                    break
                    
                case .finish:
                    activityIndicator.stopAnimating()
                    image = okImgTask.loadedImg
                    break
                    
                case .error, .noResult:
                    activityIndicator.stopAnimating()
                    image = UIImage(named: "pathetic")
                    break
                }
            }
        } else {
            activityIndicator.stopAnimating()
            image = UIImage(named: "pathetic")
        }
    }
}
