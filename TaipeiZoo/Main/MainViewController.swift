//
//  MainViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/5/27.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 This is main view for app,
 "containerView" is the SpeciesPageViewController for species(Animal & Plant),
 and "topBarView" is for switch species button and search bar.
 */
class MainViewController: UIViewController {
    
    // Segue id
    private let detailSegueId  = "goToDetail"
    private let speciesSegueId = "goToSpecies"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topBarView:    TopBarView!
    @IBOutlet weak var topBarTopCons: NSLayoutConstraint!  // topBarView top constraint
        
    var naviBarV    = UIView()  // Fake navigation bar
    var noInternetV = UIView()  // No internent View
        
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNaviBar()
    }

    deinit {
        print("Main View Dead")
        removeObserver()
    }
    
    // MARK: - Setup Functions
        
    fileprivate func setupUI() {
        
        addFakeNaviBar()
        addNoInternetView()
        
        topBarView.delegate           = self
        topBarView.searchBar.delegate = self
        
        noInternetV.isHidden = NetworkHandler.shareInstance.isConnect()
    }
    
    fileprivate func setupNaviBar() {
        
        if let okNavigationC = navigationController {
            
            okNavigationC.navigationBar.shadowImage = UIImage()  // Remove navigation bar's bottom line
            okNavigationC.navigationBar.tintColor = .black
            navigationItem.title = "臺北市立動物園"
            navigationItem.backBarButtonItem = UIBarButtonItem(title: " ",
                                                               style: .done,
                                                               target: nil,
                                                               action: nil)  // Remove default "Back" title
        }
    }
    
    /*
     Fake Navigation bar is for process about push to DetailViewController,
     prevent transparent navigation bar.
     */
    fileprivate func addFakeNaviBar() {

        if let okNavigationC = navigationController {
            
            naviBarV.frame = CGRect(x: 0,
                                    y: 0,
                                    width:  okNavigationC.navigationBar.frame.width,
                                    height: okNavigationC.navigationBar.frame.height +
                                            UIApplication.shared.statusBarFrame.height)
            naviBarV.backgroundColor = .white
            self.view.addSubview(naviBarV)
            
            // Configure goToFavorite button
            let goToFavoBtn = UIBarButtonItem(barButtonSystemItem: .action,
                                              target: self,
                                              action: #selector(goToFavorite))
            navigationItem.rightBarButtonItem = goToFavoBtn
        }
    }
        
    fileprivate func addNoInternetView() {
        
        noInternetV.isHidden = true
        noInternetV.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8392156863, alpha: 1)
        noInternetV.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noInternetV)
        noInternetV.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        noInternetV.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        noInternetV.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        noInternetV.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        let label = UILabel()
        label.text = "請檢查您的網路連線，或稍後再試。"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        noInternetV.addSubview(label)
        label.centerXAnchor.constraint(equalTo: noInternetV.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: noInternetV.centerYAnchor).isActive = true
    }

    // MARK: - Button Action
    
    @objc fileprivate func goToFavorite() {  // Push FavoriteViewController
        
        let main     = UIStoryboard(name: "Main", bundle: nil)
        let favorite = main.instantiateViewController(withIdentifier: "FavoriteViewController")
        
        if let okNavigationC = navigationController {
            okNavigationC.pushViewController(favorite, animated: true)
        }
    }
    
    // MARK: - Notification
    
    fileprivate func addObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(performToDetail(notification:)),
                                               name: Notification.Name(rawValue: "performToDetail"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goToFavorite),
                                               name: Notification.Name(rawValue: "performToFavorite"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(notification:)),
                                               name: Notification.Name.reachabilityChanged,
                                               object: nil)
    }
    
    fileprivate func removeObserver() {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: "performToDetail"),
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: "performToFavorite"),
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.reachabilityChanged,
                                                  object: nil)
    }
    
    @objc fileprivate func performToDetail(notification: Notification) {  // Push DetailViewController
        
        guard let species = notification.object else { return }
        performSegue(withIdentifier: detailSegueId, sender: species)
    }
    
    @objc fileprivate func reachabilityChanged(notification: Notification) {  // Check network is available
        
        if let isHidden = notification.object as? Bool {
            DispatchQueue.main.async {
                self.noInternetV.isHidden = isHidden
            }
        } else {
            DispatchQueue.main.async {
                self.noInternetV.isHidden = NetworkHandler.shareInstance.isConnect()
            }
        }
    }
    
    // MARK: - Navigate
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {  // Setup perfromSegue view controller's variable via segue id
        
        if segue.identifier == detailSegueId {
            
            if let dvc     = segue.destination as? DetailViewController,
               let species = sender as? Species,
               let okNum   = species.number {
                
                dvc.species            = species
                dvc.selectedSpeciesNum = okNum
            }
        } else if segue.identifier == speciesSegueId {
            
            if let dvc = segue.destination as? SpeciesPageViewController {
                dvc.topBarView  = topBarView
            }
        }
    }
}

