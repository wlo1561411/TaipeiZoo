//
//  Animal.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import Foundation

class Animal: Species {
    
    var family:         String? // 科
    var order:          String? // 目
    var phylum:         String? // 門
    var aClass:         String? // 綱
    var interpretation: String?
    var distribution:   String?
    var habitat:        String?
    var behavior:       String?
    var diet:           String?
    
    // MARK: - Initialize
    
    init(dic: [String:Any],
         indexRow: Int) {
        
        super.init()
        
        chName         = dic["A_Name_Ch"] as? String
        enName         = dic["A_Name_En"] as? String
        laName         = dic["A_Name_Latin"] as? String
        location       = dic["A_Location"] as? String
        
        interpretation = setDescription(title: "介紹：\n",   content: dic["A_Interpretation"])
        distribution   = setDescription(title: "分佈：\n",   content: dic["A_Distribution"])
        habitat        = setDescription(title: "棲息地：\n", content: dic["A_Habitat"])
        behavior       = setDescription(title: "行為：\n",   content: dic["A_Behavior"])
        diet           = setDescription(title: "飲食：\n",   content: dic["A_Diet"] )
        feature        = setDescription(title: "特徵：\n",   content: dic["A_Feature"])
    
        family         = dic["A_Family"] as? String
        order          = dic["A_Order"] as? String
        phylum         = dic["A_Phylum"] as? String
        aClass         = dic["A_Class"] as? String
    
        url01          = dic["A_Pic01_URL"] as? String
        url02          = dic["A_Pic02_URL"] as? String
        url03          = dic["A_Pic03_URL"] as? String
        url04          = dic["A_Pic04_URL"] as? String
        number         = indexRow + 1
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: CodingKey {
        case habitat
        case diet
        case family, order, phylum, aClass
        case interpretation
        case behavior
        case distribution
    }
    
    override func encode(to encoder: Encoder) throws {
        
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(habitat,        forKey: .habitat)
        try container.encodeIfPresent(diet,           forKey: .diet)
        try container.encodeIfPresent(family,         forKey: .family)
        try container.encodeIfPresent(order,          forKey: .order)
        try container.encodeIfPresent(phylum,         forKey: .phylum)
        try container.encodeIfPresent(aClass,         forKey: .aClass)
        try container.encodeIfPresent(interpretation, forKey: .interpretation)
        try container.encodeIfPresent(behavior,       forKey: .behavior)
        try container.encodeIfPresent(distribution,   forKey: .distribution)
    }
    
    required init(from decoder: Decoder) throws {

        try super.init(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        habitat        = try container.decodeIfPresent(String.self, forKey: .habitat)
        diet           = try container.decodeIfPresent(String.self, forKey: .diet)
        family         = try container.decodeIfPresent(String.self, forKey: .family)
        order          = try container.decodeIfPresent(String.self, forKey: .order)
        phylum         = try container.decodeIfPresent(String.self, forKey: .phylum)
        aClass         = try container.decodeIfPresent(String.self, forKey: .aClass)
        interpretation = try container.decodeIfPresent(String.self, forKey: .interpretation)
        behavior       = try container.decodeIfPresent(String.self, forKey: .behavior)
        distribution   = try container.decodeIfPresent(String.self, forKey: .distribution)
    }
}

