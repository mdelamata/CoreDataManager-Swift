//
//  ViewController.swift
//  CoreDataManager Example
//
//  Created by Manuel de la Mata on 13/06/2014.
//  Copyright (c) 2014 MMS. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    

    @IBOutlet var tableView : UITableView
    @IBOutlet var actionButton : UIBarButtonItem
    @IBOutlet var editButton : UIBarButtonItem
    
    var datasource : Array<AnyObject> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        refreshData()
        
    }
    
    
    // pragma mark # - methods
    
    func configureTableView(){
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    func refreshData(){
        
        var request: NSFetchRequest = NSFetchRequest(entityName: "MonkeyEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "name" , ascending: true)]
        
        CoreDataManager.shared.executeFetchRequest(request) { results in
            self.datasource = results!
            self.tableView.reloadData()
        }
        
    }
    
    func clearEntities(){
        
        for item : AnyObject in datasource {
            CoreDataManager.shared.deleteEntity(item as MonkeyEntity)
        }
        self.datasource = []
        
        self.tableView.reloadData()
    }


    
    // pragma mark # - TableView Delegate methods
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        var monkey = self.datasource[indexPath.row] as MonkeyEntity
        cell.textLabel.text = monkey.name
        
        return cell
    }
    
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        var monkey = self.datasource[indexPath.row] as MonkeyEntity
        monkey.name = NSString(format:"Monkey %.002d", indexPath.row)
        
        var alert: UIAlertController = UIAlertController(title: "monkey says", message: "aaaaggg agggg agggg", preferredStyle: .Alert)
        var bananaOption = UIAlertAction(title: "Give banana", style: .Cancel) { action  in
            monkey.name = "\(monkey.name) is grateful"
            self.tableView.reloadData()
            alert.dismissModalViewControllerAnimated(true)
        }
        var neverOption = UIAlertAction(title: "Never!", style: .Destructive) { action  in
            monkey.name = "\(monkey.name) is angry"
            self.tableView.reloadData()
            alert.dismissModalViewControllerAnimated(true)
        }
        alert.addAction(bananaOption)
        alert.addAction(neverOption)

        
        self.presentViewController(alert, animated:true, nil)
    }
    

    
    // pragma mark # IBAction methods

    @IBAction func actionButtonPressed(sender : AnyObject) {
        
        var newMonkey: MonkeyEntity = NSEntityDescription.insertNewObjectForEntityForName("MonkeyEntity", inManagedObjectContext: CoreDataManager.shared.managedObjectContext) as MonkeyEntity
        
        newMonkey.name = NSString(format:"Monkey %.002d", self.datasource.count)
        println("Inserted New Monkey...")
        
        refreshData()
    }
    
    
    @IBAction func editButtonPressed(sender : AnyObject) {
        
        var alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        var saveOption = UIAlertAction(title: "Save", style: .Default) { action  in
            CoreDataManager.shared.save()
            alert.dismissModalViewControllerAnimated(true)
        }
        
        var reloadOption = UIAlertAction(title: "Reload", style: .Default) { action  in
            self.tableView.reloadData()
            alert.dismissModalViewControllerAnimated(true)
        }
        
        var destroyOption = UIAlertAction(title: "Delete All", style: .Destructive) { action  in
            self.clearEntities()
            alert.dismissModalViewControllerAnimated(true)
        }
        
        var cancelOption = UIAlertAction(title: "Cancel", style: .Cancel) { action  in
            alert.dismissModalViewControllerAnimated(true)
        }
        
        alert.addAction(saveOption)
        alert.addAction(reloadOption)
        alert.addAction(destroyOption)
        alert.addAction(cancelOption)

        
        self.presentViewController(alert, animated:true, nil)
    }
    
    
}

