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
    
    init(user:UserDetail?, frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.themeColor()
        
        let stackView =  UIStackView(arrangedSubviews: [nameLabel,emailLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        nameLabel.text = user?.UserName
        emailLabel.text = user?.emailAddress
        
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.heightAnchor.constraint(equalToConstant: 64),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
