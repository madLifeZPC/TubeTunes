//
//  ViewController.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class RootViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var play_button: UIButton!
    @IBOutlet weak var PlayTableView: UITableView!
    
    @IBOutlet weak var miniPlayerBtn: UIButton!
    var searchPlayList = PlaylistArray()
    //var new_playlist = Playlist
    
    // CoreData context
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // change the style of navigationItem
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let navigationTitleAttribute: NSDictionary = NSDictionary(object: UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
        self.navigationController?.navigationBar.titleTextAttributes = navigationTitleAttribute as! [String : AnyObject]
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 33.0/255.0, green: 136.0/255.0, blue: 104.0/255.0, alpha: 1.0)
        
        let item = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item;
        
        // load all the playList
        loadAllPlayList()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        PlayTableView.delegate = self
        PlayTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false  // delete the space on top of the tableview
        // correct the seperator line
        if PlayTableView.respondsToSelector(Selector("setSeparatorInset:")){
            PlayTableView.separatorInset = UIEdgeInsetsZero
        }
        if PlayTableView.respondsToSelector(Selector("setLayoutMargins:")){
            PlayTableView.layoutMargins = UIEdgeInsetsZero
        }
        let nib = UINib(nibName: "PlaylistCell", bundle: nil)
        self.PlayTableView.registerNib(nib, forCellReuseIdentifier: "PlaylistCell")
        
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
     {
     return cell
     }
     
     public func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
     
     {
     return somearray.count
     
     }*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.PlayTableView.reloadData()
        self.miniPlayerBtn.setBackgroundImage(UIImage(named: "yoMusic_red58*58.png"), forState: .Normal)
        
        if(SingletonPlayer.uniqueAudioPlayer.audioPlayer != nil )
        {
            self.play_button.setBackgroundImage(UIImage(named: "player_btn_pause_normalWhite@2x.png"), forState: .Normal)
            if SingletonPlayer.uniqueAudioPlayer.playingCategory == PlayingCategory.OnlinePlaying{
                self.miniPlayerBtn.setBackgroundImage(UIImage(data: NSData(contentsOfURL: NSURL(string: YoutubeAudioArray.publicOnlinePlayList.audios[YoutubeAudioArray.publicOnlinePlayList.selectedIndex].imageLink!)!)!),forState: .Normal)
            }
            else
            {
                self.miniPlayerBtn.setBackgroundImage(UIImage(data: NSData(contentsOfURL: NSURL(string: LocalAudioArray.publicLocalPlayList.audios[LocalAudioArray.publicLocalPlayList.selectedIndex].imageLink!)!)!), forState: .Normal)
            }
        }
        else{
            self.play_button.setBackgroundImage(UIImage(named: "player_btn_play_normalWhite@2x.png"), forState: .Normal)
        }
        

    }
    
    //Adding a new PlayList
    
    @IBAction func AddNewPlaylist(sender: AnyObject) {
        
        let entityDesc = NSEntityDescription.entityForName("PlayLists", inManagedObjectContext: managedObjectContext)
        let newPlayList = PlayLists(entity: entityDesc!, insertIntoManagedObjectContext: managedObjectContext)
        
        let request = NSFetchRequest()
        request.entity = entityDesc
        var numberOfPlayList = 0
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            print(results.count)
            numberOfPlayList = results.count
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }catch{
            
        }
        let name = "NewPlaylist" + String(numberOfPlayList)
        let desc = "Description"
        newPlayList.name = name
        newPlayList.desc = desc
        
        do{
            try managedObjectContext.save()
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }catch{
            
        }
        
        self.searchPlayList.playlist_audios.append(Playlist(title: name, description: desc))
        self.PlayTableView.reloadData()
        
    }
    
    func loadAllPlayList()
    {
        let entityDesc = NSEntityDescription.entityForName("PlayLists", inManagedObjectContext: managedObjectContext)
        
        let request = NSFetchRequest()
        request.entity = entityDesc
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            var i = 0
            while i < results.count {
                let playlist = Playlist()
                let match = results[i] as! NSManagedObject
                playlist.title = (match.valueForKey("name") as! String)
                playlist.desc = (match.valueForKey("desc") as! String)
                self.searchPlayList.playlist_audios.append(playlist)
                i += 1
            }
        }catch let error as NSError{
            print("Failed : \(error.localizedDescription)")
        }catch{
            
        }

    }
    
    // TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchPlayList.playlist_audios.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell", forIndexPath: indexPath) as! PlaylistCell
        cell.PlayListName!.text = searchPlayList.playlist_audios[indexPath.row].title
        cell.PlayListSubtitle!.text = searchPlayList.playlist_audios[indexPath.row].desc
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
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("hello i am in this function")
        //print(PlayTableView!.indexPathForSelectedRow)
        if let indexPath = self.PlayTableView.indexPathForSelectedRow {
            print(indexPath.row)
            let playlist = searchPlayList.playlist_audios[indexPath.row] as! Playlist
            segue.identifier == "PlayListDisplay"
            let controller = segue.destinationViewController as! PlayListController
            //controller.onlineSongs = sender as? YoutubeAudioArray
            controller.playlists = playlist
            
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.PlayTableView!.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchPlayList.selectedIndex = indexPath.row
        self.performSegueWithIdentifier("PlayListDisplay", sender: self.searchPlayList)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            
            let alertPopUp:UIAlertController = UIAlertController(title:"Confirmation",message: "Are you sure to delete this playlist?",preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirmAction = UIAlertAction(title: "YES", style: .Destructive){
                action -> Void in
                
                
                let selectedTitle = self.searchPlayList.playlist_audios[indexPath.row].title
                let selectedPlayList = self.findPlayList( selectedTitle! )
                
                if selectedPlayList != nil {
                    do {
                        // delete the record from playlist table
                        self.managedObjectContext.deleteObject(selectedPlayList!)
                        
                        // delete the record from playcontent table
                        let entityDesc = NSEntityDescription.entityForName("ListContent", inManagedObjectContext: self.managedObjectContext)
                        let request = NSFetchRequest()
                        request.entity = entityDesc
                        let pred = NSPredicate(format: "(listName = %@)", selectedTitle!)
                        request.predicate = pred
                        
                        do{
                            let results = try self.managedObjectContext.executeFetchRequest(request)
                            var i = 0
                            while( i < results.count ) {
                                let match = results[i] as! NSManagedObject
                                let playListItem =  (match as! ListContent)
                                self.managedObjectContext.deleteObject(playListItem)
                                i = i + 1
                            }
                        }catch let error as NSError{
                            print("Failed : \(error.localizedDescription)")
                        }
                        
                        try self.managedObjectContext.save()
                        
                        // delete the ui cell
                        self.searchPlayList.playlist_audios.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }catch let error as NSError{
                        print("Failed : \(error.localizedDescription)")
                    }catch{
                        
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "NO", style: .Cancel) {action -> Void in}
            alertPopUp.addAction(confirmAction)
            alertPopUp.addAction(cancelAction)
            self.presentViewController(alertPopUp, animated: true, completion: nil)
            
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

    
    @IBAction func goToPlayerPressed(sender: AnyObject) {
        if SingletonPlayer.uniqueAudioPlayer.audioPlayer != nil && SingletonPlayer.uniqueAudioPlayer.playingCategory != nil
        {
            print("Here")
            SingletonPlayer.uniqueAudioPlayer.playEntrance = PlayEntrance.goon
            self.performSegueWithIdentifier("gotoplayer", sender: self)
        }
        else
        {
            //TODO: ALERT NOTHING PLAYING
        }
    }
  
    @IBAction func playPauseButtonPressed(sender: AnyObject) {
        if SingletonPlayer.uniqueAudioPlayer.audioPlayer != nil{
            if SingletonPlayer.uniqueAudioPlayer.audioPlayer?.playing == true{
                SingletonPlayer.uniqueAudioPlayer.audioPlayer?.pause()
                
                play_button.setBackgroundImage(UIImage(named: "player_btn_play_normalWhite@2x.png"), forState: .Normal)
            }
            else
            {
                SingletonPlayer.uniqueAudioPlayer.audioPlayer?.play()
                play_button.setBackgroundImage(UIImage(named: "player_btn_pause_normalWhite@2x.png"), forState: .Normal)
            }
        }
    }
    
    
    
}
