//
//  JournalTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/3/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class JournalTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var post: Post!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var commentsButton: UIButton!
    var commentDelegate: CommentsDelegate!
    
    @IBAction func showComments(_ sender: Any) {
        print("Comments")
        commentDelegate.userDidSelectPostForComments(post: self.post)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol CommentsDelegate {
    func userDidSelectPostForComments(post: Post)
}
