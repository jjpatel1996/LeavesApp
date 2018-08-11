//
//  Classes.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation
import UIKit

public class LeavesHandler {
    
    static func isSyncON() -> Bool {
        return UserDefaults.standard.bool(forKey: "Sync")
    }
    
    static func SetSync(isOn:Bool) {
        let storage = UserDefaults.standard
        storage.set(isOn, forKey: "Sync")
        storage.synchronize()
    }
    
    static func isFirstTime() -> Bool {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "FirstTime") == 0
    }
    
    static func DoneFirstTime() {
        let storage = UserDefaults.standard
        storage.set(1, forKey: "FirstTime")
        storage.synchronize()
    }
    
    static func getSickLeaves()  -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "SickLeave")
    }
    
    static func getWorkingLeaves() -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "WorkingLeave")
    }
    
    static func SetSickLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "SickLeave")
        storage.synchronize()
    }
    
    static func SetWorkingLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "WorkingLeave")
        storage.synchronize()
    }

    static func getRemainSickLeaves()  -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "RemainSickLeave")
    }
    
    static func getRemainWorkingLeaves() -> Int {
        let storage = UserDefaults.standard
        return storage.integer(forKey: "RemainWorkingLeave")
    }
    
    static func SetRemainSickLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "RemainSickLeave")
        storage.synchronize()
    }
    
    static func SetRemainWorkingLeaves(leaves:Int) {
        let storage = UserDefaults.standard
        storage.set(leaves, forKey: "RemainWorkingLeave")
        storage.synchronize()
    }
    
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

extension UIColor {
    
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func galleryBackgroundColor() -> UIColor {
        return UIColor.rgb(5, green: 29, blue: 38)
    }
    
    static func surveyBarColor() -> UIColor {
        return UIColor.rgb(54, green: 105, blue: 255)
    }
    
    static func blueButtonColor() -> UIColor {
        return UIColor.rgb(60, green: 140, blue: 255)
    }
    
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


extension UIViewController {
    
    func StartloadingScreen(){
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                
                let backView = UIView()
                backView.layer.cornerRadius = 9
                backView.backgroundColor = UIColor.black
                backView.tag = 123321
                backView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                backView.center = self.view.center
                backView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                window.addSubview(backView)
                
                let activityIndicator :UIActivityIndicatorView = UIActivityIndicatorView()
                activityIndicator.activityIndicatorViewStyle = .whiteLarge
                activityIndicator.color = UIColor.white
                activityIndicator.frame = CGRect(x: 21.5, y: 21.5, width: 37, height: 37)
                activityIndicator.tag = 123456
                activityIndicator.startAnimating()
                //  self.view.isUserInteractionEnabled = false
                window.isUserInteractionEnabled = false
                backView.addSubview(activityIndicator)
                //  window.bringSubview(toFront: backView)
                
            }
            
        }
    }
    
    func StoploadingScreen(){
        
        DispatchQueue.main.async {
            
            self.view.isUserInteractionEnabled = true
            
            if let window = UIApplication.shared.keyWindow {
                
                window.isUserInteractionEnabled = true
                
                if let blurView = window.subviews.filter (
                    { $0.tag == 123321}).first {
                    blurView.removeFromSuperview()
                }
            }
        }
    }
}

extension UIViewController {
    
    func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in actionTitles.enumerated() {
            if title == "Yes,Log out" || title == "Delete" {
                let action = UIAlertAction(title: title, style: .destructive, handler: actions[index])
                alert.addAction(action)
            }else{
                let action = UIAlertAction(title: title, style: .default, handler: actions[index])
                alert.addAction(action)
            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func popupAlertwithoutButton(title: String?, message: String?, seconds:Double = 1.0 ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + seconds
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func popupActionSheet(title: String?, message: String?, actionTitles:[String?],navigationItem:UINavigationItem,actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, title) in actionTitles.enumerated() {
            if title == "Cancel" {
                let action = UIAlertAction(title: title, style: .cancel, handler: actions[index])
                alert.addAction(action)
            }else{
                
                let action = UIAlertAction(title: title, style: .default, handler: actions[index])
                alert.addAction(action)
            }
            
        }
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        self.present(alert, animated: true, completion: nil)
    }
    
    func popupActionSheet2(title:String?,message:String?, actionTitles:[String],sender:UIButton,actions:[((UIAlertAction) -> Void)?]){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, title) in actionTitles.enumerated() {
            if title == "Cancel" {
                let action = UIAlertAction(title: title, style: .cancel, handler: actions[index])
                alert.addAction(action)
            }else{
                
                let action = UIAlertAction(title: title, style: .default, handler: actions[index])
                alert.addAction(action)
            }
            
        }
        
        if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
            currentPopoverpresentioncontroller.sourceView = sender
            currentPopoverpresentioncontroller.sourceRect = sender.bounds
            currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func popupActionSheetwithImage(title:String?,message:String?, actionTitles:[String],actionImages:[UIImage],navigationItem:UINavigationItem,actions:[((UIAlertAction) -> Void)?]){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (index, title) in actionTitles.enumerated() {
            if title == "Cancel" {
                let action = UIAlertAction(title: title, style: .cancel, handler: actions[index])
                alert.addAction(action)
            }else{
                let action = UIAlertAction(title: title, style: .default, image: actionImages[index], handler: actions[index])
                alert.addAction(action)
            }
            
        }
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func popupActionSheetwithImage2(title:String?,message:String?, actionTitles:[String],actionImages:[UIImage],sender:UIButton,actions:[((UIAlertAction) -> Void)?]){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (index, title) in actionTitles.enumerated() {
            if title == "Cancel" {
                let action = UIAlertAction(title: title, style: .cancel, handler: actions[index])
                alert.addAction(action)
            }else{
                let action = UIAlertAction(title: title, style: .default, image: actionImages[index], handler: actions[index])
                alert.addAction(action)
            }
            
        }
        
        if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
            currentPopoverpresentioncontroller.sourceView = sender
            currentPopoverpresentioncontroller.sourceRect = sender.bounds
            currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension UIAlertAction {
    
    convenience init(title: String?, style: UIAlertActionStyle, image: UIImage, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, style: style, handler: handler)
        self.actionImage = image
    }
    
    convenience init?(title: String?, style: UIAlertActionStyle, imageNamed imageName: String, handler: ((UIAlertAction) -> Void)? = nil) {
        if let image = UIImage(named: imageName) {
            self.init(title: title, style: style, image: image, handler: handler)
        } else {
            return nil
        }
    }
    
    var actionImage: UIImage {
        get {
            return self.value(forKey: "image") as? UIImage ?? UIImage()
        }
        set(image) {
            self.setValue(image, forKey: "image")
        }
    }
}
