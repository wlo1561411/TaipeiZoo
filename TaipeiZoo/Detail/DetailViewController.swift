//
//  DetailViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/5.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

/*
 Presnt the species image and details on section 0,
 and fetch other species on section 1.
 */
class DetailViewController: BaseCollectionViewController {
    
    private let horiValue: CGFloat = 17  // Left & Right constraint
    private let vertValue: CGFloat = 15  // Top & Bottom constraint
    private let imgViewH:  CGFloat = 300 // DetailPhotoPageViewController's height
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var naviBarV    = UIView()
    
    let favoBarBtnItem     = UIBarButtonItem()
    let goToFavoBarBtnItem = UIBarButtonItem()

    var saturation: CGFloat = 0  // Navigation bar's saturation value
    
    var species: Species?
    var selectedSpeciesNum = 0
    
    var detailsCount  = 3  // Prevent the species data will be nil, so it needs to calulate count.
    
    var basic         = [String?]()
    var taxonomy      = [String?]()
    var descriptions  = [String?]()

    var basicH:        CGFloat = 0
    var taxonomyH:     CGFloat = 0
    var descriptionsH: CGFloat = 0
        
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        limit  = detailLimit
        offset = selectedSpeciesNum
        
        setupUI()
        setupDetails()
        addObserver()
        fetchMoreSpecies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        translateNaviBar()  // Reset Navigation bar's translation
    }
    
    override func viewDidLayoutSubviews() {
        setupDetailsHeight()
    }
    
    deinit {
        print("Detail View Dead")
        removeObserver()
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupUI(){
        
        detailCollectionView.delegate   = self
        detailCollectionView.dataSource = self
        
        setupNaviBar()
        registerCellNib()
    }
    
    fileprivate func registerCellNib() {
        
        detailCollectionView.register(UICollectionReusableView.self,
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                      withReuseIdentifier: footerViewId)
        
        let pageCellNib = UINib(nibName: "ImgPageViewControllerCell", bundle: nil)
        detailCollectionView.register(pageCellNib,
                                      forCellWithReuseIdentifier: pageCellId)
        
        let detailCellNib = UINib(nibName: "TaxonomyCollectionViewCell", bundle: nil)
        detailCollectionView.register(detailCellNib,
                                      forCellWithReuseIdentifier: taxonomyCellId)
        
        let descriptionCellNib = UINib(nibName: "DescriptionCollectionViewCell", bundle: nil)
        detailCollectionView.register(descriptionCellNib,
                                      forCellWithReuseIdentifier: descriptionCellId)
        
        let cellNib = UINib(nibName: "SpeciesCollectionViewCell", bundle: nil)
        detailCollectionView.register(cellNib,
                                      forCellWithReuseIdentifier: speciesCellId)
    }
    
    fileprivate func setupNaviBar() {
        
        if let okNavigationC = navigationController {
            
            okNavigationC.navigationBar.setBackgroundImage(UIImage(), for: .default)  // Set Navigation bar background transparent
            okNavigationC.navigationBar.tintColor = .white
            naviBarV.frame = CGRect(x: 0,
                                    y: 0,
                                    width:  okNavigationC.navigationBar.frame.width,
                                    height: okNavigationC.navigationBar.frame.height +
                                            UIApplication.shared.statusBarFrame.height)
            naviBarV.backgroundColor = .clear
            self.view.addSubview(naviBarV)
            
            favoBarBtnItem.target = self
            favoBarBtnItem.action = #selector(favoriteBarBtnItemAction)
            
            let goToFavoBtn = UIBarButtonItem(barButtonSystemItem: .action,
                                              target: self,
                                              action: #selector(goToFavoriteAction))
            
            if let okChName = species?.chName,
               let okHelper = coreDataHandler {  // Set favorite button's image

                if okHelper.isContain(chName: okChName) {
                    favoBarBtnItem.image = UIImage(named: "heart-fill")
                } else {
                    favoBarBtnItem.image = UIImage(named: "heart-empty")
                }
            }
            
            navigationItem.rightBarButtonItems = [favoBarBtnItem, goToFavoBtn]
            navigationItem.backBarButtonItem = UIBarButtonItem(title: " ",
                                                               style: .done,
                                                               target: nil,
                                                               action: nil)  // Remove default "Back" title
        }
    }
    
    fileprivate func translateNaviBar() {
        
        if let okNavigationC = navigationController {
            
            // Translate navigation bar via saturation
            naviBarV.backgroundColor = UIColor.white.withAlphaComponent(saturation)
            okNavigationC.navigationBar.tintColor = UIColor(hue: 1,
                                                            saturation: saturation,
                                                            brightness: 1,
                                                            alpha: 1)
        }
    }
    
    fileprivate func setupDetails() {  // Setup details in order to calculate label's height, and configure cell.
                
        if let animal = species as? Animal {
            
            isAnimal = true
            
            basic        = [animal.chName,
                            animal.enName,
                            animal.laName,
                            animal.location]
        
            taxonomy     = [animal.phylum,
                            animal.aClass,
                            animal.order,
                            animal.family].filter({$0 != nil && $0 != ""})
        
            descriptions = [animal.interpretation,
                            animal.distribution,
                            animal.habitat,
                            animal.behavior,
                            animal.diet,
                            animal.feature].filter({$0 != nil && $0 != ""})

        } else if let plant = species as? Plant {
            
            isAnimal = false
            
            basic        = [plant.chName,
                            plant.enName,
                            plant.laName,
                            plant.location]
        
            taxonomy     = [plant.family,
                            plant.genus].filter({$0 != nil && $0 != ""})
        
            descriptions = [plant.brief,
                            plant.commonName,
                            plant.feature,
                            plant.function].filter({$0 != nil && $0 != ""})
        }
        
        // Get species maximum from UserDefault, and set isFull flag
        let maxId = isAnimal ? webService.ANIMAL_MAXIMUM : webService.PLANT_MAXIMUM
        if let okMax = UserDefaults.standard.value(forKey: maxId) as? Int {
            
            maximum = okMax
            
            if offset >= maximum {
                isFull = true
            }
        }
    }
    
    fileprivate func setupDetailsHeight() {
        
        // If detailCollectionView had updated, will need to reset detailsCount.
        detailsCount = 3
        
        basicH        = caluContentHeight(font: UIFont.systemFont(ofSize: 17),
                                          horizontalSpace: horiValue,
                                          verticalSpace: vertValue,
                                          labelSpace: 8,
                                          strings: basic) + imgViewH
        
        taxonomyH     = caluContentHeight(font: UIFont.systemFont(ofSize: 15),
                                          horizontalSpace: horiValue,
                                          verticalSpace: vertValue,
                                          labelSpace: 8,
                                          strings: taxonomy)
        
        descriptionsH = caluContentHeight(font: UIFont.systemFont(ofSize: 15),
                                          horizontalSpace: horiValue,
                                          verticalSpace: vertValue,
                                          labelSpace: 12,
                                          strings: descriptions)
    }
    
    fileprivate func caluContentHeight(font: UIFont,
                                       horizontalSpace: CGFloat,
                                       verticalSpace: CGFloat,
                                       labelSpace: CGFloat,
                                       strings: [String?]) -> CGFloat {
        if strings.isEmpty {
            detailsCount -= 1
            return 0
        }
        
        var contentHeight: CGFloat = 0
        let hs  = horizontalSpace * 2
        let vs  = verticalSpace   * 2
        let lbs = labelSpace * CGFloat(strings.count - 1)
        
        // Calulate every string's height
        for str in strings {
            let textHeight = caluStringHeight(font: font,
                                            width: view.frame.width - hs,
                                            str: str)
            contentHeight += textHeight
        }

        contentHeight += CGFloat(vs + lbs)
        
        return ceil(contentHeight) + 1
    }
    
    fileprivate func caluStringHeight(font:UIFont,
                                      width: CGFloat ,
                                      str:String?) -> CGFloat {
        guard let text  = str,
                  text != ""  else { return 0 }
        
        let maxSize = CGSize(width: width,
                             height: CGFloat(Float.infinity))
        let textSize = text.boundingRect(with: maxSize,
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedString.Key.font: font],
                                         context: nil) 
        return textSize.height
    }
    
    // MARK: - Button Action
    
    @objc func goToFavoriteAction() {  // Post notification for push FavoriteViewController
        
        NotificationCenter.default.post(name: Notification.Name.init("performToFavorite"),
                                        object: nil)
    }
    
    @objc func favoriteBarBtnItemAction() {  // Setup favorite button action
        postFavoriteNotification(species: species)
    }
    
    // MARK: - Notfication
    
    fileprivate func addObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadForFavoriteAction(notification:)),
                                               name: Notification.Name.init("reloadForFavoriteAction"),
                                               object: nil)
    }
    
    fileprivate func removeObserver() {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.init("reloadForFavoriteAction"),
                                                  object: nil)
    }
    
    @objc fileprivate func reloadForFavoriteAction(notification: Notification) {  // Process cell's favorite button action's notification
     
        if let stateDic        = notification.object as? [String:Any],
           let isInsert        = stateDic["isInsert"] as? Bool,
           let selectedSpecies = stateDic["selectedSpecies"] as? Species {

            if selectedSpecies.number == species?.number {  // Set navigation bar's favorite button image
                favoBarBtnItem.image = isInsert ? UIImage(named: "heart-fill") : UIImage(named: "heart-empty")
                return
            }

            let speciesArr: [Species] = isAnimal ? animals : plants

            guard let indexRow = speciesArr.firstIndex(where: { $0.chName == selectedSpecies.chName }) else { return }

            UIView.performWithoutAnimation {
                detailCollectionView.performBatchUpdates({
                    // Reload species cell for change favorite button image
                    detailCollectionView.reloadItems(at: [IndexPath(item: indexRow, section: 1)])
                }, completion: nil)
            }
        }
    }
}


