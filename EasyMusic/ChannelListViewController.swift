//
//  ChannelListViewController.swift
//  EasyMusic
//
//  Created by Selvaraju Vignesh on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class ChannelListViewController: UITableViewController, NSURLSessionDelegate {
    var accesstoken: String!
    var youtubechannellist : NSMutableArray! = NSMutableArray()
    var playlistview: PlaylistViewController! = PlaylistViewController()
    var selectedChannel : YoutubeChannels?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "MusicCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "MusicCell")
        tableView.reloadData()        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func getData()
    {
        var buffer: NSMutableData = NSMutableData();
        let url: NSURL = NSURL(string: "https://www.googleapis.com/youtube/v3/channels?part=snippet&maxResults=50&mine=true&access_token=\(accesstoken)")!
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

        var chtitle: String?
        var imglink: String?
        youtubechannellist.removeAllObjects()
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
                        let channel: YoutubeChannels = YoutubeChannels(channelID: itemDic["id"] as! String, channelTitle: chtitle as String!, channelImage: imglink!)
                        youtubechannellist.addObject(channel)
                        //print(youtubechannellist[0].channelLink)
                    }
                }
            }
            tableView.reloadData()
        }
        //print(jsonObject)
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return youtubechannellist.count;
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicCell", forIndexPath: indexPath) as! MusicCell
        
        //let cell = UITableViewCell()
        let channel = youtubechannellist[indexPath.row] as! YoutubeChannels
        //cell.textLabel!.text = channel.channelTitle
        cell.songName.text = channel.channelTitle
        cell.songImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: channel.channelImage!)!)!)
        //cell.imageView = UIImage(data: NSData(contentsOfURL: NSURL(string: channel.channelImage!)!)!)
        return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playlistSegue"
        {
            print(selectedChannel?.channelLink)
            let destvc = segue.destinationViewController as! PlaylistViewController
            destvc.channel = selectedChannel
            destvc.accesstoken = accesstoken
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedChannel = youtubechannellist[indexPath.row] as! YoutubeChannels
        
        self.performSegueWithIdentifier("playlistSegue", sender: self)
        
    }
    
  
    


}
