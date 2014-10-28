//
//  KFPodcastSyncService.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit
import CoreData

/*
Parsing XML Example:

https://developer.apple.com/library/ios/samplecode/SeismicXML/Listings/SeismicXML_APLViewController_m.html#//apple_ref/doc/uid/DTS40007323-SeismicXML_APLViewController_m-DontLinkElementID_13
*/

class KAPodcastSyncService: NSObject {
    
    lazy var urlSession: NSURLSession = {
        
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:nil, delegateQueue:nil)
        }()
    // serial delegate queue for NSURLSession completion handler calls to
    // isolate operations on tasks, updates, bookeeping... groups?
    
    // another queue for parsing and saving...
    // use serial queue to mark parse and save steps as done?
    lazy var rssParserQueue: NSOperationQueue = NSOperationQueue()
    
    func dateFromString(string: String?) -> NSDate? {
        if let dateString = string? {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
            return dateFormatter.dateFromString(dateString)
        }
        return nil
    }
    
    func upsertPodcast(channel: KFChannel, managedObjectContext: NSManagedObjectContext) {
        
        
        let fetchRequest = NSFetchRequest(entityName: "Podcast")
        fetchRequest.predicate = NSPredicate(format: "link = %@", channel.link!)
        var error: NSError? = nil
        let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error:&error)
        var podcast: KAPodcast?
        if (fetchResults != nil && fetchResults!.count > 0) {
            podcast = fetchResults!.first as KAPodcast?
        } else {
            podcast = NSEntityDescription.insertNewObjectForEntityForName("Podcast", inManagedObjectContext: managedObjectContext) as KAPodcast?
        }
        
        podcast?.title = channel.title
        podcast?.link = channel.link!
        podcast?.imageUrl = channel.image.url
        
        upsertEpisodes(podcast!, items: channel.items, managedObjectContext: managedObjectContext)
    }
    
    func upsertEpisodes(podcast: KAPodcast, items: [AnyObject], managedObjectContext: NSManagedObjectContext) {
        var episodes = podcast.mutableSetValueForKey("episodes")
        for item in items {
            let itemPredicate = NSPredicate(format: "guid = %@", item.guid!)
            let matches = episodes.filteredSetUsingPredicate(itemPredicate)
            if (matches.count == 0) {
                let episode = NSEntityDescription.insertNewObjectForEntityForName("Episode", inManagedObjectContext: managedObjectContext) as KAEpisode?
                episode?.guid = item.guid!
                episode?.title = item.title
                episode?.link = item.link
                episode?.pubDate = dateFromString(item.pubDate)
                episodes.addObject(episode!)
            }
        }
        
    }
    
    func processFeedXMLData(data: NSData, completion:(channel: KFChannel?, error: NSError!) -> Void) {
        
        let parser = KFFeedParser(data: data)
        
        parser.parse()
        
        if let channel = parser.channel {
            let moc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            moc.parentContext = KACoreDataStack.sharedInstance.managedObjectContext!
            
            moc.performBlockAndWait { () -> Void in
                self.upsertPodcast(channel, managedObjectContext: moc)
                
                var error: NSError? = nil
                
                if !moc.save(&error) {
                    completion(channel: channel, error: error)
                    return;
                }
                
                if let parentContext = moc.parentContext {
                    parentContext.performBlock({ () -> Void in
                        var error: NSError? = nil
                        parentContext.save(&error)
                    })
                }
                
                completion(channel: channel, error: nil)
            }
        } else {
            completion(channel: nil, error: nil)
        }
    }
    
    func refreshFeedWithURLString(feedURLString: String, completion:(channel: KFChannel?, error: NSError!) -> Void) {
        let feedURL = NSURL.URLWithString(feedURLString);
        urlSession.dataTaskWithURL(feedURL, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if (error == nil) {
                // not async... could just return result... and call completion block here... cleaner?
                self.processFeedXMLData(data, completion)
            } else {
                completion(channel: nil, error: error)
            }
        }).resume()
    }
    
}
