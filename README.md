CoreDataManager-Swift
=====================

Swift CoreDataManager for multithreading environments


Multithreading in CoreData
------------
This Swift CoreData Manager can handle multi-threading. You can access to CoreData entities from different threads or GCD dispatches closures without problems.


How to use it? 
------------

As simple as copying the file `CoreDataManager.swift`. into your project.


This manager uses the singleton pattern in order to be able of handle different NSManagedObjectContexts per thread automatically.

Methods? 
------------
#### Fetch Methods

- `executeFetchRequest(request:)`: 

Fetches results synchronously

        var request: NSFetchRequest = NSFetchRequest(entityName: "MonkeyEntity")
        
        var myMonkeys:NSArray? = CoreDataManager.shared.executeFetchRequest(request)


- `executeFetchRequest(request:, completionHandler:)`: 

Fetches with a completionHandler that returns an array with results asynchronously.

        var myMonkeys:NSArray?
        var request: NSFetchRequest = NSFetchRequest(entityName: "MonkeyEntity")
        
        CoreDataManager.shared.executeFetchRequest(request) { results in
            myMonkeys = results!
        }


       
#### Save Method

- `save()`: 

Saves the context, it doesn't matters the thread.

        CoreDataManager.shared.save()

### Delete Method

- `deleteEntity(object:)`: 

Deletes the NSManagedObject sent

        CoreDataManager.shared.deleteEntity(item as MonkeyEntity)


Tests
------------
Tests are provided to check the performance under a stress case.
