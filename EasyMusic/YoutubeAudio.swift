//
//  YoutubeAudio.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class YoutubeAudio{
    
    var title:String?
    var description:String?
    var videoLink:String?
    var imageLink:String?
    var audioLink:String?
    
    init(title:String, desc:String, videoLink:String, imageLink:String, audioLink:String)
    {
        self.title = title
        self.description = desc
        self.videoLink = videoLink
        self.imageLink = imageLink
        self.audioLink = audioLink
    }
}
