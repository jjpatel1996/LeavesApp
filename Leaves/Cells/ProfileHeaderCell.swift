//
//  ProfileHeaderCell.swift
//  Leaves
//
//  Created by Jay Patel on 12/09/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit

class ProfileHeader: UIView {
    
    var nameLabel: UILabel = {
        let NameLabel = UILabel()
        NameLabel.font = UIFont(name: "Avenir Next-Demi Bold", size: 18)
        NameLabel.textColor = UIColor.white
        return NameLabel
    }()
    
    var emailLabel: UILabel = {
        let EmailLabel = UILabel()
        EmailLabel.font = UIFont(name: "Avenir Next", size: 15)
        EmailLabel.textColor = UIColor.white
        return EmailLabel
    }()
    
    var profileImageview:UIImageView = {
       let profile = UIImageView(image: #imageLiteral(resourceName: "UserProfile"))
       profile.translatesAutoresizingMaskIntoConstraints = false
       profile.layer.cornerRadius = 35
       profile.layer.masksToBounds = true
       return profile
    }()
    
    init(user:UserDetail?, frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.themeColor()
        
        let stackView =  UIStackView(arrangedSubviews: [nameLabel,emailLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(profileImageview)
        
        nameLabel.text = user?.UserName
        emailLabel.text = user?.emailAddress
        if user != nil && user!.profileURL != nil {
            profileImageview.downloadedFrom(link: user!.profileURL!)
        }
        
        NSLayoutConstraint.activate([
            profileImageview.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            profileImageview.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImageview.widthAnchor.constraint(equalToConstant: 70),
            profileImageview.heightAnchor.constraint(equalToConstant: 70)])
        
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: profileImageview.leadingAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.heightAnchor.constraint(equalToConstant: 64),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
