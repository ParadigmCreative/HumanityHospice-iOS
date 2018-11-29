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
    
    var post: EBPost! {
        didSet {
            DatabaseHandler.getProfilePicture(for: post.posterUID) { (img) in
                if let image = img {
                    self.profilePicture.image = image
                    self.profilePicture.setupSecondaryProfilePicture()
                    self.profilePicture.contentMode = .scaleAspectFill
                } else {
                    self.profilePicture.image = #imageLiteral(resourceName: "Logo")
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
