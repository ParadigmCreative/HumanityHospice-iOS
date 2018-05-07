//
//  PostWithImageTableViewCell.swift
//  HumanityHospice
//
//  Created by App Center on 5/6/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit

class PostWithImageTableViewCell: JournalTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var postPhoto: UIImageView!
    
    var post: Post! {
        didSet {
            if post.postImage == nil {
                setupUI()
            } else {
                DispatchQueue.main.async {
                    self.postPhoto.image = self.post.postImage
                }
            }
        }
    }
    
    func setupUI() {
        DatabaseHandler.getImageFromStorage(url: post.imageURL!) { (image, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.post.postImage = image
                DispatchQueue.main.async {
                    self.postPhoto.image = image
                }
            }
        }
        self.postPhoto.layer.cornerRadius = 5
    }
    

}
