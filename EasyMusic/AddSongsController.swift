//
//  AddSongsController.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 10/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import CoreData

class AddSongsController : UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var localSongsTable: UITableView!
    
    var localSongs = [SelectedLocalAudio]()
    
    
    // CoreData context
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SelectedLocalSongList.selectedLocalSongList.songs.removeAll()
        
        // Load local songs
        let entityDesc = NSEntityDescription.entityForName("LocalSong", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request)
            var i = 0
            while( i < results.count ) {
                let song = SelectedLocalAudio()
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
        
        //print(localSongs.count)
        
        
        // configure tableview
        self.localSongsTable.delegate = self
        self.localSongsTable.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false  // delete the space on top of the tableview
        
        // correct the seperator line
        if localSongsTable.respondsToSelector(Selector("setSeparatorInset:")){
            localSongsTable.separatorInset = UIEdgeInsetsZero
        }
        if localSongsTable.respondsToSelector(Selector("setLayoutMargins:")){
            localSongsTable.layoutMargins = UIEdgeInsetsZero
        }
        let nib = UINib(nibName: "AddSongsCell", bundle: nil)
        self.localSongsTable.registerNib(nib, forCellReuseIdentifier: "AddSongsCell")
        
    }
    // TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localSongs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddSongsCell", forIndexPath: indexPath) as! AddSongsCell
        cell.SongName!.text = localSongs[indexPath.row].title
        cell.SongImage!.image = UIImage(data: NSData(contentsOfURL: NSURL(string: localSongs[indexPath.row].imageLink!)!)!)
        if localSongs[indexPath.row].selected == false {
            cell.CheckBox.hidden = true
        }
        else
        {
            cell.CheckBox.hidden = false
        }
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
        
        if self.localSongs[indexPath.row].selected == false {
            self.localSongs[indexPath.row].selected = true
            self.localSongsTable.reloadData()
            SelectedLocalSongList.selectedLocalSongList.songs.append(localSongs[indexPath.row])
        }
        else
        {
            self.localSongs[indexPath.row].selected = false
            self.localSongsTable.reloadData()
            let title = localSongs[indexPath.row].title
            for (index,selectedLocalAudio) in SelectedLocalSongList.selectedLocalSongList.songs.enumerate(){
                if selectedLocalAudio.title == title{
                    SelectedLocalSongList.selectedLocalSongList.songs.removeAtIndex(index)
                    break
                }
            }
        }
        //self.localSongsTable!.deselectRowAtIndexPath(indexPath, animated: true)
        //print(SelectedLocalSongList.selectedLocalSongList.songs.count)
    }

}
