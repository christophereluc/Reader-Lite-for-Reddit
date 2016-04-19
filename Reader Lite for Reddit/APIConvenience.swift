//
//  This project makes me have a very deep hatred for reddit now :(
//
//  APIConvenience.swift
//  Virtual Tourist
//
//  Created by Christopher Luc on 4/10/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import Foundation
import CoreData

extension APIClient {
    
    
    // MARK: GET Convenience Methods
    
    //Gets a subreddit (or front page if none passed in)
    func getSubreddit(subReddit: String?, after: String?, completionHandlerForResult: (data: PageItem?, error: NSError?) -> Void) {
        var parameters = [
            RedditParameterKeys.Count : RedditParameterValues.CountValue
        ]
        
        if let after = after {
            parameters[RedditParameterKeys.After] = after
        }
        
        taskForGETMethod(subReddit, params: parameters, useApiMethod: false) {
            (result, error) in
            if let error = error {
                completionHandlerForResult(data: nil, error: error)
            }
            else if let data = result[RedditResponseKeys.Data] as? [String : NSObject] {
                let before = data[RedditResponseKeys.Before] as! String?
                let after = data[RedditResponseKeys.After] as! String?
                
                var posts = [Post]()
                
                if let children = data[RedditResponseKeys.Children] as? [[String: NSObject]] {
                    for childData in children {
                        if let child = childData[RedditResponseKeys.Data] as? [String:NSObject] {
                            if let author = child[RedditResponseKeys.Author] as? String, permalink = child[RedditResponseKeys.Permalink] as? String, title = child[RedditResponseKeys.Title] as? String, url = child[RedditResponseKeys.Url] as? String, id = child[RedditResponseKeys.Id] as? String, domain = child[RedditResponseKeys.Domain] as? String, subreddit = child[RedditResponseKeys.Subreddit] as? String {
                                //Thumbnail is optional
                                let thumbnail = child[RedditResponseKeys.Thumbnail] as! String?
                                posts.insert(Post(author: author, permalink: permalink, thumb: thumbnail, title: title, url: url, id: id, domain: domain, subreddit: subreddit), atIndex: 0)
                            }
                        }
                    }
                }
                
                let pageItem = PageItem(pageAfter: after, pageBefore: before, childrenData: posts)
                
                completionHandlerForResult(data: pageItem, error: nil)
                
            }
            else {
                completionHandlerForResult(data: nil, error: error)
            }
        }
    }
    
    //retrieves authorization token
    func retrieveToken(resultForCompletionHandler: (success: Bool) -> Void) {
        let parameters = [String:String]()
        
        if let oneTimeCode = oneTimeCode {
            //It must be formatted like this.  Reddit wants some funky ass formatting...no joke :(
            let jsonBody = "\(RedditParameterKeys.Code)=\(oneTimeCode)&\(RedditParameterKeys.GrantType)=\(RedditParameterValues.GrantTypeValue)&\(RedditParameterKeys.Redirect)=\(RedditParameterValues.RedirectValue)"
            taskForPOSTMethod(Methods.AccessToken, params: parameters, jsonBody: jsonBody.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) {
                result, error in
                if let result = result {
                    if let accesstoken = result[RedditResponseKeys.AccessToken] as? String? {
                        let sharedPref = NSUserDefaults.standardUserDefaults()
                        sharedPref.setValue(accesstoken, forKey: "token")
                        self.accessToken = accesstoken
                        resultForCompletionHandler(success: true)
                        self.getAllMessages(nil)
                        return
                    }
                }
                resultForCompletionHandler(success: false)
            }
            self.oneTimeCode = nil
        }
        else {
            resultForCompletionHandler(success: false)
        }
    }
    
    //Revokes authorization token
    func revokeAuthorization(completionHandler: () -> Void ) {      
        let parameters = [String:String]()
        
        if let accessToken = accessToken {
            //It must be formatted like this.  Reddit wants some funky ass formatting...no joke :(
            let jsonBody = "\(RedditParameterKeys.Token)=\(accessToken)"
            taskForPOSTMethod(Methods.Revoke, params: parameters, jsonBody: jsonBody.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) {
                result, error in
                let sharedPref = NSUserDefaults.standardUserDefaults()
                sharedPref.setValue(nil, forKey: "token")
                self.accessToken = nil
                completionHandler()
            }
        }
    }
    
    func getAllMessages(completionHandler: (()->Void)? ) {
        let params = [String:String]()
        if let _ = accessToken {
            taskForGETMethod(Methods.Messages, params: params, useApiMethod: false) {
                result, error in
                
                if let result = result {
                    self.sharedContext.performBlockAndWait({
                        if let data = result[RedditResponseKeys.Data] as? [String:NSObject] {
                            if let children = data[RedditResponseKeys.Children] as? [[String:NSObject]] {
                                for child in children {
                                    if let childData = child[RedditResponseKeys.Data] as? [String:NSObject] {
                                        if let message = childData[RedditResponseKeys.Body] as? String, author = childData[RedditResponseKeys.Author] as? String, time = childData[RedditResponseKeys.CreatedUtc] as? Double {
                                            _ = Message(author: author, message: message, time: time, context: self.sharedContext)
                                        }
                                    }
                                }
                                
                                do {
                                    try self.sharedContext.save()
                                } catch {}
                            }
                        }
                        
                    })
                    if completionHandler != nil {
                        completionHandler!()
                    }
                }
                
            }
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}