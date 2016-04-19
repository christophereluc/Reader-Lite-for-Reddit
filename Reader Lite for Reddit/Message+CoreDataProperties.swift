//
//  Message+CoreDataProperties.swift
//  Reader Lite for Reddit
//
//  Created by Christopher Luc on 4/18/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var author: String?
    @NSManaged var message: String?
    @NSManaged var time: NSNumber?

}
