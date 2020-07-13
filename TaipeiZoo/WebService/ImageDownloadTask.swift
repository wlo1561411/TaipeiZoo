//
//  ImageDownloadTask.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/26.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

protocol ImageDownloadDelegate: AnyObject {
    func updateLoadedImg(indexRow: Int)
}

class ImageDownloadTask: BaseWebService {
    
    var url: URL?
    var indexRow: Int?
    var loadedImg: UIImage?
    
    weak var delegate: ImageDownloadDelegate?

    // MARK: - Initialize
    
    init(indexRow: Int) {  // If species haven't image url, return empty imgTask
        
        super.init()
        self.url      = nil
        self.delegate = nil
        self.indexRow = indexRow
        self.state    = .noResult
    }
    
    init(url: URL,
         indexRow: Int,
         imgDelegate: ImageDownloadDelegate?) {
        
        super.init()
        self.url      = url
        self.indexRow = indexRow
        self.delegate = imgDelegate
    }
    
     // MARK: - Process Function
    
    func readyToDownloadImg() {  // Process image download action
        
        if state     == .finish ||
           state     == .downloading ||
           state     == .noResult ||
           state     == .error ||
           loadedImg != nil {
            return
        } else {
            startDownloadImg()
        }
    }
    
    func startDownloadImg() {
        
        guard let okRow = indexRow else { return }
        
        downloadImg(imgUrl: url) { (isSuccess, loadedImg) in
            
            if isSuccess {
                self.loadedImg = loadedImg
            }
            
            self.delegate?.updateLoadedImg(indexRow: okRow)
        }
    }
}
