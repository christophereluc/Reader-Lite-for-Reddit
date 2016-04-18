//
//  Post.swift
//  Reader Lite for Reddit
//
//  Not stored in core data - since a page's list can change so quickly, it doesn't make sense to cache these
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
    
    var safeUrl : String? {
        if let _ = thumbnail?.rangeOfString("http") {
            return thumbnail
        }
        return nil
    }
    
    var image : UIImage? {
        get {
            return APIClient.Caches.imageCache.imageWithIdentifier(id)
        }
        set {
            APIClient.Caches.imageCache.storeImage(newValue, withIdentifier: id)
        }
    }
}