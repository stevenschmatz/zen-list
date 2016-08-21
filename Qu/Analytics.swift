//
//  Analytics.swift
//  Qu
//
//  Created by Steven on 8/21/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Analytics {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Singleton
    
    static let sharedInstance = Analytics()
    
    // MARK: - Interface
    
    var tasksFinishedToday: Int {
        get {
            return fetchTaskObjects(fromDate: NSCalendar.currentCalendar().startOfDayForDate(NSDate())).count
        }
    }
    
    var tasksFinishedThisWeek: Int {
        get {
            let calendar = NSCalendar.currentCalendar()
            var startOfTheWeek: NSDate?
            var interval = NSTimeInterval(0)
            
            calendar.rangeOfUnit(.WeekOfMonth, startDate: &startOfTheWeek, interval: &interval, forDate: NSDate())
            
            return fetchTaskObjects(fromDate: startOfTheWeek!).count
        }
    }
    
    var tasksFinishedThisMonth: Int {
        get {
            return fetchTaskObjects(fromDate: NSDate().dateByAddingTimeInterval(-30*24*60*60)).count
        }
    }
    
    // MARK: - Core Data
    
    private lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    private lazy var taskEntity: NSEntityDescription = {
        return NSEntityDescription.entityForName("Task", inManagedObjectContext: self.managedContext)!
    }()
    
    func fetchTaskObjects(fromDate date: NSDate) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: "Task")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "date > %@", date)
        fetchRequest.predicate = predicate
        
        let result = try! managedContext.executeFetchRequest(fetchRequest)
        
        print(result)
        
        return result as! [NSManagedObject]
    }
    
    func recordTask(task: Task) {
        let taskObject = NSManagedObject(entity: taskEntity, insertIntoManagedObjectContext: managedContext)
        
        taskObject.setValue(task, forKey: "task")
        taskObject.setValue(NSDate(), forKey: "date")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
