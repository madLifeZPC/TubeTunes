//
//  LocalMusicController.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LocalMusicController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet weak var localSongTableView: UITableView!
    
    var localSongs = [LocalAudio]()
    
    // public local playing list
    var publicLocalPlayList = LocalAudioArray.publicLocalPlayList
    
    // CoreData context
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // navigation item
        let item = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item;
        
        // Load local songs
        let entityDesc = NSEntityDescription.entityForName("LocalSong", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            var i = 0
            while( i < results.count ) {
                let song = LocalAudio()
                let match = results[i] as! NSManagedObject
                song.title = (match.valueForKey("title") as! String)
                song.imageLink = (match.valueForKey("imageLink") as! String)
                song.audioAddress = (match.valueForKey("filePath") as! String)
                self.localSongs.append(song)
                i += 1
            }
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }

        
        // configure tableview
        self.localSongTableView.delegate = self
        self.localSongTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false  // delete the space on top of the tableview
        
        // correct the seperator line
        if localSongTableView.respondsToSelector(Selector("setSeparatorInset:")){
            localSongTableView.separatorInset = UIEdgeInsetsZero
        }
        if localSongTableView.respondsToSelector(Selector("setLayoutMargins:")){
            localSongTableView.layoutMargins = UIEdgeInsetsZero
        }
        let nib = UINib(nibName: "MusicCell", bundle: nil)
        self.localSongTableView.registerNib(nib, forCellReuseIdentifier: "MusicCell")
        
    }
    
    @IBAction func playAll(sender: AnyObject) {
        if self.localSongs.isEmpty == false {
            self.publicLocalPlayList.audios.removeAll()
            self.publicLocalPlayList.audios.appendContentsOf(self.localSongs)
            self.publicLocalPlayList.selectedIndex = 0
            SingletonPlayer.uniqueAudioPlayer.playingCategory = PlayingCategory.LocalPlaying
            self.performSegueWithIdentifier("playLocal", sender: self.publicLocalPlayList)

        }
    }
    
    
    // TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicCell", forIndexPath: indexPath) as! MusicCell
        cell.songName!.text = localSongs[indexPath.row].title
        cell.songImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: localSongs[indexPath.row].imageLink!)!)!)
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector(Selector("setLayoutMargins:")){
            cell.layoutMargins = UIEdgeInsetsZero
        }
        if cell.respondsToSelector(Selector("setSeparatorInset:")){
            cell.separatorInset = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.localSongTableView!.deselectRowAtIndexPath(indexPath, animated: true)
        self.publicLocalPlayList.audios.removeAll()
        self.publicLocalPlayList.audios.append(self.localSongs[indexPath.row])
        self.publicLocalPlayList.selectedIndex = 0
        SingletonPlayer.uniqueAudioPlayer.playingCategory = PlayingCategory.LocalPlaying
        self.performSegueWithIdentifier("playLocal", sender: self.publicLocalPlayList)
    }
    
    // delete song
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let alertPopUp:UIAlertController = UIAlertController(title:"Warning",message: "Are you sure to delete this song from your device?",preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirmAction = UIAlertAction(title: "YES", style: .Cancel){
                action -> Void in
                
                let selectedTitle = self.localSongs[indexPath.row].title
                let selectedSong = self.findSong( selectedTitle! )
                if selectedSong != nil {
                    do {
                        // delete the audio file
                        let fileManager = NSFileManager.defaultManager()
                        try fileManager.removeItemAtPath((selectedSong?.filePath)!)
                        // delete the audio record
                        self.managedObjectContext.deleteObject(selectedSong!)
                        try self.managedObjectContext.save()
                        // delete the audio cache
                        self.localSongs.removeAtIndex(indexPath.row)
                        // delete the audio ui cell
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }catch let error as NSError{
                        print("Failed : \(error.localizedDescription)")
                    }
                }

            }
            
            let cancelAction = UIAlertAction(title: "NO", style: .Cancel) {action -> Void in}
            alertPopUp.addAction(confirmAction)
            alertPopUp.addAction(cancelAction)
            self.presentViewController(alertPopUp, animated: true, completion: nil)
        }
    }
    
    // find song
    func findSong( title : String ) -> LocalSong? {
        
        let entityDesc = NSEntityDescription.entityForName("LocalSong", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        let pred = NSPredicate(format: "(title = %@)", title)
        request.predicate = pred
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            if( results.count > 0 ) {
                let match = results[0] as! NSManagedObject
                return (match as! LocalSong)
            }
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}