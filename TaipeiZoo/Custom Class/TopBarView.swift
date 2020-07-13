//
//  TopBarView.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/4.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

protocol TopBarViewDelegate: AnyObject {
    
    func animateTopBar(direction: Bool,
                       offsetY: CGFloat,
                       transValue: CGFloat,
                       maxTransValue: CGFloat)
    
    func resetTopBar(isTop: Bool)
}

enum TopBarAppearance {
    case top
    case middle
    case bottom
}

class TopBarView: UIView {
    
    weak var delegate: TopBarViewDelegate?
    
    var appearance: TopBarAppearance = .bottom
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    lazy var animalBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("動物", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.backgroundColor = .darkGray
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    lazy var plantBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("植物", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.backgroundColor = .darkGray
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
        
    var placeholderOffset: UIOffset = .zero
        
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchBar()
        setupSpeciesBtn()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSearchBar()
        setupSpeciesBtn()
    }
    
    // MARK: - UI Functions
    
    func setAppearance(topConstraint: CGFloat) {
        
        if topConstraint >= 0 {
            appearance = .bottom
        } else if topConstraint > -self.frame.height &&
                  topConstraint < 0 {
            appearance = .middle
        } else if topConstraint <= -self.frame.height {
            appearance = .top
        }
    }
    
    func setupSearchBar() {
        
        self.addSubview(searchBar)
        searchBar.leftAnchor.constraint (equalTo: self.leftAnchor,  constant:  5).isActive = true
        searchBar.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        searchBar.topAnchor.constraint  (equalTo: self.topAnchor,   constant:  5).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        searchBar.placeholder   = "輸入欲搜尋的物種。"
        searchBar.returnKeyType = .done
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        DispatchQueue.main.async {
            
            // Change search bar's textfield outlet
            guard let textField = self.searchBar.value(forKey: "searchField") as? UITextField else { return }
            textField.frame.size.height = 35
            textField.backgroundColor = .white
            textField.textColor = .black
            
            // Change placeholder color
            guard let placeHolderLabel = textField.value(forKey: "placeholderLabel") as? UILabel else { return }
            placeHolderLabel.textColor = .gray
            
            // Change glassIcon color
            guard let glassIconView = textField.leftView as? UIImageView else { return }
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .gray
            
            if #available(iOS 11, *) {
                self.placeholderOffset = UIOffset(horizontal: (textField.frame.width -
                    placeHolderLabel.frame.width) / 2 - glassIconView.frame.width, vertical: 0)
                self.searchBar.setPositionAdjustment(self.placeholderOffset, for: .search)
            }
        }
    }
    
    func setupSpeciesBtn() {
        
        self.addSubview(animalBtn)
        self.addSubview(plantBtn)
        
        animalBtn.leftAnchor.constraint  (equalTo: self.leftAnchor,        constant:  12).isActive = true
        animalBtn.rightAnchor.constraint (equalTo: plantBtn.leftAnchor,    constant: -10).isActive = true
        animalBtn.topAnchor.constraint   (equalTo: searchBar.bottomAnchor, constant:   5).isActive = true
        animalBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor,      constant: -10).isActive = true
        animalBtn.tag = 0
        
        animalBtn.addTarget(self, action: #selector(flipPageAction(sender:)), for: .touchUpInside)
        animalBtn.layer.masksToBounds = true
        animalBtn.layer.cornerRadius  = 10
        
        plantBtn.rightAnchor.constraint (equalTo: self.rightAnchor,       constant: -12).isActive = true
        plantBtn.topAnchor.constraint   (equalTo: searchBar.bottomAnchor, constant:   5).isActive = true
        plantBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor,      constant: -10).isActive = true
        plantBtn.tag = 1
        
        plantBtn.addTarget(self, action: #selector(flipPageAction(sender:)), for: .touchUpInside)
        plantBtn.layer.masksToBounds = true
        plantBtn.layer.cornerRadius  = 10
        
        DispatchQueue.main.async {
            let btnWidth = (self.frame.size.width - (12 * 2 + 10)) / 2
            self.animalBtn.widthAnchor.constraint(equalToConstant: btnWidth).isActive = true
            self.plantBtn.widthAnchor.constraint (equalToConstant: btnWidth).isActive = true
            self.switchBtnStyle(isAnimal: true)
        }
    }
    
    func switchBtnStyle(isAnimal: Bool) {
        
        if isAnimal {
            animalBtn.isSelected = true
            plantBtn.isSelected  = false
            animalBtn.backgroundColor = .darkGray
            plantBtn.backgroundColor  = .lightGray
        } else {
            animalBtn.isSelected = false
            plantBtn.isSelected  = true
            animalBtn.backgroundColor = .lightGray
            plantBtn.backgroundColor  = .darkGray
        }
    }
    
    // MARK: - Button Action
    
    @objc func flipPageAction(sender:UIButton) {  // Species button action
        
        let notiName = Notification.Name(rawValue: "FlipPage")
        
        if appearance != .bottom {
            delegate?.resetTopBar(isTop: false)
        }
        
        if sender.tag == 0 {
            switchBtnStyle(isAnimal: true)
            
            NotificationCenter.default.post(name: notiName,
                                            object: true)
            
        } else if sender.tag == 1 {
            switchBtnStyle(isAnimal: false)
            
            NotificationCenter.default.post(name: notiName,
                                            object: false)
        }
    }
}
