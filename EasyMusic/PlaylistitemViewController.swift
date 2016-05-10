//
//  PlaylistitemViewController.swift
//  EasyMusic
//
//  Created by Selvaraju Vignesh on 9/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class PlaylistitemViewController: UITableViewController, NSURLSessionDelegate {

    var accesstoken: String!
    var playlist: YoutubePlaylist?
    var youtubeaudio: NSMutableArray = NSMutableArray()
    var searchResults = YoutubeAudioArray.publicOnlinePlayList
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "MusicCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "MusicCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(animated: Bool) {
        //print(playlist?.playlistTitle)
        //print(accesstoken)
        super.viewWillAppear(true)
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Playlist Item View Controller
    
    func getData()
    {
        var buffer: NSMutableData = NSMutableData();
        let url: NSURL = NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(playlist!.playlistID! as String)&access_token=\(accesstoken as String)")!
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
        var tscDes: String?
        searchResults.audios.removeAll()
        youtubeaudio.removeAllObjects()
        let jsonObject : AnyObject! = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        if let jsonDictionary = jsonObject as? NSDictionary{
            if let dataItems = jsonDictionary["items"] as? NSArray{
                
                for item in dataItems{
                    //print(item)
                    var title:String?
                    var desc:String?
                    var imageLink:String?
                    var videoLink:String?
                    var audioLink:String?
                    
                    
                    if let snippet = item["snippet"] as? NSDictionary{
                        
                        if let itemTitle = snippet["title"] as? String{
                            title = itemTitle
                        }
                        if let itemDesc = snippet["description"] as? String{
                            desc = itemDesc
                        }
                        if let thumbnails = snippet["thumbnails"] as? NSDictionary{
                            if let defaultImage = thumbnails["default"] as? NSDictionary{
                                if let defaultImageUrl = defaultImage["url"] as? String{
                                    imageLink = defaultImageUrl
                                }
                            }
                        }
                        if let resource = snippet["resourceId"] as? NSDictionary{
                            if let vidId = resource["videoId"] as? String{
                                videoLink="www.youtube.com/watch?v=" +  vidId
                                audioLink = "http://serve01.mp3skull.onl/get?id=" + vidId
                            }
                        
                        }
                        }
                    
                    self.youtubeaudio.addObject(YoutubeAudio(title: title!, desc: desc!, videoLink: videoLink!, imageLink: imageLink!, audioLink: audioLink!))
                    self.searchResults.audios.append(YoutubeAudio(title: title!, desc: desc!, videoLink: videoLink!, imageLink: imageLink!,audioLink: audioLink!))
                }
            }
            tableView.reloadData()
        }
        
        
    }



    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return youtubeaudio.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        let plist = youtubeaudio[indexPath.row] as! YoutubeAudio
        //cell.textLabel!.text = plist.title
        //return cell
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicCell", forIndexPath: indexPath) as! MusicCell
        
        //let cell = UITableViewCell()
       // let channel = youtubechannellist[indexPath.row] as! YoutubeChannels
        //cell.textLabel!.text = channel.channelTitle
        cell.songName.text = plist.title
        cell.songImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: plist.imageLink!)!)!)
        //cell.imageView = UIImage(data: NSData(contentsOfURL: NSURL(string: channel.channelImage!)!)!)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //self.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchResults.selectedIndex = indexPath.row
        SingletonPlayer.uniqueAudioPlayer.playingCategory = PlayingCategory.OnlinePlaying
        self.performSegueWithIdentifier("playOnline", sender: self.searchResults)
        
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