// MARK: - TopBarView Delegate

extension MainViewController: TopBarViewDelegate {
    
    /*
     Animate topBarView via SpeciesCollectionViewController scroll action
     
     direction:     true = top, false = down
     offsetY:       collection view content offset
     transValue:    scroll action's translate value
     maxTransValue: max translate value
     */
    func animateTopBar(direction: Bool,
                       offsetY: CGFloat,
                       transValue: CGFloat,
                       maxTransValue: CGFloat) {
                
        let topBarCons = topBarTopCons.constant  // topBarView top constraint temp value
        topBarView.setAppearance(topConstraint: topBarCons)  // Set topBarView appearance
        
        // Animate topBarView via appearance
        switch topBarView.appearance {
            
        case .top:
            
            if !direction && offsetY <= maxTransValue {  // If direction is down & offsetY <= maxTransValue(at the end), animating
                if topBarCons + transValue > 0 {  // Prevent overanimate
                    topBarTopCons.constant = 0
                    return
                }
                topBarTopCons.constant += transValue
            }
            break
            
        case .middle:
            
            // Animate top bar via direction
            if direction {
                if offsetY >= maxTransValue {  // Prevent animation stuck when swipe page and the pre-page is at the end.
                    resetTopBar(isTop: true)
                    return
                } else if topBarCons - transValue < -topBarView.frame.height {  // Prevent overanimate
                    topBarTopCons.constant = -topBarView.frame.height
                    return
                }
                topBarTopCons.constant -= transValue
            } else {
                if topBarCons + transValue > 0 {  // Prevent overanimate
                    topBarTopCons.constant = 0
                    return
                }
                topBarTopCons.constant += transValue
            }
            break
            
        case .bottom:
            
            if direction && offsetY > 0 {  // If direction is up & offsetY > 0(at the top), animating
                if topBarCons - transValue < -topBarView.frame.height {  // Prevent overanimate
                    topBarTopCons.constant = -topBarView.frame.height
                    return
                }
                topBarTopCons.constant -= transValue
            }
            break
        }
    }
    
    func resetTopBar(isTop: Bool) {  // Animate topBarView to top or bottom
                
        if isTop {
            topBarTopCons.constant = -topBarView.frame.height
            topBarView.appearance  = .top
        } else {
            topBarTopCons.constant = 0
            topBarView.appearance  = .bottom
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
            
            self.view.layoutSubviews()
                        
        }, completion: nil)
    }
}

// MARK: - SearchBar Delegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        NotificationCenter.default.post(name: Notification.Name(rawValue: "didSearch"),
                                        object: searchText)  // Post notification when textDidChange
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if #available(iOS 11, *) {  // Change offset when start editing
            searchBar.setPositionAdjustment(.zero, for: .search)
        }
        
        // Animate topBarView when start editing and appearance != bottom, prevent animation stuck.
        if topBarView.appearance != .bottom {
            resetTopBar(isTop: false)
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        if #available(iOS 11, *) {
            if searchBar.text == "" {  // Change offset when end editing & search text == ""
                searchBar.setPositionAdjustment(topBarView.placeholderOffset, for: .search)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
