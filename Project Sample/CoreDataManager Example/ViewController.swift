//
//  ViewController.swift
//  CoreDataManager Example
//
//  Created by Manuel de la Mata on 13/06/2014.
//  Copyright (c) 2014 MMS. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate{
    

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var actionButton : UIBarButtonItem!
    @IBOutlet weak var editButton : UIBarButtonItem!
    
    var datasource = [MonkeyEntity]()
    
    
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
        
        let request: NSFetchRequest = NSFetchRequest(entityName: "MonkeyEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "name" , ascending: true)]
        
        CoreDataManager.sharedInstance.executeFetchRequest(request) { results in
            if let results = results as? [MonkeyEntity]{
                self.datasource = results
                self.tableView.reloadData()
            }
        }
        
    }
    
    func clearEntities(){
        
        for item in datasource {
            CoreDataManager.sharedInstance.deleteEntity(item)
        }
        self.datasource = []
        
        self.tableView.reloadData()
    }


    
    // pragma mark # - TableView Delegate methods
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.datasource.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        
        let monkey = self.datasource[indexPath.row] as MonkeyEntity
        cell?.textLabel?.text = monkey.name
        
        return cell ?? UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let monkey = self.datasource[indexPath.row] as MonkeyEntity
        monkey.name = "Monkey " + String(indexPath.row)
        
        let alert: UIAlertController = UIAlertController(title: "monkey says", message: "aaaaggg agggg agggg", preferredStyle: .Alert)
        let bananaOption = UIAlertAction(title: "Give banana", style: .Cancel) { action  in
            monkey.name = "\(monkey.name) is grateful"
            self.tableView.reloadData()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        let neverOption = UIAlertAction(title: "Never!", style: .Destructive) { action  in
            monkey.name = "\(monkey.name) is angry"
            self.tableView.reloadData()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(bananaOption)
        alert.addAction(neverOption)

        
        self.presentViewController(alert, animated:true, completion: nil)
    }
    

    
    // pragma mark # IBAction methods

    @IBAction func actionButtonPressed(sender : AnyObject) {
        
        if let newMonkey: MonkeyEntity = NSEntityDescription.insertNewObjectForEntityForName("MonkeyEntity", inManagedObjectContext: CoreDataManager.sharedInstance.managedObjectContext) as? MonkeyEntity {
            
            newMonkey.name = "Monkey " + String(self.datasource.count)
            print("Inserted New Monkey...")
            
            refreshData()
        }
    }
    
    
    @IBAction func editButtonPressed(sender : AnyObject) {
        
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        let saveOption = UIAlertAction(title: "Save", style: .Default) { action  in
            CoreDataManager.sharedInstance.save()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let reloadOption = UIAlertAction(title: "Reload", style: .Default) { action  in
            self.tableView.reloadData()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let destroyOption = UIAlertAction(title: "Delete All", style: .Destructive) { action  in
            self.clearEntities()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .Cancel) { action  in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(saveOption)
        alert.addAction(reloadOption)
        alert.addAction(destroyOption)
        alert.addAction(cancelOption)

        
        self.presentViewController(alert, animated:true, completion: nil)
    }
    
    
}

