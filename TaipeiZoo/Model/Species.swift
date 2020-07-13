//
//  Species.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import Foundation

class Species: Codable {
    
    var number:     Int?
    var chName:     String?
    var enName:     String?
    var laName:     String?
    var feature:    String?
    var location:   String?
    var url01:      String?
    var url02:      String?
    var url03:      String?
    var url04:      String?
    var imgTasks =  [ImageDownloadTask]()
    
    // MARK: - Initialize
    
    init() { }

    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case number
        case chName, enName, laName
        case feature
        case location
        case url01, url02, url03, url04
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(number,   forKey: .number)
        try container.encodeIfPresent(chName,   forKey: .chName)
        try container.encodeIfPresent(enName,   forKey: .enName)
        try container.encodeIfPresent(laName,   forKey: .laName)
        try container.encodeIfPresent(feature,  forKey: .feature)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(url01,    forKey: .url01)
        try container.encodeIfPresent(url02,    forKey: .url02)
        try container.encodeIfPresent(url03,    forKey: .url03)
        try container.encodeIfPresent(url04,    forKey: .url04)
    }
    
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        number   = try container.decodeIfPresent(Int.self,      forKey: .number)
        chName   = try container.decodeIfPresent(String.self,   forKey: .chName)
        enName   = try container.decodeIfPresent(String.self,   forKey: .enName)
        laName   = try container.decodeIfPresent(String.self,   forKey: .laName)
        feature  = try container.decodeIfPresent(String.self,   forKey: .feature)
        location = try container.decodeIfPresent(String.self,   forKey: .location)
        url01    = try container.decodeIfPresent(String.self,   forKey: .url01)
        url02    = try container.decodeIfPresent(String.self,   forKey: .url02)
        url03    = try container.decodeIfPresent(String.self,   forKey: .url03)
        url04    = try container.decodeIfPresent(String.self,   forKey: .url04)
    }
    
    // MARK: - Setup Function
    
    func setDescription(title: String,
                        content: Any?) -> String? {  // Set description title depend on itself contain value or not
        
        if let okContent = content as? String , okContent != "" {
            return title.appending(okContent)
        }
        return nil
    }
    
    func setupImgTasks(imgDelegate: ImageDownloadDelegate?) {
        
        if imgTasks.count > 0 { return }  // Prevent cell overloadeing, because "imgTasks" only needs to be set once.
        
        let urlStrings = [url01, url02, url03, url04]
        
        for str in urlStrings {
            
            guard let okNum = number,
                  let okStr = str else { return }
            
            let delSpace = okStr.replacingOccurrences(of: " ", with: "")  // Deal with url error from database
            
            if delSpace != "" && !delSpace.isEmpty {
                if let okUrl = URL(string: delSpace) {
                    imgTasks.append(ImageDownloadTask(url: okUrl,
                                                      indexRow: okNum - 1,
                                                      imgDelegate: imgDelegate))
                } else {
                    imgTasks.append(ImageDownloadTask(indexRow: okNum - 1))
                }
            } else {
                if imgTasks.isEmpty {  // If species don't have any image url, add one imageTask at least.
                    imgTasks.append(ImageDownloadTask(indexRow: okNum - 1))
                }
                break
            }
        }
    }
}
