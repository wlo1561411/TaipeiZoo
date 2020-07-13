//
//  Plant.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import Foundation

class Plant: Species {
    
    var commonName: String?
    var brief:      String?
    var function:   String?
    var family:     String?  // 科
    var genus:      String?  // 屬
    
    // MARK: - Initialize
    
    init(dic:[String:Any],
         indexRow:Int) {
        
        super.init()
        
        chName     = dic["F_Name_Ch"] as? String
        enName     = dic["F_Name_En"] as? String
        laName     = dic["F_Name_Latin"] as? String
        location   = dic["F_Location"] as? String
        
        commonName = dic["F_AlsoKnown"] as? String
        feature    = dic["F_Feature"] as? String
        brief      = dic["F_Brief"] as? String
        function   = dic["F_Function＆Application"] as? String
        
        brief      = setDescription(title: "簡介：\n", content: dic["F_Brief"])
        commonName = setDescription(title: "別名：\n", content: dic["F_AlsoKnown"])
        feature    = setDescription(title: "特徵：\n", content: dic["F_Feature"])
        function   = setDescription(title: "功能：\n", content: dic["F_Function＆Application"])

        family     = dic["F_Family"] as? String
        genus      = dic["F_Genus"] as? String
        
        url01      = dic["F_Pic01_URL"] as? String
        url02      = dic["F_Pic02_URL"] as? String
        url03      = dic["F_Pic03_URL"] as? String
        url04      = dic["F_Pic04_URL"] as? String
        number     = indexRow + 1
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: CodingKey {
        case commonName
        case brief
        case family, genus
        case function
    }
    
    override func encode(to encoder: Encoder) throws {
        
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(commonName, forKey: .commonName)
        try container.encodeIfPresent(brief,      forKey: .brief)
        try container.encodeIfPresent(family,     forKey: .family)
        try container.encodeIfPresent(genus,      forKey: .genus)
        try container.encodeIfPresent(function,   forKey: .function)
    }
    
    required init(from decoder: Decoder) throws {

        try super.init(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        family     = try container.decodeIfPresent(String.self, forKey: .family)
        genus      = try container.decodeIfPresent(String.self, forKey: .genus)
        commonName = try container.decodeIfPresent(String.self, forKey: .commonName)
        brief      = try container.decodeIfPresent(String.self, forKey: .brief)
        function   = try container.decodeIfPresent(String.self, forKey: .function)
    }
}
