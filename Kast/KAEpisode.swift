//
//  KAEpisode.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import Foundation
import CoreData

@objc(KAEpisode)
class KAEpisode: NSManagedObject {

    @NSManaged var guid: String
    @NSManaged var link: String?
    @NSManaged var pubDate: NSDate?
    @NSManaged var title: String?
    @NSManaged var podcast: KAPodcast

}
