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
    
    var _managedObjectContext: NSManagedObjectContext? = nil
    var _managedObjectModel: NSManagedObjectModel? = nil
    var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil
    
    static let sharedInstance = CoreDataManager()
    
    func initialize(){
        self.managedObjectContext
    }
    
    //MARK: - Core Data stack
    
    var managedObjectContext: NSManagedObjectContext{
        
        if NSThread.isMainThread() {
            
            if _managedObjectContext == nil {
                let coordinator: NSPersistentStoreCoordinator? = self.persistentStoreCoordinator
                if coordinator != nil {
                    _managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
                    _managedObjectContext!.persistentStoreCoordinator = coordinator
                }
                
                return _managedObjectContext!
            }
            
        }else{
            
            var threadContext : NSManagedObjectContext? = NSThread.currentThread().threadDictionary["NSManagedObjectContext"] as? NSManagedObjectContext;
            
            
            print("\(NSThread.currentThread().threadDictionary)")
            
            if threadContext == nil {
                print("creating new context")
                threadContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                threadContext!.parentContext = _managedObjectContext
                
                NSThread.currentThread().threadDictionary["NSManagedObjectContext"] = threadContext
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"contextWillSave:" , name: NSManagedObjectContextWillSaveNotification, object: threadContext)
                
            }else{
                print("using old context")
            }
            return threadContext!;
        }
        
        return _managedObjectContext!
    }
    
    
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            if let modelURL = NSBundle.mainBundle().URLForResource(kModmName, withExtension: "momd") {
                _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
            }
        }
        return _managedObjectModel!
    }
    
    
    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator == nil {
            let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(kStoreName)
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            do {
                try _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: self.databaseOptions())
            } catch let error as NSError {
                print(error.localizedDescription)
                //abort()
            }
        }
        return _persistentStoreCoordinator!
    }
    
    //MARK: - fetches
    
    func executeFetchRequest(request:NSFetchRequest, context: NSManagedObjectContext)-> Array<AnyObject>?{
        
        var results:Array<AnyObject>?
        context.performBlockAndWait{
            var fetchError:NSError?
            do {
                results = try context.executeFetchRequest(request)
            } catch let error as NSError {
                fetchError = error
                results = nil
            } catch {
                fatalError()
            }
            
            if let error = fetchError {
                print("Warning!! \(error.description)")
            }
        }
        return results
        
    }
    
    
    func executeFetchRequest(request:NSFetchRequest, completionHandler:(results: Array<AnyObject>?) -> Void)-> (){
        
        self.managedObjectContext.performBlock{
            var fetchError:NSError?
            var results:Array<AnyObject>?
            do {
                results = try self.managedObjectContext.executeFetchRequest(request)
            } catch let error as NSError {
                fetchError = error
                results = nil
            } catch {
                fatalError()
            }
            
            if let error = fetchError {
                print("Warning!! \(error.description)")
            }
            
            completionHandler(results: results)
        }
        
    }
    
    //MARK: - save methods
    
    func save() {
        
        let context:NSManagedObjectContext = self.managedObjectContext;
        if context.hasChanges {
            
            context.performBlockAndWait{
                
                var saveError:NSError?
                let saved: Bool
                do {
                    try context.save()
                    saved = true
                } catch let error as NSError {
                    saveError = error
                    saved = false
                } catch {
                    fatalError()
                }
                
                if !saved {
                    if let error = saveError{
                        print("Warning!! Saving error \(error.description)")
                    }
                }
                
                if context.parentContext != nil {
                    
                    context.parentContext?.performBlockAndWait{
                        var saveError:NSError?
                        let saved: Bool
                        do {
                            try context.parentContext?.save()
                            saved = true
                        } catch let error as NSError {
                            saveError = error
                            saved = false
                        } catch {
                            fatalError()
                        }
                        
                        if saved == false{
                            if let error = saveError{
                                print("Warning!! Saving parent error \(error.description)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func contextWillSave(notification:NSNotification){
        
        guard let context = notification.object as? NSManagedObjectContext else {
            print(">> SAVE ERROR")
            return
        }
        
        if context.insertedObjects.count != 0 {
            do {
                try context.obtainPermanentIDsForObjects(Array(context.insertedObjects))
            } catch let error as NSError {
                print("Warning!! obtaining ids error \(error.description)")
            }
        }
    }
    
    
    //MARK: - Utilities
    
    func deleteEntity(object:NSManagedObject)-> () {
        object.managedObjectContext?.deleteObject(object)
    }
    
    func clearAllDataBase()-> () {
        
        for store in self.persistentStoreCoordinator.persistentStores {
            do {
                try self.persistentStoreCoordinator.removePersistentStore(store)
            } catch _ {
            }
            do {
                try NSFileManager.defaultManager().removeItemAtPath(store.URL!.path!)
            } catch _ {
            }
        }
        
        _persistentStoreCoordinator = nil
        _managedObjectModel = nil
        _managedObjectContext = nil
        
        self.persistentStoreCoordinator
    }
    
    
    //MARK: - Application's Documents directory
    
    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1]
    }
    
    
    func databaseOptions() -> [String: AnyObject] {
        var options =  [String: AnyObject]()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        return options
    }
}

