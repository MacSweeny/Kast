//
//  KAEpisode.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import Foundation
import CoreData

enum KAMediaDownloadStatus: NSNumber {
    case Missing = 0
    case Downloading = 1
    case Paused = 2
    case Complete = 3
}

@objc(KAEpisode)
class KAEpisode: NSManagedObject {

    @NSManaged var downloadURLString: String?
    @NSManaged var episodeID: String
    @NSManaged var guid: String
    @NSManaged var link: String?
    @NSManaged var mediaType: String?
    @NSManaged var mediaURLString: String?
    @NSManaged var mediaDownloadStatusNumber: NSNumber
    @NSManaged var pubDate: NSDate?
    @NSManaged var title: String?
    @NSManaged var podcast: KAPodcast

    var mediaDownloadStatus: KAMediaDownloadStatus {
        get {
            return KAMediaDownloadStatus(rawValue: mediaDownloadStatusNumber)!
        }
        set {
            mediaDownloadStatusNumber = newValue.rawValue
        }
    }
    
}
