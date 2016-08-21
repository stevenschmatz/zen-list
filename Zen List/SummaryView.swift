//
//  SummaryView.swift
//  Zen List
//
//  Created by Steven on 8/21/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import UIKit

/**
 The view that's shown after all tasks are completed. Contains the number of tasks completed per day, week, and month.
 */
class SummaryView: UIView {

    init() {
        super.init(frame: CGRectZero)
        
        setViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI Components
    
    private lazy var blueCircleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BlueCircle"))
        self.addSubview(imageView)
        return imageView
    }()
    
    private lazy var summaryLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFontOfSize(20)
        label.text = "Summary"
        label.textColor = UIColor.whiteColor()
        
        self.addSubview(label)
        return label
    }()
    
    private func summaryAttributedString(numberOfTasks: Int, timePeriod: String) -> NSAttributedString {
        let boldString = "\(numberOfTasks) tasks"
        let string = "\(boldString) completed \(timePeriod)"
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ])
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: NSMakeRange(0, boldString.characters.count))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(16), range: NSMakeRange(boldString.characters.count, string.characters.count - boldString.characters.count))
        
        return attributedString
    }
    
    private lazy var monthLabel: UILabel = {
        let monthLabel = UILabel()
        monthLabel.attributedText = self.summaryAttributedString(Analytics.sharedInstance.tasksFinishedThisMonth, timePeriod: "the last 30 days")
        self.addSubview(monthLabel)
        return monthLabel
    }()
    
    private lazy var monthLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 1.0, alpha: 0.35)
        self.addSubview(line)
        return line
    }()
    
    private lazy var weekLabel: UILabel = {
        let label = UILabel()
        label.attributedText = self.summaryAttributedString(Analytics.sharedInstance.tasksFinishedThisWeek, timePeriod: "this week")
        self.addSubview(label)
        return label
    }()
    
    private lazy var weekLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 1.0, alpha: 0.35)
        self.addSubview(line)
        return line
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.attributedText = self.summaryAttributedString(Analytics.sharedInstance.tasksFinishedToday, timePeriod: "today")
        self.addSubview(label)
        return label
    }()
    
    // MARK: - Layout
    
    private func setViewConstraints() {
        blueCircleImageView.pinToTopEdgeOfSuperview()
        blueCircleImageView.sizeToWidthAndHeight(80)
        blueCircleImageView.centerHorizontallyInSuperview()
        
        summaryLabel.positionBelowItem(blueCircleImageView, offset: 50)
        summaryLabel.centerHorizontallyInSuperview()
        
        monthLabel.pinToBottomEdgeOfSuperview()
        monthLabel.pinToSideEdgesOfSuperview()
        
        monthLine.pinToSideEdgesOfSuperview()
        monthLine.sizeToHeight(1)
        monthLine.positionAboveItem(monthLabel, offset: 15)
        
        weekLabel.pinToSideEdgesOfSuperview()
        weekLabel.positionAboveItem(monthLine, offset: 15)
        
        weekLine.pinToSideEdgesOfSuperview()
        weekLine.sizeToHeight(1)
        weekLine.positionAboveItem(weekLabel, offset: 15)
        
        dayLabel.pinToSideEdgesOfSuperview()
        dayLabel.positionAboveItem(weekLine, offset: 15)
    }
    
    // MARK: - Data
    
    func reloadData() {
        monthLabel.attributedText = self.summaryAttributedString(Analytics.sharedInstance.tasksFinishedThisMonth, timePeriod: "the last 30 days")
        weekLabel.attributedText = self.summaryAttributedString(Analytics.sharedInstance.tasksFinishedThisWeek, timePeriod: "this week")
        dayLabel.attributedText = self.summaryAttributedString(Analytics.sharedInstance.tasksFinishedToday, timePeriod: "today")
    }
}
