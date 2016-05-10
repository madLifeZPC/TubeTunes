//
//  PlayListController.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 9/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlayListController: UIViewController {
    
    @IBOutlet weak var PlayListName: UITextField!
    @IBOutlet weak var PlayListDesc: UITextField!
    var playlists : Playlist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //PlayListName.text = playlists
        //print(playlists.title)
        PlayListName.text = playlists.title
        PlayListDesc.text = playlists.desc
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        playlists.title = PlayListName.text!
        playlists.desc = PlayListDesc.text!
    }
    
}