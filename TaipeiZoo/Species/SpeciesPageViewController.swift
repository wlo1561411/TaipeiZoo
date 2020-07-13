//
//  SpeciesPageViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/4.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 MainViewController's container view,
 provide two pages to swipe(Animal & Plant)
 */
class SpeciesPageViewController: UIPageViewController {
        
    var speciesViews = [SpeciesCollectionViewController]()
    
    var topBarView: TopBarView?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupPageView()
        addObserver()
    }
    
    deinit {
        print("Species Page View Dead")
        removeObserver()
    }
    
    // MARK: - Setup Function
    
    fileprivate func setupPageView() {  // Setup page view controller's data source at first time
        
        delegate   = self
        dataSource = self
        
        for i in 0 ..< 2 {
            let collectionView = SpeciesCollectionViewController()
            collectionView.isAnimal   = i == 0 ? true : false
            collectionView.topBarView = topBarView
            speciesViews.append(collectionView)
        }
        
        if let okFirst = speciesViews.first {
            setViewControllers([okFirst],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    // MARK: - Notification
    
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(flipPage(_:)),
                                               name: NSNotification.Name(rawValue: "FlipPage"),
                                               object: nil)
    }
    
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "FlipPage"),
                                                  object: nil)
    }
    
    @objc func flipPage(_ notification: Notification) {  // Process switch species button action
        
        guard let isAnimal = notification.object as? Bool else { return }

        if isAnimal {
            let animal = speciesViews[0]
            setViewControllers([animal],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        } else {
            let plant = speciesViews[1]
            setViewControllers([plant],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
}

// MARK: - PageView DataSource, Delegate

extension SpeciesPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
       guard let currentView  = viewController as? SpeciesCollectionViewController,
             let currentIndex = speciesViews.firstIndex(where: {$0 == currentView}) else { return nil }
        
        if currentIndex > 0 {
            let preView = speciesViews[currentIndex - 1]
            return preView
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentView  = viewController as? SpeciesCollectionViewController,
              let currentIndex = speciesViews.firstIndex(where: {$0 == currentView}) else { return nil }
        
        if currentIndex < speciesViews.count - 1 {
            let nextView = speciesViews[currentIndex + 1]
            return nextView
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextView = pendingViewControllers.first as? SpeciesCollectionViewController else { return }
        
        // When swipe action start, swtich button style first
        if let okBar = topBarView {
            okBar.switchBtnStyle(isAnimal: nextView.isAnimal)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        guard let preView  = previousViewControllers.first as? SpeciesCollectionViewController else { return }
        
        if let okBar = topBarView {
            
            // When swipe action completed, swtich species button style
            if completed {
                
                // Animate topBarView when swipe action completed and appearance != bottom, prevent animation stuck.
                if okBar.appearance != .bottom {  
                    okBar.delegate?.resetTopBar(isTop: false)
                }
            } else {
                // If swipe action didn't completed, reset species button style
                okBar.switchBtnStyle(isAnimal: preView.isAnimal)
            }
        }
    }
}

