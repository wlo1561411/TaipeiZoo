//
//  DescriptionCollectionViewCell.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/28.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class DescriptionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var descriptionLabels: [UILabel]!
    
    // MARK: - First initialize

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Setup Function
    
    func configCell(descriptions:[String?]) {
        
        for i in 0 ..< descriptionLabels.count {
            if i > descriptions.count - 1 {  // If descriptions's count is less than labels count, than break
                descriptionLabels[i].text = ""
                break
            }
            descriptionLabels[i].text = descriptions[i]
        }
    }
}
