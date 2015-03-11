//
//  KAPodcastDownloadService.swift
//  Kast
//
//  Created by Andy Sweeny on 12/19/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit
import CoreData

// singleton
// add to list
// URLSessionBased, concurrent delegate queue
// dataSource for reporting!?!? for 'listeners'
// do bookeeping on serial private queue
// failed stay in 'list'...
// notifications when states change?

private let _sharedInstance = KAPodcastDownloadService()

class KAPodcastDownloadService: NSObject, NSURLSessionDownloadDelegate {
    
    class var sharedInstance : KAPodcastDownloadService {
        return _sharedInstance
    }
    
    var tasks = [String: NSURLSessionDownloadTask]()
    var lockQueue: dispatch_queue_t = {
        return dispatch_queue_create("com.misoapps.kast.KAPodcastDownloadService", nil)
    }()
    
    lazy var urlSession: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("KAPodcastDownloadService"), delegate:self, delegateQueue:nil)
//        return NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(), delegate:self, delegateQueue:nil)
        }()

    func downloadEpisode(episodeID: String, podcastID: String, urlString: String) {
        dispatch_sync(lockQueue, { () -> Void in
            // create task
            let task = self.urlSession.downloadTaskWithURL(NSURL(string: urlString)!)
            // add to list
            self.tasks[episodeID] = task
            // do bookeeping on episode
            self.updateEpisodeDownloadStatus(episodeID, downloadStatus: .Downloading, episodeMediaURL: nil)
            // resume
            task.resume()
        })
    }
    
    func updateEpisodeDownloadStatus(episodeID: String, downloadStatus: KAMediaDownloadStatus, episodeMediaURL: NSURL?) {
        let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        moc.parentContext = KACoreDataStack.sharedInstance.managedObjectContext
        
        moc.performBlockAndWait { () -> Void in
            
            let fetchRequest = NSFetchRequest(entityName: "Episode")
            fetchRequest.predicate = NSPredicate(format: "episodeID = %@", episodeID)
            
            var error: NSError? = nil
            if let fetchResults = moc.executeFetchRequest(fetchRequest, error:&error) {
                if let episode = fetchResults.first as KAEpisode? {
                    episode.mediaDownloadStatus = downloadStatus
                    
                    if let episodeMediaURLString = episodeMediaURL?.path {
                        episode.downloadURLString = episodeMediaURLString
                    }
                    
                    var error: NSError? = nil
                    
                    if !moc.save(&error) {
                        return;
                    }
                    
                    if let parentContext = moc.parentContext {
                        parentContext.performBlock({ () -> Void in
                            var error: NSError? = nil
                            parentContext.save(&error)
                        })
                    }
                }
            }
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        for (episodeID, task) in self.tasks {
            if downloadTask == task {
                // move file
                let fileManager = NSFileManager()
                
                let episodeMediaLocation = self.episodeMediaDirectoryURL(fileManager).URLByAppendingPathComponent(NSUUID().UUIDString);
                
                var moveItemErrorPointer: NSErrorPointer = nil
                
                fileManager.moveItemAtURL(location, toURL: episodeMediaLocation, error: moveItemErrorPointer)
                
                var setResourceValueErrorPointer: NSErrorPointer = nil
            
                episodeMediaLocation.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey, error: setResourceValueErrorPointer)
                
                dispatch_sync(
                    lockQueue, { () -> Void in
                        // update episode details
                        self.updateEpisodeDownloadStatus(episodeID, downloadStatus: KAMediaDownloadStatus.Complete, episodeMediaURL: episodeMediaLocation)
                })
                break
            }
        }
    }
   
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        NSLog("error")
    }
    
    func URLSession(session: NSURLSession,
        downloadTask: NSURLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64) {
            println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
    }

    func episodeMediaDirectoryURL(fileManager: NSFileManager) -> NSURL {
        let libraryDirectoryURL = fileManager.URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask).first! as NSURL
        
        return libraryDirectoryURL.URLByAppendingPathComponent("Episode Media")
    }
    
}
