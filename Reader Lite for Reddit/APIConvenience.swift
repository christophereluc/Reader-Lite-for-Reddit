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
    
    //Gets users's public data (for first/last name)
    func getSubreddit(subReddit: String?, after: String?, completionHandlerForResult: (data: PageItem?, error: NSError?) -> Void) {
        var parameters = [
            RedditParameterKeys.Count : RedditParameterValues.CountValue
        ]
        
        if let after = after {
            parameters[RedditParameterKeys.After] = after
        }
        
        taskForGETMethod(subReddit, params: parameters) {
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
                                posts.append(Post(author: author, permalink: permalink, thumb: thumbnail, title: title, url: url, id: id, domain: domain, subreddit: subreddit))
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
    
}