//
//  Task.swift
//  Qu
//
//  Created by Steven on 8/20/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import Foundation

typealias Task = String

/**
 A standard queue.
 */
class Queue<T> {
    
    // MARK: Model
    
    var items: [T]
    
    // MARK: Init
    
    init(items: [T]) {
        self.items = items
    }
    
    init() {
        self.items = [T]()
    }
    
    // MARK: - Queue
    
    func pop() -> T? {
        return items.popLast()
    }
    
    func push(item: T) {
        items.insert(item, atIndex: 0)
    }
    
    func allItems() -> [T] {
        return items
    }
}

class PersistentQueue<T>: Queue<T> {
    
    // MARK: - ID
    
    private var id: String
    
    // MARK: - Init
    
    init(id: String, items: [T]) {
        self.id = id
        super.init(items: items)
    }
    
    init(id: String) {
        self.id = id
        super.init()
        initItemsFromPersistentStorage()
    }
    
    override init() {
        self.id = "persistent_queue_default"
        super.init()
        initItemsFromPersistentStorage()
    }
    
    func initItemsFromPersistentStorage() {
        if let fetchResults = fetchFromPersistentRecord() where fetchResults.count > 0 {
            items = fetchResults
        }
    }
    
    // MARK: - Persistence
    
    override func pop() -> T? {
        let item = super.pop()
        updatePersistentRecord()
        return item
    }
    
    override func push(item: T) {
        super.push(item)
        updatePersistentRecord()
    }
    
    private func updatePersistentRecord() {
        guard let array = items as? AnyObject as? NSArray else {
            print("Error: could not convert items to [AnyObject]")
            return
        }
        
        NSUserDefaults.standardUserDefaults().setValue(array, forKey: id)
    }
    
    private func fetchFromPersistentRecord() -> [T]? {
        let fetchResults = NSUserDefaults.standardUserDefaults().arrayForKey(id)
        
        guard let result = fetchResults as? AnyObject as? [T] where result.count > 0 else {
            return nil
        }
        
        return result
    }
}

func initializeTaskQueue() {
    if !NSUserDefaults.standardUserDefaults().boolForKey("onboarding_complete") {
        TaskQueue.items = [
            "Welcome to Zen List! Swipe right to complete this task.",
            "Zen List is a productivity app focused on doing things one at a time.",
            "The only item you can interact with is the top item. You can swipe left to delete it (try it!).",
            "Sometimes you have to see what's ahead - swipe up to view future tasks.",
            "When you add a task, it's pushed onto the back of the queue - the tasks you record first, you do first.",
            "When you're done with all of your tasks, you can see some numbers on your productivity. Enjoy!"
        ].reverse()
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "onboarding_complete")
    }
}

var TaskQueue = PersistentQueue<Task>()
