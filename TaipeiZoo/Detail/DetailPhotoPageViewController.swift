//
//  DetailPhotoPageViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/5.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 ImagePageViewController Cell's container view
 */
class DetailPhotoPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var frameVs = [FrameViewController]()
    
    /*
     This variable will be set by DetailViewController's function "cellForItemAt",
     when it didSet, setup page view controller's data source.
     */
    var imgTasks: [ImageDownloadTask]? {
        didSet {
            guard let okTasks = imgTasks else { return }
            if !frameVs.isEmpty { return }  // Prevent cell overloadeing, because "frameVs" only needs to be set once.
            
            for task in okTasks {
                let frameV = FrameViewController()
                frameV.imgTask = task
                frameVs.append(frameV)
            }

            if let okFirst = frameVs.first {
                setViewControllers([okFirst],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil);
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dataSource = self
    }
    
    // MARK: - PageView DataSource
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentView = viewController as? FrameViewController,
              let currentIndex = frameVs.firstIndex(where: {$0 == currentView}) else { return nil }
        
        if currentIndex > 0 {
            return frameVs[currentIndex - 1]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentView = viewController as? FrameViewController,
              let currentIndex = frameVs.firstIndex(where: {$0 == currentView}) else { return nil }
        
        if currentIndex < frameVs.count - 1 {
            return frameVs[currentIndex + 1]
        }
        
        return nil
    }
}

