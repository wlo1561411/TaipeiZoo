//
//  TaxonomyCollectionViewCell.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class TaxonomyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var taxonomyLabels: [UILabel]!

    // MARK: - First initialize

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Setup Function
    
    func configCell(taxonomy:[String?]) {
        
        for i in 0 ..< taxonomyLabels.count {
            if i > taxonomy.count - 1 {  // If taxonmy's count is less than labels count, than break
                taxonomyLabels[i].text = ""
                break
            }
            taxonomyLabels[i].text = taxonomy[i]
        }
    }
}
