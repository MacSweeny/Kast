//
//  KAPodcastDownloadService.swift
//  Kast
//
//  Created by Andy Sweeny on 12/19/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit

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
    
    lazy var urlSession: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("KAPodcastDownloadService"), delegate:self, delegateQueue:nil)
        }()

    func downloadEpisode(podcastLink: String, guid: String) {
        // create task
        // add to list
        // do bookeeping on episode
        // resume
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        // move file
        // remove task
        // mark downloaded
    }
}
