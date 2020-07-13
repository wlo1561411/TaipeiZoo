//
//  FrameViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/5.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 DetailPhotoPageViewController's page
 */
class FrameViewController: UIViewController {
    
    var imgAi: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .white)
        ai.color = .black
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        return ai
    }()
    
    var imgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    /*
     This variable will be set by DetailPhotoPageViewController's imgTasks didSet,
     when it didSet, setup delegate and readyToDownloadImg.
     */
    var imgTask: ImageDownloadTask? {
        didSet {
            imgTask?.delegate = self
            imgTask?.readyToDownloadImg()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
                
        // Setup UI
        view.addSubview(imgView)
        imgView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imgView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imgView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imgView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        view.addSubview(imgAi)
        imgAi.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imgAi.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        imgView.configForImageDownloadTask(activityIndicator: imgAi,
                                           imgTask: imgTask)
    }
}


// MARK: - Image Download Delegate

extension FrameViewController: ImageDownloadDelegate {
    
    // While image download finish, set imgView's image.
    func updateLoadedImg(indexRow: Int) {
        DispatchQueue.main.async {
            self.imgView.configForImageDownloadTask(activityIndicator: self.imgAi,
                                                    imgTask: self.imgTask)
        }
    }
}
