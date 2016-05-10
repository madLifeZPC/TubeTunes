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
    
    @IBOutlet weak var PlayTableView: UITableView!
    
    var searchPlayList = PlaylistArray()
    //var new_playlist = Playlist
    
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
    }
    
    //Adding a new PlayList
    
    @IBAction func AddNewPlaylist(sender: AnyObject) {
        self.searchPlayList.playlist_audios.append(Playlist(title: "NewPlaylist", description: "Description"))
        self.PlayTableView.reloadData()
        
        
        
        
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
            searchPlayList.playlist_audios.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    
    
    
}
