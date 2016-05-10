//
//  LocalSong+CoreDataProperties.swift
//  EasyMusic
//
//  Created by madlife on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension LocalSong {

    @NSManaged var filePath: String?
    @NSManaged var imageLink: String?
    @NSManaged var title: String?
    @NSManaged var localSong_playList: NSSet?

}
