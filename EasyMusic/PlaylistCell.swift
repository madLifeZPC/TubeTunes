//
//  PlaylistCell.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 7/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {
    
    
    @IBOutlet weak var PlayListName: UILabel!
    @IBOutlet weak var PlayListSubtitle: UILabel!
    @IBOutlet weak var PlayListImage: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
}
