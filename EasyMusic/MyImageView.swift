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
        self.albumView = UIImageView(frame: CGRectMake(self.frame.size.width/2 - 80, self.frame.size.height/2 - 80, 160, 160))
        self.albumView?.clipsToBounds = true
        self.albumView?.layer.cornerRadius = 80
        self.addSubview(self.albumView!)
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
