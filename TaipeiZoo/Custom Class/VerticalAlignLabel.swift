//
//  VerticalAlignLabel.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/2.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit

class VerticalAlignLabel: UILabel {
    
    enum VerticalAlignment {
        case top
        case middle
        case bottom
    }
    
    var verticalAlignment: VerticalAlignment = .middle {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var horizontalValue = {
        (textAlignment:NSTextAlignment, bounds:CGRect, textRect:CGRect) -> CGFloat in
        
        switch textAlignment {
            
        case .left, .natural, .justified:
            return bounds.origin.x
        case .center:
            return (bounds.size.width - textRect.size.width) / 2
        case .right:
            return bounds.size.width - textRect.size.width

        @unknown default:
            fatalError("Unknow error from get text alignment.")
        }
    }
    
    // MARK: - UI Function
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
        
        let rect = super.textRect(forBounds: bounds,
                                  limitedToNumberOfLines: limitedToNumberOfLines)
        let h = horizontalValue(textAlignment,bounds,rect)
        
        
        switch verticalAlignment {
            
        case .top:
            return CGRect(x: h,
                          y: bounds.origin.y,
                          width: rect.size.width,
                          height: rect.size.height)
        case .middle:
            return CGRect(x: h,
                          y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2,
                          width: rect.size.width,
                          height: rect.size.height)
        case .bottom:
            return CGRect(x: h,
                          y: bounds.origin.y + (bounds.size.height - rect.size.height),
                          width: rect.size.width,
                          height: rect.size.height)
        }
    }

    public override func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}
