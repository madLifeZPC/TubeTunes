//
//  PlayController.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreData

class PlayController: UIViewController ,NSURLSessionDataDelegate, AVAudioPlayerDelegate{
    
    // ui components
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var albumImageView: MyImageView!
    @IBOutlet weak var playProgressBar: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseBtn: UIButton!
    
    @IBOutlet weak var playModeBtn: UIButton!
    
    @IBOutlet weak var downLoadBtn: UIButton!
    var needleImageView : UIImageView?
    var timer : NSTimer?
    
    // audio player
    var player = SingletonPlayer.uniqueAudioPlayer
    
    // online Resources
    var onlineSongs = YoutubeAudioArray.publicOnlinePlayList
    var songCache : NSData?
    
    // local Resources
    var localSongs = LocalAudioArray.publicLocalPlayList
    
    // play status
    var isPlaying : Bool?
    
    // online requestCount
    var requestCount = 0
    
    // CoreData context
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load needlImageView
        self.needleImageView = UIImageView(frame: CGRectMake(160, 90, 60, 105))
        self.setAnchorPoint(CGPointMake(0.25, 0.16), forview: self.needleImageView!)
        self.rotateNeedle(false,speed: 0.0)
        self.needleImageView?.image = UIImage(named: "cm2_play_needle_play.png")
        self.view.addSubview(self.needleImageView!)
       
        // stop playing last song
        if self.player.audioPlayer != nil {
            self.player.audioPlayer!.stop()
            self.player.audioPlayer = nil
        }
        
