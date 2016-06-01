//
//  Playlist.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class Playlist{
    
    var title:String?
    var desc:String?
    
    init (){}
    
    init(title:String, description:String)
    {
        self.title = title
        self.desc = description
    }
    
}