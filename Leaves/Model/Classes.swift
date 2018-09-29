//
//  Classes.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol NotifyDelegate {
    func notify()
}


enum LeaveTableNames: String {
    case TotalLeaves = "Total_leaves"
    case Leaves = "Leaves"
    case User = "User"
}

@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 1
    @IBInspectable var shadowOffsetHeight: Int = 1
    @IBInspectable var shadowColor: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.3
    @IBInspectable var shadowRadius: CGFloat = 2.0
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowRadius = shadowRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
}

enum LeavesFont : String {
    case Helvetica = "Helvetica"
    case HelveticaBold = "HelveticaBold"
    case HelveticaNeue = "HelveticaNeue"
    case HelveticaNeueBold = "HelveticaNeue-Bold"
    
}


class UIBorderedTextField: UITextField {
    
    var borderColor:CGColor = UIColor.gray.cgColor  {
        didSet{
            self.layer.shadowColor = borderColor
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderStyle = .none
        setBottomBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setBottomBorder()
    }
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = borderColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
}
