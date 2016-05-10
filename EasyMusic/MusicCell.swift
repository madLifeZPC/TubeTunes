//
//  MusicCell.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import UIKit

class MusicCell : UITableViewCell{
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var songImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }

}
