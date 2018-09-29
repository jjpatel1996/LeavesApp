//
//  extensions.swift
//  Leaves
//
//  Created by Jay Patel on 29/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import Foundation
import UIKit


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
                Utility.downloadAndSaveProfileImage(profilePath: url.absoluteString)
                //save In Backend
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

extension UIColor {
    
    static func themeColor() -> UIColor {
        return UIColor.rgb(0, green: 122, blue: 225)
    }
    
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
                activityIndicator.style = .whiteLarge
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
    
    func popupAlertWithoutHandler(title: String?, message: String?, actionTitles:[String?]) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for title in actionTitles {
            let action = UIAlertAction(title: title, style: .default, handler: nil)
            alert.addAction(action)
        }
        
        self.present(alert, animated: true, completion: nil)
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
    
    convenience init(title: String?, style: UIAlertAction.Style, image: UIImage, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, style: style, handler: handler)
        self.actionImage = image
    }
    
    convenience init?(title: String?, style: UIAlertAction.Style, imageNamed imageName: String, handler: ((UIAlertAction) -> Void)? = nil) {
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
