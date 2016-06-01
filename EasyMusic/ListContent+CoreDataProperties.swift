//
//  ListContent+CoreDataProperties.swift
//  EasyMusic
//
//  Created by Vrinda Gupta on 10/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ListContent {

    @NSManaged var listName: String?
    @NSManaged var songName: String?

}
