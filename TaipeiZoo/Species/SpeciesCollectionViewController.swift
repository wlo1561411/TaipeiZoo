//
//  SpeciesCollectionViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/4.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 Fetch species data, provide auto fetching when scroll at the end,
 filter species via search text(from notification)
 */
class SpeciesCollectionViewController: BaseCollectionViewController {
    
    var speciesCollectionView: UICollectionView! = nil
    
    var topBarView: TopBarView?
    
    lazy var collectionAi: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.color = .black
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        return ai
    }()
    lazy var results:      [Species] = {
       return [Species]()
    }()
        
    var lastOffsetY: CGFloat = 0

    var isSearch = false  // Search flag
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        addObserver()

        limit = normalLimit
        
        /*
         While viewDidLoad, fetch species data frist,
         and when fetch data success, configure speciesCollectionView via topBarView's search text.
         */
        firstFetch { (isSuc) in
            if isSuc {
                DispatchQueue.main.async {
                                        
                    if let okText = self.topBarView?.searchBar.text {
                        self.isSearch = true
                        self.configSearch(searchText: okText)
                    }
                    
                    self.speciesCollectionView.reloadData()
                    self.speciesCollectionView.isHidden = false
                    self.collectionAi.isHidden          = true
                    self.collectionAi.stopAnimating()
                }
            } 
        }
    }
    
    deinit {
        removeObserver()
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupUI() {
        
        setupCollectionView()
        
        view.addSubview(collectionAi)
        collectionAi.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        collectionAi.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapAction))  // Add tap gesture for end editing
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    fileprivate func setupCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        speciesCollectionView = UICollectionView(frame: .zero,
                                                 collectionViewLayout: flowLayout)
        
        speciesCollectionView.delegate        = self
        speciesCollectionView.dataSource      = self
        speciesCollectionView.isHidden        = true
        speciesCollectionView.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8392156863, alpha: 1)
        speciesCollectionView.keyboardDismissMode = .onDrag
        speciesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(speciesCollectionView)
        let hCons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[cv]-(0)-|",
                                                   options: [],
                                                   metrics: nil,
                                                   views: ["cv":speciesCollectionView as Any])
        let vCons = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[cv]-(0)-|",
                                                   options: [],
                                                   metrics: nil,
                                                   views: ["cv":speciesCollectionView as Any])
        NSLayoutConstraint.activate(hCons)
        NSLayoutConstraint.activate(vCons)
        
        registerCellNib()
    }
    
    fileprivate func registerCellNib() {
        
        speciesCollectionView.register(UICollectionReusableView.self,
                                       forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter,
                                       withReuseIdentifier: footerViewId)  // Register footer view
        
        let cellNib = UINib(nibName: "SpeciesCollectionViewCell", bundle: nil)
        speciesCollectionView.register(cellNib,
                                       forCellWithReuseIdentifier: speciesCellId)
    }
        
    fileprivate func configSearch(searchText: String) {  // Configure search action and set search flag.
        
        if searchText.isEmpty || searchText == "" {
            isSearch = false
            results  = []
        } else {
            isSearch = true
            setupResults(searchText: searchText)
        }
        
        speciesCollectionView.reloadData()
    }
    
    fileprivate func setupResults(searchText: String) {  // Setup search result
        
        let speciesArr: [Species] = isAnimal ? animals : plants
        
        filterSpecies(searchText: searchText.lowercased(),
                      species: speciesArr)
    }
    
    fileprivate func filterSpecies(searchText: String, species: [Species]) {  // Filter species
                
        results = species.filter({ (species) -> Bool in
            
            guard let chName = species.chName,
                let enName = species.enName?.lowercased() else { return false }
            
            if chName.contains(searchText) {
                return chName.contains(searchText)
            } else if enName.contains(searchText) {
                return enName.contains(searchText)
            }
            
            return false
        })
    }

    // MARK: - Buttion Actions
    
    @objc fileprivate func tapAction() {  // Tap gesture action
        
        guard let okBar = topBarView else { return }
        okBar.searchBar.resignFirstResponder()
    }
    
    // MARK: - Notfication
    
    fileprivate func addObserver() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSearch(_:)),
                                               name: Notification.Name(rawValue: "didSearch"),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadForFavoriteAction(notification:)),
                                               name: Notification.Name.init("reloadForFavoriteAction"),
                                               object: nil)
        
    }
    
    fileprivate func removeObserver() {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(rawValue: "didSearch"),
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.init("reloadForFavoriteAction"),
                                                  object: nil)
    }
        
    @objc fileprivate func didSearch(_ notification: Notification) {
        
        guard let okString = notification.object as? String,
              let okBar    = topBarView else { return }
        
        // Animate topBarView when search bar is editing and appearance != bottom, prevent animation stuck.
        if okBar.appearance != .bottom {
            okBar.delegate?.resetTopBar(isTop: false)
        }
        
        // Scroll speciesCollectionView to top when search bar is editing
        speciesCollectionView.setContentOffset(.zero, animated: false)
        
        configSearch(searchText: okString)
    }
    
    @objc fileprivate func reloadForFavoriteAction(notification: Notification) {  // Process cell's favorite button action's notification
        
        if let stateDic        = notification.object as? [String:Any],
           let selectedSpecies = stateDic["selectedSpecies"] as? Species {

           var speciesArr: [Species]?

           if isSearch {
               speciesArr = results
           } else {
               speciesArr = isAnimal ? animals : plants
           }

           guard let okSpeciesArr = speciesArr,
                 let indexRow     = okSpeciesArr.firstIndex(where: { $0.chName == selectedSpecies.chName }) else { return }

           UIView.performWithoutAnimation {
               speciesCollectionView.performBatchUpdates({
                   // Reload cell for change favorite button image
                   speciesCollectionView.reloadItems(at: [IndexPath(item: indexRow, section: 0)])
               }, completion: nil)
           }
        }
    }
}

