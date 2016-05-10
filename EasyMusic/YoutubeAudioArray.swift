//
//  YoutubeAudioArray.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class YoutubeAudioArray{

    static let publicOnlinePlayList = YoutubeAudioArray()
    
    var audios = [YoutubeAudio]()
    var selectedIndex = 0
    
    private init(){}
}