// MARK: - Web Service

extension DetailViewController {
    
    fileprivate func fetchMoreSpecies() {
        
        /*
         In order to set the other species data's number right,
         startPoint need to add selected species number.
         So, the image download delegate's callback function will need to be added too.
         */
        guard let okNum = species?.number else { return }
        let from = isAnimal ? animals.count : plants.count
        
        fetchMore(collectionView: detailCollectionView,
                  startPoint: from + okNum,
                  isSearch: false,
                  section: 1)
    }
}

// MARK: - CollectionView Delegate, DataSource

/*
 section 0 = selected species detail
 section 1 = fetch other species
 */
extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return detailsCount
        } else {
            return isAnimal ? animals.count : plants.count;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                guard let pageCell = collectionView.dequeueReusableCell(withReuseIdentifier: pageCellId,
                                                                        for: indexPath) as? ImagePageViewControllerCell
                    else {
                        fatalError("pageCell initalize error")
                }
                
                if let okSpecies = species {
                    pageCell.configCell(species: okSpecies,
                                        parentView: self)
                }
                
                return pageCell
                
            } else if indexPath.row == 1 {
                
                guard let taxonomyCell = collectionView.dequeueReusableCell(withReuseIdentifier: taxonomyCellId,
                                                                            for: indexPath) as? TaxonomyCollectionViewCell
                    else {
                        fatalError("taxonomyCell initalize error")
                }
                
                taxonomyCell.configCell(taxonomy: taxonomy)
                
                return taxonomyCell
                
            } else  {  // row == 2
                
                guard let descriptionCell = collectionView.dequeueReusableCell(withReuseIdentifier: descriptionCellId,
                                                                               for: indexPath) as? DescriptionCollectionViewCell
                    else {
                        fatalError("descriptionCell initalize error")
                }
                
                descriptionCell.configCell(descriptions: descriptions)
                
                return descriptionCell
                
            }
            
        } else {
            
            guard let speciesCell = collectionView.dequeueReusableCell(withReuseIdentifier: speciesCellId, for: indexPath) as? SpeciesCollectionCell else {
                fatalError("speciesCell initalize error")
            }
            
            // Get right species data via flags, and configure cell
            let species = isAnimal ? animals[indexPath.row] : plants[indexPath.row]
            
            species.setupImgTasks(imgDelegate: self)
            
            speciesCell.configCell(coreDataHandler: coreDataHandler,
                                   species: species) { [weak self] in
                                    
                guard let sSelf = self else { return }
                sSelf.postFavoriteNotification(species: species)
            }
            
            return speciesCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            /*
             Get right species data via flags, and process species image download action,
             fetch more data when collection view close to the end.
             */
            var imgTask: ImageDownloadTask?
            
            if isAnimal {

                imgTask = animals[indexPath.row].imgTasks.first

                if indexPath.row >= animals.count - 1 {
                    fetchMoreSpecies()
                }
            } else {

                imgTask = plants[indexPath.row].imgTasks.first

                if indexPath.row >= plants.count - 1 {
                    fetchMoreSpecies()
                }
            }
            
            imgTask?.readyToDownloadImg()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            // Get right species data via flags, and post notification for push DetailViewController
            let selectedSpecies = isAnimal ? animals[indexPath.row] : plants[indexPath.row]
        
            NotificationCenter.default.post(name: Notification.Name("performToDetail"),
                                            object: selectedSpecies)
        }
    }
}

