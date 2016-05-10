//
//  PlaylistViewController.swift
//  EasyMusic
//
//  Created by Selvaraju Vignesh on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class PlaylistViewController: UITableViewController, NSURLSessionDelegate {

    var accesstoken: String!
    var channel: YoutubeChannels?
    var playlistarray: NSMutableArray = NSMutableArray()
    var selectedPlaylist: YoutubePlaylist?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "MusicCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "MusicCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        getData()
        //print(channel!.channelTitle)
        
        
    }
    
    func getData()
    {
        var buffer: NSMutableData = NSMutableData();
        let url: NSURL = NSURL(string: "https://www.googleapis.com/youtube/v3/playlists?part=snippet&maxResults=50&mine=true&access_token=\(accesstoken)")!
        // Continue your implementation to send the search request
        // to Google. Remember to do the callback methods!
        let defaultConfigObject: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        let req: NSMutableURLRequest = NSMutableURLRequest(URL: url);
        
        
        let session: NSURLSession = NSURLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        
        
        session.dataTaskWithURL(url, completionHandler: {(data, response, error) in
            
            if (error != nil) {
                print("Error %@",error!.userInfo);
                print("Error description %@", error!.localizedDescription);
                print("Error domain %@", error!.domain);
            }
            // Process the data
            if (data != nil){
                
                self.processResponse(data!)
            }
            
        }).resume();

        

    }
    
    func processResponse(data:NSData) {
        var imglink: String?
        var chtitle: String?
        playlistarray.removeAllObjects()
        let jsonObject : AnyObject! = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        if let jsonDictionary = jsonObject as? NSDictionary{
            if let dataItems = jsonDictionary["items"] as? NSArray{
                
                for item in dataItems{
                    //print(item)
                    
                    
                    
                    if let itemDic = item as? NSDictionary{
                        //print(itemDic["title"])
                        if let snipdic =  itemDic["snippet"] as? NSDictionary{
                            chtitle = snipdic["title"] as! String
                            if let thumbdic = snipdic["thumbnails"] as? NSDictionary{
                                if let def = thumbdic["default"] as? NSDictionary {
                                    imglink=def["url"] as? String
                                }
                            }
                        }
                        let plist: YoutubePlaylist = YoutubePlaylist(listID: itemDic["id"] as! String, listtitle: chtitle as String!, playlistImage: imglink!)
                        playlistarray.addObject(plist)
                        //print(youtubechannellist[0].channelLink)
                    }
                }
            }
            tableView.reloadData()
        }

     
        }
    

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return playlistarray.count;
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        let plist = playlistarray[indexPath.row] as! YoutubePlaylist
        //cell.textLabel!.text = plist.playlistTitle
        //return cell
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicCell", forIndexPath: indexPath) as! MusicCell
        
        //let cell = UITableViewCell()
        //let channel = [indexPath.row] as! YoutubeChannels
        //cell.textLabel!.text = channel.channelTitle
        cell.songName.text = plist.playlistTitle
        cell.songImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: plist.playlistImage!)!)!)
        //cell.imageView = UIImage(data: NSData(contentsOfURL: NSURL(string: channel.channelImage!)!)!)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playlistItemSegue"
        {
            //print(selectedChannel?.channelLink)
            let destvc = segue.destinationViewController as! PlaylistitemViewController
            destvc.playlist = selectedPlaylist
            destvc.accesstoken = accesstoken
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedPlaylist =  playlistarray[indexPath.row] as! YoutubePlaylist
        
        self.performSegueWithIdentifier("playlistItemSegue", sender: self)
        
    }
}
