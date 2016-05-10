//
//  LocalAudio.swift
//  EasyMusic
//
//  Created by madlife on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class LocalAudio {
    
    var title:String?
    var imageLink:String?
    var audioAddress:String?
    
    init(){}
    
    init(title:String, imageLink:String, audioAddress:String)
    {
        self.title = title
        self.imageLink = imageLink
        self.audioAddress = audioAddress
    }

}