// MARK: - CollectionView FlowLayout

/*
 section 0 = selected species detail
 section 1 = fetch other species
 */
extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.frame.width,
                              height: basicH)
            } else if indexPath.row == 1 {
                return CGSize(width: collectionView.frame.width,
                              height: taxonomyH)
            } else {
                return CGSize(width: collectionView.frame.width,
                              height: descriptionsH)
            }
        } else {
            
            // Calculate cell's width, 30 = |-10-(cell)-10-(cell)-10-|
            let width = (collectionView.frame.width - 30) / 2
            
            return CGSize(width: width,
                          height: width + speciesCellBasicH)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        } else {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if section == 0 {
            return 15
        } else {
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize.zero
        } else {
            return CGSize(width: collectionView.frame.width,
                          height: 100)
        }
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

extension DetailViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY        = scrollView.contentOffset.y
        let maxTransValue  = scrollView.contentSize.height - scrollView.frame.size.height
        saturation         = offsetY / 150
            
        if offsetY < maxTransValue {  // Set saturation via detailCollectionView content offset
            if saturation > 1 {
                saturation = 1
            }
        } else {
            saturation = 1
        }
        
        translateNaviBar()  // translate
    }
}

// MARK: - Image Download Delegate

extension DetailViewController: ImageDownloadDelegate {
    
    // While image download finish, imageTask will call this delegate function for reload cell.
    func updateLoadedImg(indexRow: Int) {
        
        /*
         This delegate call back function will configure cell reload,
         but the "indexRow" != species array's row,
         it had been added selected species number at fetch other finish before.
         
         Therefore the "indexRow" needs to be subtracted selected species number,
         then check "countedNum" is reloadable or not.
         */
        let countedNum       = indexRow - selectedSpeciesNum
        let loadedSpeciesNum = isAnimal ? animals.count - 1 : plants.count - 1

        if countedNum >= 0 &&
           countedNum <= loadedSpeciesNum {
            super.readyToReloadCell(collectionView: detailCollectionView,
                                    indexPaths: [IndexPath(item: countedNum ,section: 1)])
        }
    }
}
