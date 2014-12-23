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

class KAPodcastSyncService: NSObject, NSURLSessionTaskDelegate {
    
    lazy var urlSession: NSURLSession = {
        
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:self, delegateQueue:nil)
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
        var podcast: KAPodcast
        if (fetchResults != nil && fetchResults!.count > 0) {
            podcast = fetchResults!.first as KAPodcast
        } else {
            podcast = NSEntityDescription.insertNewObjectForEntityForName("Podcast", inManagedObjectContext: managedObjectContext) as KAPodcast
        }
        
        podcast.title = channel.title
        podcast.link = channel.link!
        podcast.imageUrl = channel.image.url
        
        upsertEpisodes(podcast, items: channel.items as [KFItem], managedObjectContext: managedObjectContext)
    }
    
    func upsertEpisodes(podcast: KAPodcast, items: [KFItem], managedObjectContext: NSManagedObjectContext) {
        var episodes = podcast.mutableSetValueForKey("episodes")
        for item in items {
            if let itemPredicate = NSPredicate(format: "guid = %@", item.guid!) {
                let matches = episodes.filteredSetUsingPredicate(itemPredicate)
                if (matches.count == 0) {
                    let episode = NSEntityDescription.insertNewObjectForEntityForName("Episode", inManagedObjectContext: managedObjectContext) as KAEpisode
                    episode.guid = item.guid!
                    episode.title = item.title
                    episode.link = item.link
                    episode.pubDate = dateFromString(item.pubDate)
                    if let episodeMedia = item.enclosure {
                        episode.mediaType = episodeMedia.type
                        episode.mediaURLString = episodeMedia.urlString
                    }
                    episodes.addObject(episode)
                }
            }
        }
        
    }
    
    func processFeedXMLData(data: NSData, completion:(channel: KFChannel?, error: NSError!) -> Void) {
        
        let parser = KFFeedParser(data: data)
        
        processFeedXMLWithParser(parser, completion: completion)
    }
    
    func processFeedXMLWithParser(parser: KFFeedParser, completion:(channel: KFChannel?, error: NSError!) -> Void) {
        
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
    
    let refreshSerialQueue = dispatch_queue_create("KAPodcastSyncService.RefreshQueue", DISPATCH_QUEUE_SERIAL)
    
    func refreshFeedsWithURLs(feedURLStrings: [String], completion:() -> Void) {
        
        dispatch_async(refreshSerialQueue, { () -> Void in
            let group_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let group = dispatch_group_create()
            
            for feedURLString in feedURLStrings {
                dispatch_group_async(group, group_queue, { () -> Void in
                    if let feedURL = NSURL(string: feedURLString) {
                        let parser = KFFeedParser(URL: feedURL)
                        self.processFeedXMLWithParser(parser, completion: { (channel, error) -> Void in
                            if (channel != nil) {
                                NSLog("Refresh success: %@", feedURLString)
                            } else {
                                NSLog("Failed refresh: %@", feedURLString)
                            }
                        })
                    }
                })
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), { completion() })
        })
    }
    
    /* Previous attempts */
    
    func refreshFeedWithURLString(feedURLString: String, completion:(channel: KFChannel?, error: NSError!) -> Void) {
        if let feedURL = NSURL(string: feedURLString) {
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
    
    var taskDictionary = [Int: NSURLSessionTask]()
    var tasks = [NSURLSessionTask]()
    var completionBlock: (() -> Void)?
    
    var feedUrlDictionary = [String: NSURL]()
    
    func OLDrefreshFeedsWithURLs(feedURLStrings: [String], completion:() -> Void) {
        
        completionBlock = completion
        
        for feedURLString in feedURLStrings {
            if let feedURL = NSURL(string: feedURLString) {
                
                feedUrlDictionary[feedURLString] = feedURL
                
                let task = urlSession.dataTaskWithURL(feedURL, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                    if (error == nil) {
                        self.processFeedXMLData(data, completion: {(channel, error) -> Void in })
                    } else {
                    }
                    
                    self.feedUrlDictionary.removeValueForKey(feedURLString)
                    if self.feedUrlDictionary.isEmpty {
                        self.completionBlock!()
                    }
                })
                tasks.append(task)
                taskDictionary[task.taskIdentifier] = task
            }
        }
        
        for task in tasks {
            task.resume()
        }
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        taskDictionary.removeValueForKey(task.taskIdentifier)
        if taskDictionary.isEmpty {
            completionBlock!()
        }
    }
    
}
