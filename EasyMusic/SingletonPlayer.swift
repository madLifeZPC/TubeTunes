//
//  SingletonPlayer.swift
//  EasyMusic
//
//  Created by madlife on 4/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import AVFoundation

class SingletonPlayer{
    
    static let uniqueAudioPlayer = SingletonPlayer() 
    
    var audioPlayer : AVAudioPlayer?
    var playingCategory : PlayingCategory?
    var playingMode : PlayingMode?
    var songCache : NSData?
    var playEntrance : PlayEntrance?
    private init(){
       
    }
    
}
