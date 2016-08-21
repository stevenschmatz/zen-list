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
    
    private lazy var scrollView: UIScrollView = {
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
    
    private lazy var topCard: StackCardView = {
        let view = StackCardView()
        view.setTask(TaskQueue.allItems().last ?? "test")
        self.scrollView.addSubview(view)
        return view
    }()
    
    private lazy var otherCardsContainer: UIView = {
        let view = UIView()
        view.layer.opacity = 0.85
        self.view.addSubview(view)
        return view
    }()
    
    private lazy var otherCards: [StackCardView] = []
    
    func addOtherCards() {
        
        let tasks = TaskQueue.allItems().reverse()
        
        for (index, task) in tasks.enumerate() {
            
            // Top card is shown already
            if index == 0 {
                continue
            }
            
            let view = StackCardView()
            view.setTask(task)
            self.otherCardsContainer.addSubview(view)
            
            view.sizeToWidth(self.view.frame.size.width - 60)
            view.sizeToHeight(250)
            view.centerVerticallyInSuperview(offset: CGFloat(TaskQueue.allItems().count - index - 2) * 15)
            view.centerHorizontallyInSuperview()
            view.backgroundColor = UIColor(hue: 265/360.0, saturation: 0.10 * CGFloat(TaskQueue.allItems().count - index - 1), brightness: 1, alpha: 1.0)
            
            otherCards.append(view)
        }
    }
    
    // MARK: - Layout
    
    private lazy var containerTopConstraint: NSLayoutConstraint? = nil
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        containerTopConstraint = otherCardsContainer.pinToTopEdgeOfSuperview()
        otherCardsContainer.pinToSideEdgesOfSuperview()
        otherCardsContainer.sizeToHeight(self.view.frame.size.height)
        
        addOtherCards()
        
        addButton.pinToBottomEdgeOfSuperview()
        addButton.pinToSideEdgesOfSuperview()
        addButton.sizeToHeight(64)
        
        scrollView.pinToTopEdgeOfSuperview()
        scrollView.pinToSideEdgesOfSuperview()
        scrollView.positionAboveItem(addButton)
        
        topCard.centerVerticallyInSuperview()
        topCard.centerHorizontallyInSuperview(offset: self.view.frame.size.width)
        topCard.sizeToWidth(self.view.frame.size.width - 60)
        topCard.sizeToHeight(250)
        
        for imageView in [doneImageView, deleteImageView] {
            imageView.sizeToWidthAndHeight(82)
            imageView.centerHorizontallyInSuperview()
            imageView.pinToTopEdgeOfSuperview(offset: 50)
        }
    }
    
    // MARK: - Navigation
    
    func addButtonPressed() {
        let composeViewController = ComposeViewController()
        composeViewController.delegate = self
        presentViewController(composeViewController, animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x - self.view.frame.size.width
        
        // "Done" swipe
        if offset < 0 {
            doneImageView.layer.opacity = -Float(offset) / 100.0
            deleteImageView.layer.opacity = 0
        } else {
            deleteImageView.layer.opacity = Float(offset) / 100.0
            doneImageView.layer.opacity = 0
        }
        
        let percentCompleted: CGFloat
        
        if offset < 0 {
            percentCompleted = -offset / self.view.frame.size.width
        } else {
            percentCompleted = offset / self.view.frame.size.width
        }
        
        otherCardsContainer.layer.opacity = 0.85 + 0.15 * Float(percentCompleted)
        containerTopConstraint?.constant = -15 * percentCompleted - 2
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard scrollView.contentOffset.x != self.view.frame.size.width else {
            return
        }
        
        if scrollView.contentOffset.x == 0 {
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
        
        if otherCards.count > 0 {
            otherCards.first?.removeFromSuperview()
            otherCards.removeFirst()
        }
        
        if allTasksCompleted {
            didFinishAllTasks()
        } else {
            topCard.setTask(TaskQueue.allItems().last!)
        }
        
        scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0)
    }
    
    private var allTasksCompleted: Bool {
        get {
            return TaskQueue.allItems().isEmpty
        }
    }
    
    private var topCardActive: Bool = !TaskQueue.allItems().isEmpty {
        didSet {
            scrollView.layer.opacity = topCardActive ? 1 : 0
            scrollView.userInteractionEnabled = topCardActive
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
        
        let view = StackCardView()
        view.setTask(TaskQueue.allItems().first!)
        self.otherCardsContainer.addSubview(view)
        
        view.sizeToWidth(self.view.frame.size.width - 60)
        view.sizeToHeight(250)
        view.centerVerticallyInSuperview(offset: CGFloat(otherCards.count - 1) * 15)
        view.centerHorizontallyInSuperview()
        
        self.otherCardsContainer.sendSubviewToBack(view)
        
        view.backgroundColor = UIColor(hue: 265/360.0, saturation: 0.10 * CGFloat(otherCards.count), brightness: 1, alpha: 1.0)
        view.layer.opacity = 0
        
        UIView.animateWithDuration(0.25) {
            view.layer.opacity = 1
        }
        
        otherCards.insert(view, atIndex: 0)
    }
}

