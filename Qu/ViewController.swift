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
    
    private lazy var topCard: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.whiteColor()
        
        self.scrollView.addSubview(view)
        return view
    }()
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        addButton.pinToBottomEdgeOfSuperview()
        addButton.pinToSideEdgesOfSuperview()
        addButton.sizeToHeight(64)
        
        scrollView.pinToTopEdgeOfSuperview()
        scrollView.pinToSideEdgesOfSuperview()
        scrollView.positionAboveItem(addButton)
        
        topCard.centerVerticallyInSuperview()
        topCard.centerHorizontallyInSuperview(offset: self.view.frame.size.width)
        topCard.sizeToWidthAndHeight(100)
    }
    
    // MARK: - Navigation
    
    func addButtonPressed() {
        let composeViewController = ComposeViewController()
        composeViewController.delegate = self
        presentViewController(composeViewController, animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate Methods
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard scrollView.contentOffset.x != self.view.frame.size.width else {
            return
        }
        
        if scrollView.contentOffset.x == 0 {
            print("Done")
        } else {
            print("Delete")
        }
        
        scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0)
    }
    
    // MARK: - TaskDelegate
    
    func didAddTask() {
        
    }
}

