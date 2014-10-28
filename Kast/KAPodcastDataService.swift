//
//  KFPodcastDataService.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit
import CoreData

class KAPodcastDataService: NSObject {
   
    class func podcastEpisodesFRC(podcastLink: String, managedObjectContext: NSManagedObjectContext, cacheName: NSString?) -> NSFetchedResultsController {
        var fetchRequest = NSFetchRequest(entityName: "Episode")
        fetchRequest.predicate = NSPredicate(format: "podcast.link = %@", podcastLink)
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "pubDate", ascending: false) ]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: cacheName)
    }
    
    
    class func podcastsFRC(managedObjectContext: NSManagedObjectContext, cacheName: NSString?) -> NSFetchedResultsController {
        var fetchRequest = NSFetchRequest(entityName: "Podcast")
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true) ]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: cacheName)
    }
    
    
}
