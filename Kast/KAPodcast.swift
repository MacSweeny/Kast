//
//  KAPodcast.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import Foundation
import CoreData

@objc(KAPodcast)
class KAPodcast: NSManagedObject {

    @NSManaged var imageUrl: String?
    @NSManaged var link: String
    @NSManaged var title: String?
    @NSManaged var episodes: NSSet

}