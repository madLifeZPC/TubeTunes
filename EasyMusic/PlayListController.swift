//
//  PlayListController.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 9/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlayListController: UIViewController, UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var PlayListName: UITextField!
    @IBOutlet weak var PlayListDesc: UITextField!
    @IBOutlet weak var songsTable: UITableView!
    
    var playlists : Playlist!
    var currentPlayList : PlayLists?
    var localSongs = [LocalAudio]()
    
    // CoreData context
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load song list
        SelectedLocalSongList.selectedLocalSongList.songs.removeAll()
        let selectedTitle = playlists.title
        currentPlayList = self.findPlayList( selectedTitle! )
        print(currentPlayList?.name)
        loadCurrentList()
        
        // configure tableview
        self.songsTable.delegate = self
        self.songsTable.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false  // delete the space on top of the tableview
        
        // correct the seperator line
        if songsTable.respondsToSelector(Selector("setSeparatorInset:")){
            songsTable.separatorInset = UIEdgeInsetsZero
        }
        if songsTable.respondsToSelector(Selector("setLayoutMargins:")){
            songsTable.layoutMargins = UIEdgeInsetsZero
        }
        let nib = UINib(nibName: "MusicCell", bundle: nil)
        self.songsTable.registerNib(nib, forCellReuseIdentifier: "MusicCell")
        
    }
    
    func loadCurrentList()
    {
        let entityDesc = NSEntityDescription.entityForName("ListContent", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        let pred = NSPredicate(format: "(listName = %@)", (self.currentPlayList?.name)!)
        request.predicate = pred


        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            var i = 0
            while i < results.count{
                let match = results[i] as! NSManagedObject
                let songName = (match.valueForKey("songName") as! String)
                let song = findSong(songName)
                self.localSongs.append(LocalAudio(title: (song?.title!)!, imageLink: (song?.imageLink!)!, audioAddress: (song?.filePath!)!))
                i = i + 1
            }
            
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }catch{
            
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        PlayListName.text = playlists.title
        PlayListDesc.text = playlists.desc
        
        for selectedLocalAudio in SelectedLocalSongList.selectedLocalSongList.songs{
            var exist = false
            for localAudio in self.localSongs{
                if selectedLocalAudio.title == localAudio.title {
                    exist = true
                    break
                }
            }
            if exist == false{
                if self.insertListContent( selectedLocalAudio ) == true {
                    
                    self.localSongs.append(LocalAudio(title: selectedLocalAudio.title!, imageLink: selectedLocalAudio.imageLink!, audioAddress: selectedLocalAudio.audioAddress!))
                }
            }
        }
        
        self.songsTable.reloadData()
    }
    
    func insertListContent(seletedLocalAudio : SelectedLocalAudio) -> Bool {
        
        
        let entityDesc = NSEntityDescription.entityForName("ListContent", inManagedObjectContext: managedObjectContext)
        let newPlayListItem = ListContent(entity: entityDesc!, insertIntoManagedObjectContext: managedObjectContext)
        newPlayListItem.listName = self.currentPlayList?.name
        newPlayListItem.songName = seletedLocalAudio.title
        
        do{
            try managedObjectContext.save()
            return true
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }catch{
            
        }
        return false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        playlists.title = PlayListName.text!
        playlists.desc = PlayListDesc.text!
        
        // save it to the database
        if currentPlayList != nil {
            do {
                
                let entityDesc = NSEntityDescription.entityForName("ListContent", inManagedObjectContext: managedObjectContext)
                let request = NSFetchRequest()
                request.entity = entityDesc
                let pred = NSPredicate(format: "(listName = %@)", (self.currentPlayList?.name)!)
                request.predicate = pred
                
                
                do{
                    let results = try managedObjectContext.executeFetchRequest(request)
                    var i = 0
                    while i < results.count{
                        let match = results[i] as! NSManagedObject
                        let listContent = match as! ListContent
                        listContent.listName = PlayListName.text
                        try managedObjectContext.save()
                        i = i + 1
                    }
                    
                }catch let error as NSError{
                    print("Failed : \(error.localizedDescription)")
                }catch{
                    
                }

                currentPlayList?.name = PlayListName.text
                currentPlayList?.desc = PlayListDesc.text
                try managedObjectContext.save()
            }catch let error as NSError{
                print("Failed : \(error.localizedDescription)")
            }catch{
                
            }
        }
        
    }
    
    
    // find playList
    func findPlayList( title : String ) -> PlayLists? {
        
        let entityDesc = NSEntityDescription.entityForName("PlayLists", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        let pred = NSPredicate(format: "(name = %@)", title)
        request.predicate = pred
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            if( results.count > 0 ) {
                let match = results[0] as! NSManagedObject
                return (match as! PlayLists)
            }
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }
        catch{
            
        }
        return nil
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
    
    func findListItem( listName : String, songName : String ) -> ListContent? {
        let entityDesc = NSEntityDescription.entityForName("ListContent", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        let pred = NSPredicate(format: "(listName = %@ && songName = %@)", listName,songName )
        request.predicate = pred
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            if( results.count > 0 ) {
                let match = results[0] as! NSManagedObject
                return (match as! ListContent)
            }
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }
        return nil
    }
    
    @IBAction func PlayAll(sender: AnyObject) {
        if self.localSongs.isEmpty == false {
            LocalAudioArray.publicLocalPlayList.audios.removeAll()
            LocalAudioArray.publicLocalPlayList.audios.appendContentsOf(self.localSongs)
            LocalAudioArray.publicLocalPlayList.selectedIndex = 0
            SingletonPlayer.uniqueAudioPlayer.playingCategory = PlayingCategory.LocalPlaying
            self.performSegueWithIdentifier("playByList", sender: self)
            
        }
    }
    
    @IBAction func addSongs(sender: AnyObject) {
        self.performSegueWithIdentifier("addSongs", sender: self)
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
        cell.songName.text = localSongs[indexPath.row].title
        cell.songImage!.image = UIImage(data: NSData(contentsOfURL: NSURL(string: localSongs[indexPath.row].imageLink!)!)!)
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
        self.songsTable!.deselectRowAtIndexPath(indexPath, animated: true)
        LocalAudioArray.publicLocalPlayList.audios.removeAll()
        LocalAudioArray.publicLocalPlayList.audios.append(self.localSongs[indexPath.row])
        LocalAudioArray.publicLocalPlayList.selectedIndex = 0
        SingletonPlayer.uniqueAudioPlayer.playingCategory = PlayingCategory.LocalPlaying
        self.performSegueWithIdentifier("playByList", sender: self)
    }
    
    // delete song
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let alertPopUp:UIAlertController = UIAlertController(title:"Confirmation",message: "Are you sure to delete this song from your playlist?",preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirmAction = UIAlertAction(title: "YES", style: .Destructive){
                action -> Void in
                
                let selectedTitle = self.localSongs[indexPath.row].title
                let selectedListItem = self.findListItem( (self.currentPlayList?.name)! ,songName: selectedTitle! )
                if selectedListItem != nil {
                    do {
                        // delete the audio record
                        self.managedObjectContext.deleteObject(selectedListItem!)
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

    

}