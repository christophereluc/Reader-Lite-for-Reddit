//
//  ViewController.swift
//  Reader Lite for Reddit
//
//  Created by Christopher Luc on 4/2/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import UIKit

class RedditViewController: UITableViewController{
    
    var data = [PageItem]()
    var total = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(RedditViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)}
    
    func loadDataAndDisplayIndicator(cell: LoadButtonViewCell) {
        cell.loadText.text = "Loading"
        loadData()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if total > 0 {
            data.removeAll()
            total = 0
            tableView.reloadData()
        }
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: total, inSection: 0)) as! LoadButtonViewCell
        cell.loadText.text = "Loading"
        loadData()
    }
    
    func loadData() {
        let after = total == 0 ? nil : data.last?.after
        refreshControl?.endRefreshing()
        
        APIClient.sharedInstance().getSubreddit(nil, after: after) {
            data, error in
            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.enabled = true
                    self.data.append(data)
                    self.total = self.total + data.children.count
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == total {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! LoadButtonViewCell
            loadDataAndDisplayIndicator(cell)
        }
        else {
            var page = 0
            var current = data[0].children.count
            while current <= indexPath.row {
                page = page + 1
                current = current + data[page].children.count
            }
            let post = current - indexPath.row - 1
            UIApplication.sharedApplication().openURL(NSURL(string: data[page].children[post].url )!)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return total + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < total {
            let cell = tableView.dequeueReusableCellWithIdentifier("Post") as UITableViewCell!
            var current = data[0].children.count
            
            var page = 0
            while current <= indexPath.row {
                page = page + 1
                current = current + data[page].children.count
            }
            
            let post = current - indexPath.row - 1
            
            let postData = data[page].children[post]
            cell.textLabel?.text = postData.title
            if postData.is_external {
                cell.detailTextLabel?.text = postData.url
            }
            else {
                cell.detailTextLabel?.text = postData.domain
            }
            if let thumbnail = postData.thumbnail {
                cell.imageView?.image = UIImage(named: thumbnail)
                cell.imageView?.hidden = false
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Load") as! LoadButtonViewCell!
            if total == 0 {
                cell.loadText.text = "Load Data"
            }
            else {
                cell.loadText.text = "Load Next Page"
            }
            return cell
        }
    }
    
}