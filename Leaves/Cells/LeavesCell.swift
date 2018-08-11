//
//  LeavesCell.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit

//LeaveID
class LeavesCell: UITableViewCell {

    @IBOutlet weak var cardView: CardView!
    
    @IBOutlet weak var LeaveCount: UILabel!
    @IBOutlet weak var LeaveDate: UILabel!
    @IBOutlet weak var LeaveTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

//LeaveHeaderID
class LeaveHeaderCell: UITableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    
    @IBOutlet weak var SickLeaveHeader: UILabel!
    @IBOutlet weak var SickLeaveDetails: UILabel!
    @IBOutlet weak var WorkingLeaveDetails: UILabel!
    @IBOutlet weak var WorkingLeaveHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
