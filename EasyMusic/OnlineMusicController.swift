//
//  OnlineMusicController.swift
//  EasyMusic
//
//  Created by madlife on 1/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import Foundation
import UIKit

class OnlineMusicController: UIViewController,NSURLSessionDataDelegate,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var resultTableView: UITableView!
    var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 250, 30))
    
    var searchResults = YoutubeAudioArray.publicOnlinePlayList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the navigationItem
        searchBar.placeholder = "Search in youtube.com"
        searchBar.delegate = self
        let searchView = UIView(frame: CGRectMake(0, 0, 250, 30))
        searchView.addSubview(searchBar)
        searchView.layer.masksToBounds = true
        searchView.layer.cornerRadius = 3
        self.navigationItem.titleView = searchView
        
        // Do any additional setup after loading the view, typically from a nib.
        resultTableView.delegate = self
        resultTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false  // delete the space on top of the tableview
        // correct the seperator line 
        if resultTableView.respondsToSelector(Selector("setSeparatorInset:")){
            resultTableView.separatorInset = UIEdgeInsetsZero
        }
        if resultTableView.respondsToSelector(Selector("setLayoutMargins:")){
            resultTableView.layoutMargins = UIEdgeInsetsZero
        }
        let nib = UINib(nibName: "MusicCell", bundle: nil)
        self.resultTableView.registerNib(nib, forCellReuseIdentifier: "MusicCell")
    }

    // searchBar
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        let key:String = "AIzaSyBBrATaOXuGZ0YokP3ffOK6m_XsDsld3T4"
        
        let defaultConfigObject:NSURLSessionConfiguration =
            NSURLSessionConfiguration.defaultSessionConfiguration();
        let session:NSURLSession = NSURLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: NSOperationQueue.mainQueue());
        
        let urlAsString:String = String(format: "https://www.googleapis.com/youtube/v3/search?key=\(key)&part=snippet&maxResults=50&q=%@",searchBar.text!);
        let encodeUrl = urlAsString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let sessionUrl:NSURL = NSURL(string: encodeUrl!)!;
        session.dataTaskWithURL(sessionUrl, completionHandler: {(data, response, error) in
            
            if (error != nil) {
                print("Error %@",error!.userInfo);
                print("Error description %@", error!.localizedDescription);
                print("Error domain %@", error!.domain);
            }
            // Process the data
            if (data != nil){
                self.processResponse(data!);
                self.searchBar.resignFirstResponder()
            }
            
        }).resume();
    }

    func processResponse(data:NSData)
    {
        self.searchResults.audios.removeAll()
        
        let jsonObject : AnyObject! = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        
        if let jsonDictionary = jsonObject as? NSDictionary{
            if let dataItems = jsonDictionary["items"] as? NSArray{
                for item in dataItems{
                    
                    var title:String?
                    var desc:String?
                    var imageLink:String?
                    var videoLink:String?
                    var audioLink:String?
                    
                    if let id = item["id"] as? NSDictionary{
                        if id["videoId"] != nil{
                            if let videoId = id["videoId"] as? String{
                                videoLink = "https://www.youtube.com/watch?v=" +  videoId
                                audioLink = "http://serve01.mp3skull.onl/get?id=" + videoId
                            }
                        }
                        else
                        {
                            continue
                        }
                    }
                    
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
                    }
                    
                    self.searchResults.audios.append(YoutubeAudio(title: title!, desc: desc!, videoLink: videoLink!, imageLink: imageLink!, audioLink: audioLink!))
                }
            }
            self.resultTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.audios.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MusicCell", forIndexPath: indexPath) as! MusicCell
        cell.songName!.text = searchResults.audios[indexPath.row].title
        cell.songImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: searchResults.audios[indexPath.row].imageLink!)!)!)
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
        self.resultTableView!.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchResults.selectedIndex = indexPath.row
        SingletonPlayer.uniqueAudioPlayer.playingCategory = PlayingCategory.OnlinePlaying
        self.performSegueWithIdentifier("playOnline", sender: self.searchResults)
    }
}
