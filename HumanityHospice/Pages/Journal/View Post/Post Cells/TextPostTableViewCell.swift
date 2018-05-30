//
//  TextPostTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/29/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class TextPostTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    
    
    
    

}
