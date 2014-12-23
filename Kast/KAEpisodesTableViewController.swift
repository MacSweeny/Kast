//
//  KAEpisodesTableViewController.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit
import CoreData

class KAEpisodesTableViewController: UITableViewController {

    var podcastLink: String?
    var frc: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "KAEpisodeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "EpisodeTableViewCellIdentifier")
        
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let podcastLinkUrl = podcastLink? {
            frc = KAPodcastDataService.podcastEpisodesFRC(podcastLinkUrl, managedObjectContext: KACoreDataStack.sharedInstance.managedObjectContext!, cacheName: "EpisodesTableViewController")
            var error: NSError?
            frc?.performFetch(&error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchedObjects = frc?.fetchedObjects {
            return fetchedObjects.count
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EpisodeTableViewCellIdentifier", forIndexPath: indexPath) as KAEpisodeTableViewCell
        
        let episode = frc?.objectAtIndexPath(indexPath) as KAEpisode?
        
        cell.titleLabel?.text = episode?.title
        if let episodeDate = episode?.pubDate? {
            cell.dateLabel?.text = NSDateFormatter.localizedStringFromDate(episodeDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let episode = frc?.objectAtIndexPath(indexPath) as KAEpisode?
        
        if let guid = episode?.guid {
            if let podcastLink = episode?.podcast.link {
                let episodeController = KAEpisodeTableViewController(guid: guid, podcastLink: podcastLink);
                navigationController?.pushViewController(episodeController, animated: true)
            }
        }
    }
    
}

