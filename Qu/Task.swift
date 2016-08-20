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

var TaskQueue = PersistentQueue<Task>()
