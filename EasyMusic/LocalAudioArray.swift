//
//  LocalAudioArray.swift
//  EasyMusic
//
//  Created by madlife on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class LocalAudioArray {
    
    static let publicLocalPlayList = LocalAudioArray()
    
    var audios = [LocalAudio]()
    var selectedIndex = 0
    
    private init(){}
    
}