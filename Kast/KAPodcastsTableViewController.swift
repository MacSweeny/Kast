//
//  KAPodcastsTableViewController.swift
//  Kast
//
//  Created by Andy Sweeny on 10/22/14.
//  Copyright (c) 2014 Miso Apps. All rights reserved.
//

import UIKit
import CoreData

class KAPodcastsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate {

    private var collapseDetailViewController = true
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var newPodcastModalViewController: UINavigationController? = nil
    let podcastSyncService = KAPodcastSyncService()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let moc = KACoreDataStack.sharedInstance.managedObjectContext!
        let frc = KAPodcastDataService.podcastsFRC(moc, cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    override func viewDidLoad() {
        
        self.tableView.registerNib(UINib(nibName: "KAPodcastTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "PodcastTableViewCellIdentifier")
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: "refreshPodcasts:", forControlEvents: UIControlEvents.ValueChanged)
        
        //        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let newButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "enterNewPodcast:")
        self.navigationItem.leftBarButtonItem = newButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptNewPodcast:")
        self.navigationItem.rightBarButtonItem = addButton
        
        var error: NSError? = nil
        if !self.fetchedResultsController.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        super.viewDidLoad()

        splitViewController?.delegate = self
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshPodcasts(sender: AnyObject) {
        /*
        var feedURLs = [String]()
        for object in fetchedResultsController.fetchedObjects! as [NSManagedObject] {
            feedURLs.append(object.valueForKey("link") as String )
        }
        */
        
        let feedURLs = [ "http://dameshek.libsyn.com/rss", "http://www.npr.org/rss/rss.php?id=1033", "http://norm.videopodcastnetwork.libsynpro.com/rss" ];

        self.podcastSyncService.refreshFeedsWithURLs(feedURLs, completion: { () -> Void in
            if let refreshControl = self.refreshControl {
                refreshControl.endRefreshing()
            }
        })
    }
    
    func enterNewPodcast(sender: AnyObject) {
        
//        let enterNewPodcastNavigationController = UINavigationController(rootViewController: AddPodcastViewController())
//        
//        enterNewPodcastNavigationController.modalPresentationStyle = .FormSheet
//        
//        presentViewController(enterNewPodcastNavigationController, animated: true, completion: nil)

    }

    
    func promptNewPodcast(sender: AnyObject) {
        var alertController = UIAlertController(title: "Add a Podcast", message: "To add a podcast enter the URL", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "Shek", style: .Default, handler: { (action) -> Void in
            self.newPodcast("http://dameshek.libsyn.com/rss")
        }))
        
        alertController.addAction(UIAlertAction(title: "NPR", style: .Default, handler: { (action) -> Void in
            self.newPodcast("http://www.npr.org/rss/rss.php?id=1033")
        }))
        
        alertController.addAction(UIAlertAction(title: "Norm MacDonald", style: .Default, handler: { (action) -> Void in
            self.newPodcast("http://norm.videopodcastnetwork.libsynpro.com/rss")
        }))
        
        alertController.modalPresentationStyle = .Popover
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem
            popoverPresentationController.sourceView = self.view
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    func newPodcast(urlString: String) {
        
        self.podcastSyncService.refreshFeedWithURLString(urlString, completion: { (channel, error) -> Void in
            //
        })
        
        //        let newPodcastModalViewController = NewPodcastViewController()
        //        newPodcastModalViewController.delegate = self
        //
        //        self.newPodcastModalViewController = UINavigationController(rootViewController: newPodcastModalViewController)
        //        self.newPodcastModalViewController!.modalPresentationStyle = .FormSheet
        //        self.presentViewController(self.newPodcastModalViewController!, animated: true, completion: nil);
    }
    
    func viewControllerDidDismiss() {
        self.newPodcastModalViewController?.dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PodcastTableViewCellIdentifier", forIndexPath: indexPath) as KAPodcastTableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
            
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        collapseDetailViewController = false
        
        let podcast = self.fetchedResultsController.objectAtIndexPath(indexPath) as KAPodcast
        let controller = KAEpisodesTableViewController()
        controller.podcastLink = podcast.valueForKey("link") as String?
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
        
        self.showDetailViewController(UINavigationController(rootViewController: controller), sender: self)
    }
    
    func configureCell(cell: KAPodcastTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        cell.titleLabel?.text = object.valueForKey("title")!.description
    }
    
    // MARK: - Split view controller delegate
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return collapseDetailViewController
    }
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath)! as KAPodcastTableViewCell, atIndexPath: indexPath)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
    
}