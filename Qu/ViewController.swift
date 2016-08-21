//
//  ViewController.swift
//  Qu
//
//  Created by Steven on 8/20/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import UIKit

protocol TaskDelegate {
    func didAddTask()
}

class ViewController: UIViewController, TaskDelegate, UIScrollViewDelegate {

    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.Purple
        view.setNeedsLayout()
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - UI Elements
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.Colors.DarkPurple
        button.addTarget(self, action: #selector(addButtonPressed), forControlEvents: .TouchUpInside)
        
        let imageView = UIImageView(image: UIImage(named: "Plus"))
        button.addSubview(imageView)
        imageView.centerInSuperview()
        imageView.sizeToWidthAndHeight(20)
        
        self.view.addSubview(button)
        return button
    }()
    
    private lazy var verticalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.pagingEnabled = true
        let numberOfPages: CGFloat = 2
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, numberOfPages * self.view.frame.size.height)
        scrollView.contentOffset = CGPointMake(0, 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        self.horizontalScrollView.addSubview(scrollView)
        return scrollView
    }()
    
    private lazy var horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.pagingEnabled = true
        let numberOfPages: CGFloat = 3
        scrollView.contentSize = CGSizeMake(numberOfPages * self.view.frame.size.width, self.view.frame.size.height - Constants.Sizes.ButtonHeight)
        scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        return scrollView
    }()
    
    private lazy var doneImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "GreenCheck"))
        imageView.layer.opacity = 0.0
        self.view.addSubview(imageView)
        return imageView
    }()
    
    private lazy var deleteImageView: UIImageView = {
        let deleteImageView = UIImageView(image: UIImage(named: "RedTrash"))
        deleteImageView.layer.opacity = 0.0
        self.view.addSubview(deleteImageView)
        return deleteImageView
    }()
    
    // MARK: Cards
    
    private lazy var topCard: StackCardView = {
        let view = StackCardView()
        
        if self.allTasksCompleted {
            self.topCardActive = false
        }
        
        view.setTask(TaskQueue.allItems().last ?? "test")
        self.horizontalScrollView.addSubview(view)
        return view
    }()
    
    private lazy var otherCards: [StackCardView] = {
        
        var cards: [StackCardView] = []
        
        let tasks: [Task] = [Task("One"), Task("Two"), Task("Three"), Task("Four"), Task("Five"), Task("Six")]
        
        for (index, task) in tasks.enumerate() {
            if index == 0 {
                continue
            }
            
            let card = StackCardView()
            card.setTask(task)
            card.ratio = CGFloat(index) * 0.1
            cards.append(card)
            self.view.addSubview(card)
        }
        
        return cards
    }()
    
    // MARK: - Layout
    
    private lazy var topCardWidthConstraint: NSLayoutConstraint? = nil
    private lazy var topCardVerticalCenterConstraint: NSLayoutConstraint? = nil
    private lazy var backCardTopConstraints: [NSLayoutConstraint] = []
    private lazy var backCardHeightConstraints: [NSLayoutConstraint] = []
    private lazy var backCardWidthConstraints: [NSLayoutConstraint] = []
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        addButton.pinToBottomEdgeOfSuperview()
        addButton.pinToSideEdgesOfSuperview()
        addButton.sizeToHeight(Constants.Sizes.ButtonHeight)
        
        horizontalScrollView.pinToTopEdgeOfSuperview()
        horizontalScrollView.pinToSideEdgesOfSuperview()
        horizontalScrollView.positionAboveItem(addButton)
        
        topCardVerticalCenterConstraint = topCard.centerVerticallyInSuperview()
        topCard.centerHorizontallyInSuperview(offset: self.view.frame.size.width)
        topCardWidthConstraint = topCard.sizeToWidth(self.view.frame.size.width - 60)
        topCard.sizeToHeight(Constants.Sizes.CardHeight)
        
        for imageView in [doneImageView, deleteImageView] {
            imageView.sizeToWidthAndHeight(82)
            imageView.centerHorizontallyInSuperview()
            imageView.pinToTopEdgeOfSuperview(offset: 50)
        }
        
        verticalScrollView.pinToTopEdgeOfSuperview()
        verticalScrollView.sizeToWidth(self.view.frame.size.width)
        verticalScrollView.sizeToHeight(self.view.frame.size.height - Constants.Sizes.ButtonHeight)
        verticalScrollView.pinToLeftEdgeOfSuperview(offset: self.view.frame.size.width)
        
        for (index, card) in otherCards.enumerate() {
            backCardHeightConstraints.append(card.sizeToHeight(Constants.Sizes.CardHeight))
            backCardWidthConstraints.append(card.sizeToWidth(self.view.frame.size.width - 60))
            card.centerHorizontallyInSuperview()
            
            if index == 0 {
                backCardTopConstraints.append(card.pinTopEdgeToTopEdgeOfItem(topCard, offset: 20)!)
            } else {
                backCardTopConstraints.append(card.pinTopEdgeToTopEdgeOfItem(otherCards[index - 1], offset: 20)!)
            }
            
            view.sendSubviewToBack(card)
        }
        
        view.bringSubviewToFront(horizontalScrollView)
    }
    
    // MARK: - Navigation
    
    func addButtonPressed() {
        let composeViewController = ComposeViewController()
        composeViewController.delegate = self
        presentViewController(composeViewController, animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == verticalScrollView {
            verticalScrollViewDidScroll()
        } else if scrollView == horizontalScrollView {
            horizontalScrollViewDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == verticalScrollView {
            verticalScrollViewDidEndDecelerating()
        } else if scrollView == horizontalScrollView {
            horizontalScrollViewDidEndDecelerating()
        }
    }
    
    /**
     Responsible for unfolding the cards into the visual list.
     */
    private func verticalScrollViewDidScroll() {
        let offset = verticalScrollView.contentOffset.y
        
        guard offset >= 0 else {
            return
        }
        
        let maxOffset = self.view.frame.size.height - Constants.Sizes.ButtonHeight
        let ratio = offset / maxOffset
        
        // Increase width of cards
        
        let minimumWidth = self.view.frame.size.width - 60
        let maximumWidth = self.view.frame.size.width
        
        let widthDifference = maximumWidth - minimumWidth
        
        let newWidth = widthDifference * ratio + minimumWidth
        
        topCardWidthConstraint?.constant = newWidth
        
        for constraint in backCardWidthConstraints {
            constraint.constant = newWidth
        }
        
        // Increase top of cards
        
        let topCardOriginalTop = (self.view.frame.size.height - Constants.Sizes.ButtonHeight) / 2 - (Constants.Sizes.CardHeight / 2)
        let newTopConstant = -topCardOriginalTop * ratio
        topCardVerticalCenterConstraint?.constant = newTopConstant
        
        // Decrease top alignment of back cards
        // First background card top constraint increases, and the rest decrease
        
        let firstBackCardTopConstraintMax: CGFloat = Constants.Sizes.CardHeight
        
        let backCardTopConstraintMax: CGFloat = Constants.Sizes.BackCardHeightUnfolded
        let backCardTopConstraintMin: CGFloat = 20
        
        for (index, constraint) in backCardTopConstraints.enumerate() {
            var difference: CGFloat
            
            if index == 0 {
                difference = (firstBackCardTopConstraintMax - backCardTopConstraintMin)
            } else {
                difference = backCardTopConstraintMax - backCardTopConstraintMin
            }
            
            constraint.constant = backCardTopConstraintMin + difference * ratio
        }
        
        // Change sizes of back cards
        
        let difference = Constants.Sizes.CardHeight - Constants.Sizes.BackCardHeightUnfolded
        for constraint in backCardHeightConstraints {
            constraint.constant = Constants.Sizes.CardHeight - difference * ratio
        }
        
        // Change size of font of back cards
        
        if offset == 0 {
            for card in otherCards {
                card.setFontSize(20)
            }
        } else {
            for card in otherCards {
                card.setFontSize(16)
            }
        }
        
        self.view.setNeedsLayout()
    }
    
    /**
     Responsible for handling "Done" and "Delete" fade in animations,
     as well as moving the background cards up and increasing their opacity.
     */
    private func horizontalScrollViewDidScroll() {
        let offset = horizontalScrollView.contentOffset.x - self.view.frame.size.width
        
        // "Done" swipe
        if offset < 0 {
            doneImageView.layer.opacity = -Float(offset) / 100.0
            deleteImageView.layer.opacity = 0
        } else {
            deleteImageView.layer.opacity = Float(offset) / 100.0
            doneImageView.layer.opacity = 0
        }
        
//        let percentCompleted: CGFloat
//        
//        if offset < 0 {
//            percentCompleted = -offset / self.view.frame.size.width
//        } else {
//            percentCompleted = offset / self.view.frame.size.width
//        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func verticalScrollViewDidEndDecelerating() {
        for card in otherCards {
            card.fadeInText()
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        guard scrollView == verticalScrollView else {
            return
        }
        
        for card in otherCards {
            card.fadeOutText()
        }
    }
    
    private func horizontalScrollViewDidEndDecelerating() {
        guard horizontalScrollView.contentOffset.x != self.view.frame.size.width else {
            return
        }
        
        if horizontalScrollView.contentOffset.x == 0 {
            didFinishTask()
            
            doneImageView.layer.opacity = 1
            
            UIView.animateWithDuration(0.25, animations: {
                self.doneImageView.layer.opacity = 0
            })
        } else {
            didDeleteTask()
            
            deleteImageView.layer.opacity = 1
            
            UIView.animateWithDuration(0.25, animations: {
                self.deleteImageView.layer.opacity = 0
            })
        }
        
        if allTasksCompleted {
            didFinishAllTasks()
        } else {
            topCard.setTask(TaskQueue.allItems().last!)
        }
        
        horizontalScrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0)
    }
    
    private var allTasksCompleted: Bool {
        get {
            return TaskQueue.allItems().isEmpty
        }
    }
    
    private var topCardActive: Bool = !TaskQueue.allItems().isEmpty {
        didSet {
            horizontalScrollView.layer.opacity = topCardActive ? 1 : 0
            horizontalScrollView.userInteractionEnabled = topCardActive
        }
    }
    
    private func didFinishAllTasks() {
        topCardActive = false
    }
    
    /**
     Removes the task from the task queue, with a success status.
     */
    func didFinishTask() {
        // Maybe in the future, can do something actually useful?
        print(TaskQueue.pop())
    }
    
    /**
     Removes the task from the task queue, with a failure status.
     */
    func didDeleteTask() {
        print(TaskQueue.pop())
    }
    
    // MARK: - TaskDelegate
    
    func didAddTask() {
        let tasks = TaskQueue.allItems()
        
        if tasks.count == 1 {
            topCard.setTask(tasks.first!)
            topCardActive = true
            return
        }
    }
}

