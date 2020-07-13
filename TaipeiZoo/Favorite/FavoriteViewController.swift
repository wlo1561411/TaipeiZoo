//
//  FavoriteViewController.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/16.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit
import CoreData

/*
 Fetch species from CoreData.
 */
class FavoriteViewController: BaseCollectionViewController {
    
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    
    lazy var favorites: [Species] = {
        return [Species]()
    }()

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        getFavorite()
        addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNaviBar()
    }
    
    deinit {
        print("Favorite View Dead")
        removeObserver()
    }
        
    // MARK: - Setup Functions
    
    fileprivate func setupUI() {
        
        favoriteCollectionView.delegate   = self
        favoriteCollectionView.dataSource = self
        
        registerCellNib()
    }
    
    fileprivate func registerCellNib() {
        
        let cellNib = UINib(nibName: "SpeciesCollectionViewCell", bundle: nil)
        favoriteCollectionView.register(cellNib,
                                        forCellWithReuseIdentifier: speciesCellId)
    }
    
    fileprivate func setupNaviBar() {
        
        if let okNavigationC = navigationController {
            
            okNavigationC.navigationBar.shadowImage = UIImage()
            okNavigationC.navigationBar.tintColor = .black
            navigationItem.title = "我的收藏"
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: " ",
                                                               style: .done,
                                                               target: nil,
                                                               action: nil)  // Remove default "Back" title
        }
    }
    
    fileprivate func getFavorite() {
        
        guard let okHelper = coreDataHandler else { return }
        
        if let entitys = okHelper.fetchFavorite(predicateString: nil) {
            
            for i in 0 ..< entitys.count {
                
                guard let speciesData = entitys[i].value(forKey: "speciesData") as? Data,
                      let isAnimal    = entitys[i].value(forKey: "isAnimal")    as? Bool else { return }
                
                var loadedImg: UIImage?
                
                // If favorite species has image, set loadedImage
                if let imgData = entitys[i].value(forKey: "imgData") as? Data {
                    loadedImg = UIImage(data: imgData)
                }
                                
                // Get right species class in order to decode speciesData
                if isAnimal {
                     if let animal = try? PropertyListDecoder().decode(Animal.self,
                                                                       from: speciesData) {
                        setupSpeciesFromCoreData(indexRow: i,
                                                 species: animal,
                                                 loadedImg: loadedImg)
                        favorites.append(animal)
                     }
                } else {
                    if let plant = try? PropertyListDecoder().decode(Plant.self,
                                                                     from: speciesData) {
                        setupSpeciesFromCoreData(indexRow: i,
                                                 species: plant,
                                                 loadedImg: loadedImg)
                        favorites.append(plant)
                    }
                }
            }
            
            favoriteCollectionView.reloadData()
        }
    }
    
    fileprivate func setupSpeciesFromCoreData(indexRow: Int,
                                              species: Species,
                                              loadedImg: UIImage?) {  // Manual setup imageTasks for decoded species
        
        species.setupImgTasks(imgDelegate: nil)
        
        if loadedImg != nil {
            species.imgTasks.first?.state = .finish
            species.imgTasks.first?.loadedImg = loadedImg
        } else {
            species.imgTasks.first?.state = .noResult
        }
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
                        
            if !isInsert {

                guard let indexRow = favorites.firstIndex(where: { $0.chName == selectedSpecies.chName }) else { return }

                UIView.performWithoutAnimation {
                    favorites.remove(at: indexRow)
                    favoriteCollectionView.performBatchUpdates({
                        favoriteCollectionView.deleteItems(at: [IndexPath(item: indexRow, section: 0)])
                    }, completion: nil)
                }
            } else {

                UIView.performWithoutAnimation {
                    favorites.insert(selectedSpecies, at: 0)
                    favoriteCollectionView.performBatchUpdates({
                        favoriteCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                    }, completion: nil)
                }
            }
        }
    }
}

// MARK: - CollectionView Delegate, DataSource

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let speciesCell = collectionView.dequeueReusableCell(withReuseIdentifier: speciesCellId, for: indexPath) as? SpeciesCollectionCell else {
            fatalError("speciesCell initalize error")
        }
        
        let species = favorites[indexPath.row]
        
        speciesCell.configCell(coreDataHandler: coreDataHandler,
                               species: species) { [weak self] in
                                
            guard let sSelf = self else { return }
            sSelf.postFavoriteNotification(species: species)
        }
        
        return speciesCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let source = favorites[indexPath.row]

        NotificationCenter.default.post(name: Notification.Name("performToDetail"),
                                        object: source)  // Post notification for push DetailViewController
    }
}

// MARK: - CollectionView FlowLayout

extension FavoriteViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Calculate cell's width, 30 = |-10-(cell)-10-(cell)-10-|
        let width = (collectionView.frame.width - 30) / 2
        
        return CGSize(width: width,
                      height: width + 110)
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
}
