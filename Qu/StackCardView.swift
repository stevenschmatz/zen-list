//
//  StackCardView.swift
//  Qu
//
//  Created by Steven on 8/20/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import UIKit

class StackCardView: UIView {
    
    // MARK: - Layout
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .whiteColor()
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI Components
    
    private lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFontOfSize(20)
        label.textAlignment = .Left
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        
        self.addSubview(label)
        return label
    }()
    
    // MARK: - Interface
    
    func setTask(task: Task) {
        label.text = task
    }
    
    // MARK: - Layout
    
    override func updateConstraints() {
        super.updateConstraints()
        
        label.pinToSideEdgesOfSuperview(offset: 30)
        label.centerVerticallyInSuperview()
    }
}
