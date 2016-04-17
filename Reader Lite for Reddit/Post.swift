//
//  Post.swift
//  Reader Lite for Reddit
//
//  Created by Christopher Luc on 4/13/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import Foundation
import UIKit

class Post {
    let redditUrl = "https://www.reddit.com/"
    
    var author: String
    var permalink: String
    var thumbnail: String?
    var title: String
    var url: String
    var id: String
    var domain: String
    var subreddit: String
    
    init(author: String, permalink: String, thumb: String?, title: String, url: String, id: String, domain: String, subreddit: String) {
        self.author = author
        self.permalink = permalink
        if let thumb = thumb {
            thumbnail = thumb
        }
        self.title = title
        self.url = url
        self.id = id
        self.domain = domain
        self.subreddit = subreddit
    }
    
    var is_external: Bool {
        return domain != "self." + subreddit
    }
}