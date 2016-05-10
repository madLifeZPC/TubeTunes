//
//  YoutubeChannels.swift
//  EasyMusic
//
//  Created by Selvaraju Vignesh on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class YoutubeChannels
{
    var channelTitle: String?
    var channelID:String?
    var channelLink:String?
    var channelImage:String?
    
    
    init(channelID:String, channelTitle: String, channelImage: String)
    {
        self.channelTitle = channelTitle
        self.channelID = channelID
        self.channelLink = "https://www.youtube.com/channel/" + channelID
        self.channelImage = channelImage
    }

}