        //play
        if self.player.playingCategory == PlayingCategory.OnlinePlaying {
            if onlineSongs.audios.isEmpty == false{
                self.startOnlinePlaying()
            }
        }
        else
        {
            if localSongs.audios.isEmpty == false{
                self.startLocalPlaying()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayController.updateUI), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    // update ui when come back from background
    func updateUI()
    {
        
        if self.player.playingCategory == PlayingCategory.OnlinePlaying{
            
            let index = onlineSongs.selectedIndex
            
            // set the title of the navigationBar
            self.navigationItem.title = self.onlineSongs.audios[(self.onlineSongs.selectedIndex)].title
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            
            //Load background image and blur effect
            self.setBackgroundImage((onlineSongs.audios[index].imageLink)!)
            let blurEffect = UIBlurEffect(style: .Light)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.alpha = 1.0
            visualEffectView.frame = UIScreen.mainScreen().bounds
            self.backgroundImageView.addSubview(visualEffectView)
            
            //load albumView
            self.albumImageView.setAlbumViewImage((onlineSongs.audios[index].imageLink)!)
        }
        else{
            let index = localSongs.selectedIndex
            
            // set the title of the navigationBar
            self.navigationItem.title = self.localSongs.audios[(self.localSongs.selectedIndex)].title
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            
            //Load background image and blur effect
            self.setBackgroundImage((localSongs.audios[index].imageLink)!)
            let blurEffect = UIBlurEffect(style: .Light)
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.alpha = 1.0
            visualEffectView.frame = UIScreen.mainScreen().bounds
            self.backgroundImageView.addSubview(visualEffectView)
            
            //load albumView
            self.albumImageView.setAlbumViewImage((localSongs.audios[index].imageLink)!)
            
        }
        
        // ui synchronize
        let duration = self.player.audioPlayer!.duration
        if self.player.audioPlayer?.currentTime == duration
        {
            self.playProgressBar.setProgress(0, animated: false)
            if self.player.audioPlayer != nil {
                self.player.audioPlayer!.stop()
                self.player.audioPlayer = nil
            }
            self.totalTimeLabel.text = self.durationToString(Int(duration))
            self.timer?.invalidate()
            self.timer = nil
            self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_play_normal.png"),
                                                   forState: .Normal)
            self.isPlaying = false
        }
        else
        {
            self.rotateNeedle(true, speed: 0.5)
            self.albumImageView.startRotating()
            self.totalTimeLabel.text = self.durationToString(Int(duration))
            self.timer?.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0,target: self,selector: #selector(PlayController.onUpdate), userInfo: nil, repeats: true)
            self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_pause_normal.png"),
                                                   forState: .Normal)
            // start playing
            self.isPlaying = true
            
        }

        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        self.requestCount = 0
        self.songCache = nil
        
    }
    
    // play online songs, first download, then play
    func startOnlinePlaying()
    {
        let index = onlineSongs.selectedIndex
        
        // set the title of the navigationBar
        self.navigationItem.title = self.onlineSongs.audios[(self.onlineSongs.selectedIndex)].title
        self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        
        //Load background image and blur effect
        self.setBackgroundImage((onlineSongs.audios[index].imageLink)!)
        let blurEffect = UIBlurEffect(style: .Light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 1.0
        visualEffectView.frame = UIScreen.mainScreen().bounds
        self.backgroundImageView.addSubview(visualEffectView)
        
        //load albumView
        self.albumImageView.setAlbumViewImage((onlineSongs.audios[index].imageLink)!)
        
        //start downloading selected song from youtube
        KVNProgress.setConfiguration(KVNProgressConfiguration.defaultConfiguration())
        KVNProgress.showWithStatus("Loading from Youtube...")
        self.downloadFromYoutube((onlineSongs.audios[index].audioLink)!)
    }
    
    // play local songs
    func startLocalPlaying()
    {
        let index = localSongs.selectedIndex
        
        // set the title of the navigationBar
        self.navigationItem.title = self.localSongs.audios[(self.localSongs.selectedIndex)].title
        self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        
        //Load background image and blur effect
        self.setBackgroundImage((localSongs.audios[index].imageLink)!)
        let blurEffect = UIBlurEffect(style: .Light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 1.0
        visualEffectView.frame = UIScreen.mainScreen().bounds
        self.backgroundImageView.addSubview(visualEffectView)
        
        //load albumView
        self.albumImageView.setAlbumViewImage((localSongs.audios[index].imageLink)!)
        
        let audioAddress = self.localSongs.audios[self.localSongs.selectedIndex].audioAddress
        let fileURL : NSURL = NSURL(fileURLWithPath: audioAddress!)
        do {
            let data = try NSData(contentsOfFile: fileURL.path!,options: .DataReadingMappedIfSafe)
            self.songCache = data
            startPlaying()

        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    // rotate the needle in two direction
    func rotateNeedle(type : Bool,speed : Double) {
        UIView.animateWithDuration(speed, delay: 0, options: UIViewAnimationOptions.CurveLinear,    animations: {
            () -> Void in
            if type == false {
                self.needleImageView?.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI/7))
            }
            else
            {
                self.needleImageView?.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/7))
            }
        }) {(finished) -> Void in
        }
    }

    // set the backgroundImage of the screen
    func setBackgroundImage(imageUrl : String)
    {
        let imageData = NSData(contentsOfURL: NSURL(string: imageUrl)!)
        self.backgroundImageView?.image = UIImage(data: imageData!)
    }
    
    // set anchorPoint of the needleView
    func setAnchorPoint(anchorPoint : CGPoint, forview view : UIView){
        
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    // download the audio online
    func downloadFromYoutube( path : String ){
        
        let defaultConfigObject:NSURLSessionConfiguration =
            NSURLSessionConfiguration.defaultSessionConfiguration();
        let session:NSURLSession = NSURLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: NSOperationQueue.mainQueue());
        let url:NSURL = NSURL(string: path)!;
        
        session.dataTaskWithURL(url, completionHandler: {(data, response, error) in
            
            if (error != nil) {
                KVNProgress.dismiss()
                KVNProgress.showErrorWithStatus("Fail to get data online, check your network")
            }
            // Process the data
            if (data != nil){
                let httpResponse : NSHTTPURLResponse = response as! NSHTTPURLResponse
                //print(httpResponse)
                if httpResponse.MIMEType == "audio/mpeg"
                {
                    self.requestCount = 0
                    self.songCache = data
                    KVNProgress.dismiss()
                    KVNProgress.showSuccess()
                    self.startPlaying()
                }
                else
                {
                    print(self.requestCount)
                    if self.requestCount == 3{
                        self.requestCount = 0
                        KVNProgress.showErrorWithStatus("Fail to convert this video to music, try next")
                        if self.player.audioPlayer != nil{
                            self.player.audioPlayer?.stop()
                            self.player.audioPlayer = nil
                        }
                    }
                    else
                    {
                        self.requestCount = self.requestCount + 1
                        let index = self.onlineSongs.selectedIndex
                        self.downloadFromYoutube((self.onlineSongs.audios[index].audioLink)!)
                    }
                }
            }
            
        }).resume();
    }

    // Get the time format of duration of the song
    func durationToString( time : Int ) -> String
    {
        var result = ""
        let second : Int = time % 60
        let minute : Int = Int( time / 60 )
        if minute<10{
            result = "0\(minute):"
        }else {
            result = "\(minute):"
        }
        if second<10{
            result += "0\(second)"
        }else {
            result += "\(second)"
        }
        return result
    }
    
    // Data has been download, use this to start playing
    func startPlaying()
    {
        do{
            // initialize
            if self.player.audioPlayer != nil{
                self.player.audioPlayer?.stop()
                self.player.audioPlayer = nil
            }
            self.player.audioPlayer = try AVAudioPlayer(data: songCache!)
            self.player.playingMode = PlayingMode.AllRepeat
            //self.player
            self.player.audioPlayer!.delegate = self
            self.player.audioPlayer!.prepareToPlay()
            let duration = self.player.audioPlayer!.duration
            
            // ui synchronize
            self.rotateNeedle(true, speed: 0.5)
            self.albumImageView.startRotating()
            self.totalTimeLabel.text = self.durationToString(Int(duration))
            self.timer?.invalidate()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0,target: self,selector: #selector(PlayController.onUpdate), userInfo: nil, repeats: true)
            self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_pause_normal.png"),
                                               forState: .Normal)
            // start playing
            self.player.audioPlayer?.play()
            self.isPlaying = true
            
        }catch
        {
            KVNProgress.showErrorWithStatus("Fail to initialize player")
        }
    }
    
    // update method of the timer, updating the progressBar and current time label
    func onUpdate()
    {
        self.currentTimeLabel.text = durationToString(Int((self.player.audioPlayer?.currentTime)!))
        let currentTime = Float((self.player.audioPlayer?.currentTime)!)
        let totalTime = Float((self.player.audioPlayer?.duration)!)
        let ratio = currentTime / totalTime
        self.playProgressBar.setProgress(ratio, animated: true)
    }
    
    @IBAction func playModeToggle(sender: AnyObject) {
        
        if self.player.playingMode == PlayingMode.AllRepeat{
            self.player.playingMode = PlayingMode.SingleRepeat
            self.playModeBtn.setBackgroundImage(UIImage(named:"player_btn_repeatone_highlight@2x.png"),
                                                   forState: .Normal)
        }
        else
        {
            self.player.playingMode = PlayingMode.AllRepeat
            self.playModeBtn.setBackgroundImage(UIImage(named:"player_btn_repeat_highlight@2x.png"),
                                                forState: .Normal)
        }
    }
    
    @IBAction func saveToLocal(sender: AnyObject) {
        
        if self.player.playingCategory == PlayingCategory.OnlinePlaying{
            
            let documentPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentPath = documentPaths[0]
            let fileName = self.onlineSongs.audios[self.onlineSongs.selectedIndex].title
            let encodeFileName = fileName?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            
            let filePath = documentPath + "/" + encodeFileName!
            let fileURL = NSURL(fileURLWithPath: filePath)
            print(filePath)
            // save it to the device
            if self.songCache?.writeToFile(fileURL.path!, atomically: true) == true
            {
                // save it to the database
                let entityDesc = NSEntityDescription.entityForName("LocalSong", inManagedObjectContext: managedObjectContext)
                let song = LocalSong(entity: entityDesc!, insertIntoManagedObjectContext: managedObjectContext)
                song.title = self.onlineSongs.audios[self.onlineSongs.selectedIndex].title
                song.imageLink = self.onlineSongs.audios[self.onlineSongs.selectedIndex].imageLink
                song.filePath = filePath
                do{
                    try managedObjectContext.save()
                    self.downLoadBtn.setBackgroundImage(UIImage(named:"player_btn_downloaded_highlight@2x.png"),
                                                        forState: .Normal)
                }catch let error as NSError{
                    print("Save Failed : \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // play and pause control
    @IBAction func playOrPauseClick(sender: AnyObject) {
        
        if self.player.audioPlayer != nil{
            if self.isPlaying == true{
                self.albumImageView.pauseRotating()
                self.rotateNeedle(false, speed: 0.5)
                self.timer?.invalidate()
                self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_play_normal.png"),
                                                       forState: .Normal)
                self.player.audioPlayer?.pause()
                self.isPlaying = false
            }else
            {
                self.albumImageView.resumeRotating()
                self.rotateNeedle(true, speed: 0.5)
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0,target: self,selector: #selector(PlayController.onUpdate), userInfo: nil, repeats: true)
                self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_pause_normal.png"),
                                                       forState: .Normal)
                self.player.audioPlayer?.play()
                self.isPlaying = true
            }

        }
    }
    
    // play previous song
    @IBAction func playPreClick(sender: AnyObject) {
        
        if self.player.playingCategory == PlayingCategory.OnlinePlaying{
            if self.onlineSongs.selectedIndex > 0{
                self.onlineSongs.selectedIndex -= 1
                self.albumImageView.stopRotating()
                self.rotateNeedle(false, speed: 0.5)
                self.playProgressBar.setProgress(0, animated: false)
                if self.player.audioPlayer != nil {
                    self.player.audioPlayer!.stop()
                    self.player.audioPlayer = nil
                }
                self.timer?.invalidate()
                self.timer = nil
                self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_play_normal.png"),
                                                       forState: .Normal)
                startOnlinePlaying()
            }
        }
        else
        {
            if self.localSongs.selectedIndex > 0{
                self.localSongs.selectedIndex -= 1
                self.albumImageView.stopRotating()
                self.rotateNeedle(false, speed: 0.5)
                self.playProgressBar.setProgress(0, animated: false)
                if self.player.audioPlayer != nil {
                    self.player.audioPlayer!.stop()
                    self.player.audioPlayer = nil
                }
                self.timer?.invalidate()
                self.timer = nil
                self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_play_normal.png"),
                                                       forState: .Normal)
                startLocalPlaying()
            }
        }
    }
   
    // play next song
    @IBAction func playNextClick(sender: AnyObject) {
        if self.player.playingCategory == PlayingCategory.OnlinePlaying{
            if self.onlineSongs.selectedIndex < ((self.onlineSongs.audios.count) - 1){
                self.onlineSongs.selectedIndex += 1
                self.albumImageView.stopRotating()
                self.rotateNeedle(false, speed: 0.5)
                self.playProgressBar.setProgress(0, animated: false)
                if self.player.audioPlayer != nil {
                    self.player.audioPlayer!.stop()
                    self.player.audioPlayer = nil
                }
                self.timer?.invalidate()
                self.timer = nil
                self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_play_normal.png"),
                                                   forState: .Normal)
                startOnlinePlaying()
            }
        }
        else
        {
            if self.localSongs.selectedIndex < ((self.localSongs.audios.count) - 1){
                self.localSongs.selectedIndex += 1
                self.albumImageView.stopRotating()
                self.rotateNeedle(false, speed: 0.5)
                self.playProgressBar.setProgress(0, animated: false)
                if self.player.audioPlayer != nil {
                    self.player.audioPlayer!.stop()
                    self.player.audioPlayer = nil
                }
                self.timer?.invalidate()
                self.timer = nil
                self.playOrPauseBtn.setBackgroundImage(UIImage(named:"player_btn_play_normal.png"),
                                                       forState: .Normal)
                startLocalPlaying()
            }

        }
    }
    
    // End playing
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        if self.player.playingMode == PlayingMode.AllRepeat{
            playNextClick(self)
        }
        else{
           self.player.audioPlayer?.play()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