// MARK: - CollectionView Delegate, DataSource

extension SpeciesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        // Get right species data count via flags
        if isSearch {
            return results.count
        } else {
            return isAnimal ? animals.count : plants.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let speciesCell = collectionView.dequeueReusableCell(withReuseIdentifier: speciesCellId, for: indexPath) as? SpeciesCollectionCell else {
            fatalError("speciesCell initalize error")
        }
                
        var species: Species?
        
        // Get right species data via flags, and configure cell
        if isSearch {
            species = results[indexPath.row]
        } else {
            species = isAnimal ? animals[indexPath.row] : plants[indexPath.row]
        }
        
        species?.setupImgTasks(imgDelegate: self)
        
        speciesCell.configCell(coreDataHandler: coreDataHandler,
                               species: species) { [weak self] in
                                
            guard let sSelf = self else { return }
            sSelf.postFavoriteNotification(species: species)
        }
                
        return speciesCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        /*
         Get right species data via flags, and process species image download action,
         fetch more data when collection view close to the end.
         */
        var imgTask: ImageDownloadTask?
        
        if isSearch {
            imgTask = results[indexPath.row].imgTasks.first
        } else {
            
            if isAnimal {
                
                imgTask = animals[indexPath.row].imgTasks.first
                
                if indexPath.row >= animals.count - 1 {
                    fetchMore(collectionView: collectionView,
                              startPoint: animals.count,
                              isSearch: isSearch,
                              section: 0)
                }
            } else {
                
                imgTask = plants[indexPath.row].imgTasks.first
                
                if indexPath.row >= plants.count - 1 {
                    fetchMore(collectionView: collectionView,
                              startPoint: plants.count,
                              isSearch: isSearch,
                              section: 0)
                }
            }
        }
        
        imgTask?.readyToDownloadImg()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        // Get right species data via flags, and post notification for push DetailViewController
        var species: Species?

        if isSearch {
            species = results[indexPath.row]
        } else {
            species = isAnimal ? animals[indexPath.row] : plants[indexPath.row]
        }

        NotificationCenter.default.post(name: Notification.Name("performToDetail"),
                                        object: species)
    }
}

// MARK: - CollectionView FlowLayout

extension SpeciesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate cell's width, 30 = |-10-(cell)-10-(cell)-10-|
        let width = (collectionView.frame.width - 30) / 2
        
        return CGSize(width: width,
                      height: width + speciesCellBasicH)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        
        // When user is searching, don't need to present foot view.
        if isSearch { return .zero }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        var footer = UICollectionReusableView()
        
        if kind == UICollectionView.elementKindSectionFooter {
            
            footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: footerViewId,
                                                                     for: indexPath)
            // Configure footer view via isFull flag
            if isFull {
                if !footer.subviews.contains(fullTextLb) {
                    footerAi.removeFromSuperview()
                    footer.addSubview(fullTextLb)
                    fullTextLb.centerYAnchor.constraint(equalTo: footer.centerYAnchor).isActive = true
                    fullTextLb.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
                }
            } else {
                if !footer.subviews.contains(footerAi) {
                    fullTextLb.removeFromSuperview()
                    footer.addSubview(footerAi)
                    footerAi.centerYAnchor.constraint(equalTo: footer.centerYAnchor).isActive = true
                    footerAi.centerXAnchor.constraint(equalTo: footer.centerXAnchor).isActive = true
                }
            }
        }

        return footer
    }
}

// MARK: - Scroll Delegate

extension SpeciesCollectionViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let okBar = topBarView else { return }
        
        let offsetY       = speciesCollectionView.contentOffset.y
        let maxTransValue = speciesCollectionView.contentSize.height - speciesCollectionView.frame.size.height
        let transValue    = abs(lastOffsetY - speciesCollectionView.contentOffset.y)
        let direction     = lastOffsetY - speciesCollectionView.contentOffset.y > 0 ? false:true
        
        lastOffsetY = speciesCollectionView.contentOffset.y  // Record offsetY temp
        
        okBar.delegate?.animateTopBar(direction: direction,
                                      offsetY: offsetY,
                                      transValue: transValue * 0.7,
                                      maxTransValue: maxTransValue)  // Animate topBarView via delegate
    }
}

// MARK: - Image Download Delegate

extension SpeciesCollectionViewController: ImageDownloadDelegate {
    
    // While image download finish, imageTask will call this delegate function for reload cell.
    func updateLoadedImg(indexRow: Int) {

        var row: Int?

        // If user is searching, will need to find same species first.
        if isSearch {

            let originImgTask = isAnimal ? animals[indexRow].imgTasks.first : plants[indexRow].imgTasks.first
            let searchedSpecies = results.filter({$0.imgTasks.first?.url == originImgTask?.url}).first
            row = results.firstIndex(where: {$0.chName == searchedSpecies?.chName})

        } else {
            row = indexRow
        }

        guard let okRow = row else { return }
        readyToReloadCell(collectionView: speciesCollectionView,
                          indexPaths: [IndexPath(item: okRow, section: 0)])
    }
}


