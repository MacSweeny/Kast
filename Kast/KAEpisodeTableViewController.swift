//
//  KAEpisodeTableViewController.swift
//  Kast
//
//  Created by Andy Sweeny on 12/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit
import CoreData

class KAEpisodeTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var guid: String
    var podcastLink: String
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let moc = KACoreDataStack.sharedInstance.managedObjectContext!
        let frc = KAPodcastDataService.podcastEpisodesFRC(self.guid, podcastLink: self.podcastLink, managedObjectContext: moc, cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    init(guid aGuid: String, podcastLink aPodcastLink: String) {
        guid = aGuid
        podcastLink = aPodcastLink
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        var error: NSError? = nil
        
        if !self.fetchedResultsController.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        let episode = fetchedResultsController.fetchedObjects!.first as KAEpisode

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = episode.guid
        case 1:
            cell.textLabel?.text = "Play"
        case 2:
            cell.textLabel?.text = "Mark as Favorite"
        case 3:
            switch episode.mediaDownloadStatus {
            case .Missing:
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.textLabel?.text = "Download"
            case .Downloading:
                cell.textLabel?.textColor = UIColor.greenColor()
                cell.textLabel?.text = "Downloading..."
            case .Paused:
                cell.textLabel?.textColor = UIColor.orangeColor()
                cell.textLabel?.text = "Paused..."
            case .Complete:
                cell.textLabel?.textColor = UIColor.redColor()
                cell.textLabel?.text = "Delete Download"
            }
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            // download
            if let episode = fetchedResultsController.fetchedObjects?.first as KAEpisode? {
                if let urlString = episode.mediaURLString {
                    KAPodcastDownloadService.sharedInstance.downloadEpisode(episode.episodeID, podcastID: episode.podcast.podcastID, urlString: urlString)
                }
            }
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }

}
