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
        view.setTask("Write blog post for redesign process")
        self.scrollView.addSubview(view)
        return view
    }()
    
    private lazy var otherCardsContainer: UIView = {
        let view = UIView()
        view.layer.opacity = 0.85
        self.view.addSubview(view)
        return view
    }()
    
    func addOtherCards() {
        
        for i in 0...5 {
            let view = StackCardView()
            view.setTask("Write blog post for redesign process")
            self.otherCardsContainer.addSubview(view)
            
            view.sizeToWidth(self.view.frame.size.width - 60)
            view.sizeToHeight(250)
            view.centerVerticallyInSuperview(offset: CGFloat(4-i) * 15)
            view.centerHorizontallyInSuperview()
            view.backgroundColor = UIColor(hue: 265/360.0, saturation: 0.10 * CGFloat(5-i), brightness: 1, alpha: 1.0)
        }
    }
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        otherCardsContainer.pinToEdgesOfSuperview()
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
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard scrollView.contentOffset.x != self.view.frame.size.width else {
            return
        }
        
        if scrollView.contentOffset.x == 0 {
            print("Done")
            
            doneImageView.layer.opacity = 1
            
            UIView.animateWithDuration(0.25, animations: { 
                self.doneImageView.layer.opacity = 0
            })
        } else {
            print("Delete")
            
            deleteImageView.layer.opacity = 1
            
            UIView.animateWithDuration(0.25, animations: { 
                self.deleteImageView.layer.opacity = 0
            })
        }
        
        scrollView.contentOffset = CGPointMake(self.view.frame.size.width, 0)
    }
    
    // MARK: - TaskDelegate
    
    func didAddTask() {
        
    }
}

