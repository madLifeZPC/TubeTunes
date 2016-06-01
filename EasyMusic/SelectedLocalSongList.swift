//
//  SelectedLocalSong.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 10/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation

class SelectedLocalSongList {
    
    static let selectedLocalSongList = SelectedLocalSongList()
    
    var songs = [SelectedLocalAudio]()
    
    private init(){}
    
}