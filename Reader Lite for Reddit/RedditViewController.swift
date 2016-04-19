//
//  ViewController.swift
//  Reader Lite for Reddit
//
//  Created by Christopher Luc on 4/2/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

let closeSafariViewControllerNotification = "closeSafariViewControllerNotification"

class RedditViewController: UIViewController {
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(RedditViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
        
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var login: UIBarButtonItem!
    @IBOutlet weak var messageButton: UIBarButtonItem!
    
    var safariVC: SFSafariViewController?
    var loadingVC: LoadingViewController?

    var data = [PageItem]()
    //Stores the number of posts between all pages
    var total = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLoginButton()
        updateMessageButton()
        tableView.addSubview(refreshControl)
        automaticallyAdjustsScrollViewInsets = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(safariLogin(_:)), name: closeSafariViewControllerNotification, object: nil)
    }
    
    //Utility used to change last item in tableview to loading and starts loading data
    func loadDataAndDisplayIndicator(cell: LoadButtonViewCell) {
        cell.loadText.text = "Loading"
        loadData()
    }
    
    //Function that handles swiping the list view all the way down
    func handleRefresh(refreshControl: UIRefreshControl) {
        if total > 0 {
            clearAllData()
        }
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: total, inSection: 0)) as! LoadButtonViewCell
        loadDataAndDisplayIndicator(cell)
    }
    
    //Loads a page of data from the API
    func loadData() {
        //Send after parameter if we already have a page loaded (get the next page)
        let after = total == 0 ? nil : data.last?.after
        APIClient.sharedInstance().getSubreddit(nil, after: after) {
            data, error in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl.endRefreshing()
                if let data = data {
                    self.refreshControl.enabled = true
                    self.data.append(data)
                    self.total = self.total + data.children.count
                    self.tableView.reloadData()
                }
                else {
                    if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.total, inSection: 0)) as? LoadButtonViewCell! {
                        if self.total == 0 {
                            cell.loadText.text = "Load Data"
                        }
                        else {
                            cell.loadText.text = "Load Next Page"
                        }
                    }
                    let alert = UIAlertController(title: "Error retrieving data", message: "Please try again", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func loginAction(sender: UIBarButtonItem) {
        if sender.title == "Login" {
            let encodedUrl = APIClient.sharedInstance().oAuthUrl
            safariVC = SFSafariViewController(URL: NSURL(string: encodedUrl)!)
            presentViewController(safariVC!, animated: true, completion: nil)
        }
        else {
            APIClient.sharedInstance().revokeAuthorization() {
                dispatch_async(dispatch_get_main_queue()) {
                    self.logout()
                }
            }
        }
    }
    
    func logout() {
        do {
            //We need to clear out all messages
            try self.fetchedResultsController.performFetch()
            for message in self.fetchedResultsController.fetchedObjects as! [Message] {
                self.sharedContext.deleteObject(message)
            }
            CoreDataStackManager.sharedInstance().saveContext()
        } catch {}
        self.clearAllData()
        self.updateMessageButton()
        self.updateLoginButton()
    }
    
    //Clears data and table
    func clearAllData() {
        for item in data {
            item.clearChildrenCache()
        }
        data.removeAll()
        total = 0
        tableView.reloadData()
    }

    //Called on successful login from safari view controller
    func successfulLogin() {
        if let loadingVC = loadingVC {
            loadingVC.dismissViewControllerAnimated(true) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.clearAllData()
                    self.loadingVC = nil
                    self.loadData()
                    self.updateLoginButton()
                    self.updateMessageButton()
                }
            }
        }
    }
    
    //Called when oAuth failed from safari view controller
    func failedLogin() {
        if let loadingVC = loadingVC {
            loadingVC.dismissViewControllerAnimated(true) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadingVC = nil
                    APIClient.sharedInstance().oneTimeCode = nil
                    self.updateLoginButton()
                    self.updateMessageButton()
                    let alert = UIAlertController(title: "Error", message: "Failed logging in", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Displays the loading indicator and tells the apiclient to retrieve token
    func displayLoading() {
        loadingVC = LoadingViewController(message: "Loading...")
        presentViewController(loadingVC!, animated: true) {
            dispatch_async(dispatch_get_main_queue()) {
                APIClient.sharedInstance().retrieveToken() {
                    success in
                    dispatch_async(dispatch_get_main_queue()) {
                        if success && APIClient.sharedInstance().accessToken != nil {
                            self.successfulLogin()
                        }
                        else {
                            self.failedLogin()
                        }
                    }
                }
            }
        }
    }

    func updateLoginButton() {
        if APIClient.sharedInstance().accessToken != nil {
            login.title = "Logout"
        }
        else {
            login.title = "Login"
        }
    }
    
    func updateMessageButton() {
        if APIClient.sharedInstance().accessToken != nil {
            messageButton.enabled = true
        }
        else {
            messageButton.enabled = false
        }
    }
    
}

//SafariViewController jazz 
extension RedditViewController: SFSafariViewControllerDelegate {
    func safariLogin(notification: NSNotification) {
        // get the url form the auth callback
        if let safariVC = safariVC {
            safariVC.dismissViewControllerAnimated(true) {
                self.displayLoading()
            }
        }
    }
    
}

//UITableView stuff
//Such as custom cells and displaying data
extension RedditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //If we selected the loading cell, start loading more data
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
            let svc = SFSafariViewController(URL: NSURL(string: data[page].children[post].url )!)
            presentViewController(svc, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //+1 for the loading cell
        return total + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < total {
            return configureNormalCell(indexPath)
        }
        else {
            return configureLoadDataButton()
        }
    }
    
    func configureNormalCell(indexPath: NSIndexPath) -> UITableViewCell {
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
        
        if let image = postData.image {
            //Image was cached locally
            cell.imageView!.image = image
        }
        else {
           
            //We need to download image
            cell.imageView!.image = UIImage(named: "placeholder")
            if let thumbnail = postData.safeUrl {
                APIClient.sharedInstance().taskForGETImage(thumbnail) {
                    (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            //Now make sure that the cell is still in view (so we don't update wrong cell)
                            if let cellToUpdate = self.tableView.cellForRowAtIndexPath(indexPath) {
                                postData.image = image
                                cellToUpdate.imageView!.image = image
                            }
                        }
                    }
                }
            }
            else {
                postData.image = UIImage(named: "placeholder")
            }
        }
        
        return cell
    }
    
    func configureLoadDataButton() -> LoadButtonViewCell {
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