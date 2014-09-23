//
//  CoreDataManager.swift
//  CoreDataManager Example
//
//  Created by Manuel de la Mata on 13/06/2014.
//  Copyright (c) 2014 MMS. All rights reserved.
//

import Foundation
import CoreData


class CoreDataManager: NSObject {
    
    let kStoreName = "TNTCache.sqlite"
    let kModmName = "CoreDataManager_Example"

    
    var _managedObjectContext: NSManagedObjectContext?
    var _managedObjectModel: NSManagedObjectModel?
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    
    
    class var shared:CoreDataManager{
        get {
            struct Static {
                static var instance : CoreDataManager? = nil
                static var token : dispatch_once_t = 0
            }
            dispatch_once(&Static.token) { Static.instance = CoreDataManager() }
            
            return Static.instance!
        }
    }
    
    
    /**
    Initializes CoreData Manager. Basically, creates the first NSManagedObjectContext
    
    :param: style The style of the bicycle
    :param: gearing The gearing of the bicycle
    :param: handlebar The handlebar of the bicycle
    :param: centimeters The frame size of the bicycle, in centimeters
    
    :returns: nothing.
    */

    func initialize(){
        self.managedObjectContext
    }
    
    // MARK: Core Data stack
    
    var managedObjectContext: NSManagedObjectContext{
    
        if NSThread.isMainThread() {
            
            if (_managedObjectContext == nil) {
                if let coordinator = self.persistentStoreCoordinator  {
                    _managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
                    _managedObjectContext!.persistentStoreCoordinator = coordinator
                }
                
                return _managedObjectContext!
            }
            
        }else{
            
            var threadContext : NSManagedObjectContext? = NSThread.currentThread().threadDictionary!["NSManagedObjectContext"] as? NSManagedObjectContext;
            
            println(NSThread.currentThread().threadDictionary)
            
            if threadContext == nil {
                                println("creating new context")
                threadContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                threadContext!.parentContext = _managedObjectContext
                threadContext!.name = NSThread.currentThread().description
                
                NSThread.currentThread().threadDictionary!["NSManagedObjectContext"] = threadContext
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"contextWillSave:" , name: NSManagedObjectContextWillSaveNotification, object: threadContext)
                
            }else{
                println("using old context")
            }
            return threadContext!;
        }
            
        return _managedObjectContext!
    }
    
    
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
    if _managedObjectModel == nil {
        let modelURL = NSBundle.mainBundle().URLForResource(kModmName, withExtension: "momd")
        _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        return _managedObjectModel!
    }
  
    
    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
    if _persistentStoreCoordinator == nil {
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(kStoreName)
        var error: NSError? = nil
        _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: self.databaseOptions(), error: &error) == nil {

            abort()
        }
        }
        return _persistentStoreCoordinator!
    }
    

    
    // MARK: fetches
    
    func executeFetchRequest(request:NSFetchRequest)-> Array<AnyObject>?{

        var results:Array<AnyObject>?
        self.managedObjectContext.performBlockAndWait{
            var fetchError:NSError?
            results = self.managedObjectContext.executeFetchRequest(request, error: &fetchError)
            
            if let error = fetchError {
                println("Warning!! \(error.description)")
            }
        }
        return results
        
    }

    
    func executeFetchRequest(request:NSFetchRequest, completionHandler:(results: Array<AnyObject>?) -> Void)-> (){
        
        self.managedObjectContext.performBlock{
            var fetchError:NSError?
            var results:Array<AnyObject>?
             results = self.managedObjectContext.executeFetchRequest(request, error: &fetchError)
            
            if let error = fetchError {
                println("Warning!! \(error.description)")
            }
    
            completionHandler(results: results)
        }
        
    }


    
    // #pragma mark - save methods
    
    func save() {
        
        var context:NSManagedObjectContext = self.managedObjectContext;
        if context.hasChanges {
            
            context.performBlockAndWait{
                
                var saveError:NSError?
                let saved = context.save(&saveError)
                
                if !saved {
                    if let error = saveError{
                        println("Warning!! Saving error \(error.description)")
                    }
                }
                
                if context.parentContext != nil {
                    
                    context.parentContext!.performBlockAndWait{
                        var saveError:NSError?
                        let saved = context.parentContext!.save(&saveError)
                        
                        if !saved{
                            if let error = saveError{
                                println("Warning!! Saving parent error \(error.description)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    func contextWillSave(notification:NSNotification){
        
        let context : NSManagedObjectContext! = notification.object as NSManagedObjectContext
        var insertedObjects : NSSet = context.insertedObjects
        
        if insertedObjects.count != 0 {
            var obtainError:NSError?

            context.obtainPermanentIDsForObjects(insertedObjects.allObjects, error: &obtainError)
            if let error = obtainError {
                println("Warning!! obtaining ids error \(error.description)")
            }
        }
        
    }
    
    
    // #pragma mark - Utilities


    func deleteEntity(object:NSManagedObject)-> () {
        object.managedObjectContext .deleteObject(object)
    }



    // #pragma mark - Application's Documents directory

    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as NSURL
    }
    
    
    func databaseOptions() -> Dictionary <String,Bool> {
        var options =  Dictionary<String,Bool>()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        return options
    }
  

    
}

