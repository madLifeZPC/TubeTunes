//
//  MyImageView.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class MyImageView: UIImageView {

    var albumView : UIImageView?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        enum UIUserInterfaceIdiom : Int
        {
            case Unspecified
            case Phone
            case Pad
        }
        
        struct ScreenSize
        {
            static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
            static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
            static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
            static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        }
        
        struct DeviceType
        {
            static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
            static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
            static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
            static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
            static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
            static let IS_IPAD_PRO          = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
        }

        
        if DeviceType.IS_IPHONE_5 {
            self.albumView = UIImageView(frame: CGRectMake(self.frame.size.width/2 - 80, self.frame.size.height/2 - 80, 160, 160))
            self.albumView?.clipsToBounds = true
            self.albumView?.layer.cornerRadius = 80
            self.addSubview(self.albumView!)
        }
        
        if DeviceType.IS_IPHONE_6 {
            self.albumView = UIImageView(frame: CGRectMake(self.frame.size.width/2 - 80, self.frame.size.height/2 - 80, 160, 160))
            self.albumView?.clipsToBounds = true
            self.albumView?.layer.cornerRadius = 80
            self.addSubview(self.albumView!)
            
        }
        
        if DeviceType.IS_IPHONE_6P {
            self.albumView = UIImageView(frame: CGRectMake(self.frame.size.width/2 - 66, self.frame.size.height/2 - 66, 230, 230))
            self.albumView?.clipsToBounds = true
            self.albumView?.layer.cornerRadius = 115
            self.addSubview(self.albumView!)

        }
        
        if DeviceType.IS_IPHONE_4_OR_LESS {
            self.albumView = UIImageView(frame: CGRectMake(self.frame.size.width/2 - 80, self.frame.size.height/2 - 80, 160, 160))
            self.albumView?.clipsToBounds = true
            self.albumView?.layer.cornerRadius = 80
            self.addSubview(self.albumView!)
            
        }

        
    }
    
    func setAlbumViewImage(imageUrl : String)
    {
        let imageData = NSData(contentsOfURL: NSURL(string: imageUrl)!)
        self.albumView?.image = UIImage(data: imageData!)
    }
    
    func startRotating()
    {
        let rotateAni = CABasicAnimation(keyPath: "transform.rotation")
        rotateAni.fromValue = 0.0
        rotateAni.toValue = M_PI * 2.0
        rotateAni.duration = 20.0
        rotateAni.repeatCount = MAXFLOAT
        self.layer.speed = 1.0
        self.layer.addAnimation(rotateAni, forKey: nil)
    }
    
    func pauseRotating()
    {
        let pausedTime = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        self.layer.speed = 0.0
        self.layer.timeOffset = pausedTime
    }
    
    func resumeRotating()
    {
        let pausedTime = self.layer.timeOffset
        self.layer.speed = 1.0
        self.layer.timeOffset = 0.0
        self.layer.beginTime = 0.0
        let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        self.layer.beginTime = timeSincePause
    }
    
    func stopRotating()
    {
        self.layer.speed = 0.0
        //self.layer.timeOffset = 0.0
    }
}
