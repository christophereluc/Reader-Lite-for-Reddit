//
//  PageItem.swift
//  Reader Lite for Reddit
//
//  Not stored in core data - since a page's list can change so quickly, it doesn't make sense to cache these
//
//  Created by Christopher Luc on 4/13/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import Foundation

class PageItem {

    var after: String?
    var before: String?
    var children : [Post]
    
    init(pageAfter: String?, pageBefore: String?, childrenData: [Post]?) {
        after = pageAfter
        before = pageBefore
        if let childrenData = childrenData {
            children = childrenData
        }
        else {
            children = [Post]()
        }
    }
    
    func clearChildrenCache() {
        for child in children {
            child.image = nil
        }
    }
}