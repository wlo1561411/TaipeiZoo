//
//  SpeciesCollectionViewCell.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class SpeciesCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var speciesImgView: UIImageView!
    @IBOutlet weak var chNameLb: VerticalAlignLabel!
    @IBOutlet weak var enNameLb: VerticalAlignLabel!
    @IBOutlet weak var locationLb: VerticalAlignLabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    lazy var cellAi: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        ai.color = .black
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        return ai
    }()
    
    var favoriteAction: (()->())?
    
    // MARK: - First initialize
    
    override func awakeFromNib() {
        
        chNameLb.verticalAlignment   = .middle
        enNameLb.verticalAlignment   = .top
        locationLb.verticalAlignment = .middle
        
        layer.masksToBounds = true
        layer.cornerRadius  = 10
        
        speciesImgView.addSubview(cellAi)
        cellAi.centerXAnchor.constraint(equalTo: speciesImgView.centerXAnchor).isActive = true
        cellAi.centerYAnchor.constraint(equalTo: speciesImgView.centerYAnchor).isActive = true
    }
    
    // MARK: - Button Action
    
    @IBAction func favoriteBtnAction(_ sender: UIButton) {
        favoriteAction?()
    }
    
    // MARK: - Setup Function
        
    func configCell(coreDataHandler: CoreDataHandler?,
                    species: Species?,
                    favoriteAction: @escaping () -> ()) {
        
        guard let okHandler = coreDataHandler,
              let okSpecies = species else { return }
        
        chNameLb.text   = okSpecies.chName
        enNameLb.text   = okSpecies.enName
        locationLb.text = okSpecies.location
        speciesImgView.contentMode = .scaleAspectFill
        
        speciesImgView.configForImageDownloadTask(activityIndicator: cellAi,
                                                  imgTask: okSpecies.imgTasks.first)
        
        let img = !okHandler.isContain(chName: okSpecies.chName) ? UIImage(named: "heart-empty") : UIImage(named: "heart-fill")
        
        favoriteBtn.setImage(img, for: .normal)
        
        self.favoriteAction = favoriteAction
    }
}
