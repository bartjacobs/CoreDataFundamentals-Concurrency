//
//  CoreDataManager.swift
//  Core Data
//
//  Created by Bart Jacobs on 03/01/16.
//  Copyright © 2016 Bart Jacobs. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {

    // MARK - Initialization

    override init() {
        super.init()

        // Setup Notification Handling
        self.setupNotificationHandling()
    }

    // MARK: - Core Data stack
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bartjacobs.Core_Data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Notes", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Notes.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)

        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

        // Configure Managed Object Context
        managedObjectContext.parentContext = self.privateManagedObjectContext

        return managedObjectContext
    }()
    
    // MARK - Helper Methods

    func saveContext () {
        guard managedObjectContext.hasChanges else { return }

        do {
            // Write Changes to Persistent Store
            try managedObjectContext.save()

        } catch {
            let saveError = error as NSError
            print("Unable to Save Managed Object Context")
            print("\(saveError), \(saveError.localizedDescription)")
        }
    }

    private func setupNotificationHandling() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "savePrivateManagedObjectContext:", name: UIApplicationWillTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: "savePrivateManagedObjectContext:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }

    // MARK - Notification Handling

    func savePrivateManagedObjectContext(notification: NSNotification) {
        guard privateManagedObjectContext.hasChanges else { return }

        do {
            // Write Changes to Persistent Store
            try privateManagedObjectContext.save()

        } catch {
            let saveError = error as NSError
            print("Unable to Save Managed Object Context")
            print("\(saveError), \(saveError.localizedDescription)")
        }
    }

}
