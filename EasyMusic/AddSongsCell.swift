//
//  AddSongsCell.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 10/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class AddSongsCell: UITableViewCell {

    @IBOutlet weak var SongImage: UIImageView!
    @IBOutlet weak var SongName: UILabel!
    @IBOutlet weak var CheckBox: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
