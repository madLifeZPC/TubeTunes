//
//  SelectedLocalAudio.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 10/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class SelectedLocalAudio {
    
    var title:String?
    var imageLink:String?
    var audioAddress:String?
    var selected = false
    
    init(){}
    
    init(title:String, imageLink:String, audioAddress:String)
    {
        self.title = title
        self.imageLink = imageLink
        self.audioAddress = audioAddress
    }
    
}