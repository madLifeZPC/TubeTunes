//
//  YoutubePlaylist.swift
//  EasyMusic
//
//  Created by Selvaraju Vignesh on 9/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class YoutubePlaylist
{
    var playlistTitle: String?
    var playlistID:String?
    var playlistLink:String?
    var playlistImage:String?
    
    
    init(listID:String, listtitle: String, playlistImage: String)
    {
        self.playlistTitle = listtitle
        self.playlistID = listID
        self.playlistLink = "https://www.youtube.com/playlist?list=" + listID
        self.playlistImage = playlistImage
    }
    
}