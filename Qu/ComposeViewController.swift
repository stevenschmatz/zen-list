//
//  ComposeViewController.swift
//  Qu
//
//  Created by Steven on 8/20/16.
//  Copyright © 2016 Steven Schmatz. All rights reserved.
//

import UIKit

/**
 The view controller responsible for the entry of tasks.
 */
class ComposeViewController: UIViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.Purple
        view.setNeedsLayout()
        
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardFrameDidChange), name: UIKeyboardDidChangeFrameNotification, object: nil)
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Delegate
    
    var delegate: TaskDelegate? = nil
    
    // MARK: - UI Components
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        
        let attributedTitle = NSAttributedString(string: "Cancel", attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18)
            ])
        
        button.backgroundColor = UIColor(white: 1, alpha: 0.39)
        button.setAttributedTitle(attributedTitle, forState: .Normal)
        button.addTarget(self, action: #selector(cancelPressed), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(button)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        
        let attributedTitle = NSAttributedString(string: "Confirm", attributes: [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(18)
            ])
        
        button.backgroundColor = Constants.Colors.Green
        button.setAttributedTitle(attributedTitle, forState: .Normal)
        button.addTarget(self, action: #selector(confirmPressed), forControlEvents: .TouchUpInside)
        
        button.userInteractionEnabled = false
        button.layer.opacity = 0.0
        
        self.view.addSubview(button)
        return button
    }()
    
    let placeholderColor = UIColor(white: 1.0, alpha: 0.39)
    let placeholder = "Begin redesign process for the tasks app"
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        
        textView.text = self.placeholder
        textView.textColor = self.placeholderColor
        textView.backgroundColor = UIColor.clearColor()
        textView.font = UIFont.systemFontOfSize(22)
        textView.tintColor = UIColor.whiteColor()
        textView.delegate = self
        
        self.view.addSubview(textView)
        return textView
    }()
    
    // MARK: - UITextViewDelegate Methods
    
    var placeholderActive = true {
        didSet {
            if placeholderActive {
                UIView.animateWithDuration(0.1, animations: {
                    self.confirmButton.layer.opacity = 0.8
                    }, completion: { (Bool) in
                        self.confirmButton.userInteractionEnabled = false
                })
            } else {
                UIView.animateWithDuration(0.1, animations: {
                    self.confirmButton.layer.opacity = 1.0
                    }, completion: { (Bool) in
                        self.confirmButton.userInteractionEnabled = true
                })
            }
        }
    }
    
    var confirmButtonInView = false
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.isEmpty {
            
            placeholderActive = true
            
            textView.text = placeholder
            textView.textColor = placeholderColor
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
        else if textView.textColor == placeholderColor && !text.isEmpty {
            
            placeholderActive = false
            
            textView.text = nil
            textView.textColor = UIColor.whiteColor()
            
            guard !confirmButtonInView else {
                return true
            }
            
            cancelButtonBottomConstraint?.constant -= Constants.Sizes.ButtonHeight
            view.setNeedsLayout()
            
            UIView.animateWithDuration(0.1, animations: {
                self.view.layoutIfNeeded()
                self.confirmButton.layer.opacity = 1.0
                }, completion: { (Bool) -> Void in
                    self.confirmButton.userInteractionEnabled = true
                    self.confirmButtonInView = true
            })
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == placeholderColor {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    
    func keyboardFrameDidChange(notification: NSNotification) {
        keyboardTop = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue().minY
        
        guard let constraint = cancelButtonBottomConstraint else {
            return
        }
        
        guard let distanceFromBottom = keyboardTop else {
            return
        }
        
        var constant = distanceFromBottom - self.view.frame.size.height
        
        if confirmButtonInView {
            constant -= Constants.Sizes.ButtonHeight
        }
        
        constraint.constant = constant
        view.setNeedsLayout()
        
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Layout
    
    private var cancelButtonBottomConstraint: NSLayoutConstraint? = nil
    private var keyboardTop: CGFloat? = nil
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if cancelButtonBottomConstraint == nil {
            cancelButtonBottomConstraint = cancelButton.pinToBottomEdgeOfSuperview(offset: 0)
        }
        
        cancelButton.pinToSideEdgesOfSuperview()
        cancelButton.sizeToHeight(Constants.Sizes.ButtonHeight)
        
        confirmButton.positionBelowItem(cancelButton)
        confirmButton.pinToSideEdgesOfSuperview()
        confirmButton.sizeToHeight(Constants.Sizes.ButtonHeight)
        
        textView.pinToSideEdgesOfSuperview(offset: 20)
        textView.pinToTopEdgeOfSuperview(offset: 40)
        textView.positionAboveItem(cancelButton, offset: 20)
    }
    
    // MARK: - Navigation
    
    func cancelPressed() {
        textView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func confirmPressed() {
        if placeholderActive {
            let alert = UIAlertController(title: "Enter a task", message: "The text was empty. Try again!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        TaskQueue.push(textView.text)
        delegate?.didAddTask()
        textView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
