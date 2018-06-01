//
//  EncouragementBoardTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/9/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class EncouragementBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageTF: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
