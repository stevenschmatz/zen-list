//
//  Analytics.swift
//  Qu
//
//  Created by Steven on 8/21/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import Foundation

class Analytics {
    
    // MARK: - Init
    
    init() {
        
    }
    
    // MARK: - Singleton
    
    static let sharedInstance = Analytics()
    
    // MARK: - Interface
    
    var tasksFinishedToday: Int {
        get {
            return 0
        }
    }
    
    var tasksFinishedThisWeek: Int {
        get {
            return 0
        }
    }
    
    
}