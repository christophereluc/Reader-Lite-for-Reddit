//
//  Message.swift
//  Reader Lite for Reddit
//
//  Created by Christopher Luc on 4/18/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import Foundation
import CoreData


class Message: NSManagedObject {
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(author: String, message: String, time: Double, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Message", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.author = author
        self.message = message
        self.time = time
    }
    
}
