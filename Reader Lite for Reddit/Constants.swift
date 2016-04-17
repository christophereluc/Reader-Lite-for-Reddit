//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Christopher Luc on 4/10/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import Foundation

extension APIClient {
    
        struct Constants {
            static let APIScheme = "https"
            static let APIHost = "www.reddit.com"
            static let APIPath = "/"
            static let APIReturnType = ".json"

        }
        
        struct RedditParameterKeys {
            static let Count = "count"
            static let Before = "before"
            static let After = "after"
        }
        
        struct RedditParameterValues {
            static let CountValue = "10"
        }
        
        struct RedditResponseKeys {
            static let Data = "data"
            static let Before = "before"
            static let After = "after"
            static let Children = "children"
            static let Author = "author"
            static let Permalink = "permalink"
            static let Thumbnail = "thumbnail"
            static let Title = "title"
            static let Url = "url"
            static let Id = "id"
            static let Domain = "domain"
            static let Subreddit = "subreddit"
        }
    
        struct RedditResponseValues {
        }
}