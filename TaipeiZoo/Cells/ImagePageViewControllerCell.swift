//
//  ImagePageViewControllerCell.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class ImagePageViewControllerCell: UICollectionViewCell {
    
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var chNameLabel: UILabel!
    @IBOutlet weak var enNameLabel: UILabel!
    @IBOutlet weak var laNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var detailPhotoPageVC: DetailPhotoPageViewController! = nil
    
    // MARK: - First initialize
    
    override func awakeFromNib() {
        
        detailPhotoPageVC = DetailPhotoPageViewController(transitionStyle: .scroll,
                                                              navigationOrientation: .horizontal,
                                                              options: nil)
        
        detailPhotoPageVC.view.translatesAutoresizingMaskIntoConstraints = false

        containerV.addSubview(detailPhotoPageVC.view)
        
        let hCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[imgPVC]-(0)-|",
                                                   options: [],
                                                   metrics: nil,
                                                   views: ["imgPVC":detailPhotoPageVC.view as Any])
        
        let vCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[imgPVC]-(0)-|",
                                                   options: [],
                                                   metrics: nil,
                                                   views: ["imgPVC":detailPhotoPageVC.view as Any])
        contentView.addConstraints(hCons)
        contentView.addConstraints(vCons)
    }
    
    // MARK: - Setup Function
    
    func configCell(species:Species,
                    parentView: UIViewController) {
        
        chNameLabel.text   = species.chName
        enNameLabel.text   = species.enName
        laNameLabel.text   = species.laName
        locationLabel.text = species.location

        setupContainerView(parentV: parentView,
                           imgTasks: species.imgTasks)
    }
    
    private func setupContainerView(parentV: UIViewController,
                                    imgTasks: [ImageDownloadTask]?) {
        
        detailPhotoPageVC.imgTasks = imgTasks
        
        // set ContainerView by code
        parentV.addChild(detailPhotoPageVC)
        detailPhotoPageVC.didMove(toParent: parentV)
    }
}
