//
//  ViewController.swift
//  Qu
//
//  Created by Steven on 8/20/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    
    // MARK: - Layout
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        addButton.pinToBottomEdgeOfSuperview()
        addButton.pinToSideEdgesOfSuperview()
        addButton.sizeToHeight(64)
    }
    
    // MARK: - Navigation
    
    func addButtonPressed() {
        
    }
}

