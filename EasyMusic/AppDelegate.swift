//
//  AppDelegate.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,NSURLSessionDataDelegate, GIDSignInDelegate, AVAudioPlayerDelegate{

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSThread.sleepForTimeInterval(1)
        // Override point for customization after application launch.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        
        
        let youtubeScope : String = "https://www.googleapis.com/auth/youtube.readonly";
        let currentScopes: NSArray = GIDSignIn.sharedInstance().scopes;
        GIDSignIn.sharedInstance().scopes = currentScopes.arrayByAddingObject(youtubeScope)
        // Override point for customization after application launch.
        return true
    }

    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        var options: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!,
                                            UIApplicationOpenURLOptionsAnnotationKey: annotation]
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let accesstoken = user.authentication.accessToken
            
            // Access the storyboard and fetch an instance of the view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: ChannelListViewController = storyboard.instantiateViewControllerWithIdentifier("ChannelListViewController") as! ChannelListViewController
            viewController.accesstoken = accesstoken
            viewController.getData()
            // Then push that view controller onto the navigation stack
            let rootViewController = self.window!.rootViewController as! UINavigationController
            rootViewController.pushViewController(viewController, animated: true)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        print("resign active")
        let session = AVAudioSession.sharedInstance()
        do
        {
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            self.becomeFirstResponder()

        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("enter background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        print("enter foreground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("become active")
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    // remote control received event
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event != nil
        {
            if event?.type == UIEventType.RemoteControl{
                
                let uniquePlayer = SingletonPlayer.uniqueAudioPlayer
                if ( SingletonPlayer.uniqueAudioPlayer.playingCategory == PlayingCategory.OnlinePlaying)
                {
                    switch event?.subtype {
                    case UIEventSubtype.RemoteControlPlay?:
                        if uniquePlayer.audioPlayer!.playing == false{
                            uniquePlayer.audioPlayer!.play()
                        }
                    case UIEventSubtype.RemoteControlPause?:
                        if uniquePlayer.audioPlayer!.playing == true{
                            uniquePlayer.audioPlayer!.pause()
                        }
                    default:
                        break
                    }
                }
                else
                {
                    switch event?.subtype {
                    case UIEventSubtype.RemoteControlPlay?:
                        if uniquePlayer.audioPlayer!.playing == false{
                            uniquePlayer.audioPlayer!.play()
                        }
                    case UIEventSubtype.RemoteControlPause?:
                        if uniquePlayer.audioPlayer!.playing == true{
                            uniquePlayer.audioPlayer!.pause()
                        }
                        
                    case UIEventSubtype.RemoteControlNextTrack?:
                        playNextSong()
                    case UIEventSubtype.RemoteControlPreviousTrack?:
                        playPreSong()
                    default:
                        break
                    }

                }
            }
            
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("will terminate")
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("LocalMusicCoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    // End playing
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        if SingletonPlayer.uniqueAudioPlayer.playingMode == PlayingMode.AllRepeat{
            playNextSong()
        }
        else{
            SingletonPlayer.uniqueAudioPlayer.audioPlayer?.play()
        }
    }
    
    func playNextSong()
    {
        
        if LocalAudioArray.publicLocalPlayList.selectedIndex < LocalAudioArray.publicLocalPlayList.audios.count - 1{
            LocalAudioArray.publicLocalPlayList.selectedIndex += 1
            SingletonPlayer.uniqueAudioPlayer.audioPlayer!.stop()
            SingletonPlayer.uniqueAudioPlayer.audioPlayer = nil
            let audioAddress = LocalAudioArray.publicLocalPlayList.audios[LocalAudioArray.publicLocalPlayList.selectedIndex].audioAddress
            let fileURL : NSURL = NSURL(fileURLWithPath: audioAddress!)
            do {
                let data = try NSData(contentsOfFile: fileURL.path!,options: .DataReadingMappedIfSafe)
                SingletonPlayer.uniqueAudioPlayer.songCache = data
                SingletonPlayer.uniqueAudioPlayer.audioPlayer = try AVAudioPlayer(data: SingletonPlayer.uniqueAudioPlayer.songCache!)
                SingletonPlayer.uniqueAudioPlayer.audioPlayer?.delegate = self
                SingletonPlayer.uniqueAudioPlayer.playingMode = PlayingMode.AllRepeat
                //self.player
                SingletonPlayer.uniqueAudioPlayer.audioPlayer!.prepareToPlay()
                SingletonPlayer.uniqueAudioPlayer.audioPlayer!.play()
                
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }

    }
    
    func playPreSong()
    {
        if LocalAudioArray.publicLocalPlayList.selectedIndex > 0{
            LocalAudioArray.publicLocalPlayList.selectedIndex -= 1
            SingletonPlayer.uniqueAudioPlayer.audioPlayer!.stop()
            SingletonPlayer.uniqueAudioPlayer.audioPlayer = nil
            let audioAddress = LocalAudioArray.publicLocalPlayList.audios[LocalAudioArray.publicLocalPlayList.selectedIndex].audioAddress
            let fileURL : NSURL = NSURL(fileURLWithPath: audioAddress!)
            do {
                let data = try NSData(contentsOfFile: fileURL.path!,options: .DataReadingMappedIfSafe)
                SingletonPlayer.uniqueAudioPlayer.songCache = data
                SingletonPlayer.uniqueAudioPlayer.audioPlayer = try AVAudioPlayer(data: SingletonPlayer.uniqueAudioPlayer.songCache!)
                SingletonPlayer.uniqueAudioPlayer.audioPlayer?.delegate = self
                SingletonPlayer.uniqueAudioPlayer.playingMode = PlayingMode.AllRepeat
                //self.player
                SingletonPlayer.uniqueAudioPlayer.audioPlayer!.prepareToPlay()
                SingletonPlayer.uniqueAudioPlayer.audioPlayer!.play()
                
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }

    }
    func application (application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return checkOrientation(self.window?.rootViewController)
    }
    
    func checkOrientation (viewController: UIViewController?) -> UIInterfaceOrientationMask {
        if viewController == nil {
            return UIInterfaceOrientationMask.Portrait
            
        } else if viewController is PlayController {
            return UIInterfaceOrientationMask.Portrait
            
        }
            
        else {
            return checkOrientation(viewController!.presentedViewController)
        }
    }

}

