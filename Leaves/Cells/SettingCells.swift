//
//  SettingCellsTableViewCell.swift
//  Leaves
//
//  Created by Jay Patel on 11/08/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit

//EditProfileFieldID,
class ProfileTextFieldCell: UITableViewCell {
    
    @IBOutlet weak var profileTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//ProfileID
class ProfileImageCell: UITableViewCell {
    
    @IBOutlet weak var ProfileImageView: UIImageView!
    
    @IBOutlet weak var EditProfileImageButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }
    
}



//SyncID
class SyncCell: UITableViewCell {

    @IBOutlet weak var SyncLabel: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var Switch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//LogoutID
class LogoutCell: UITableViewCell {

    @IBOutlet weak var LogoutButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


//LeaveEditID
class LeaveEditingCell: UITableViewCell {
    
    
    @IBOutlet weak var LeaveTitle: UILabel!
    
    @IBOutlet weak var LeaveEditTextfield: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

