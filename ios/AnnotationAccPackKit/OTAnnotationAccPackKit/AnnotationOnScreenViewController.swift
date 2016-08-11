//
//  AnnotationOnScreenViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit

class AnnotationOnScreenViewController: UIViewController {
    private let annotationOverContentViewController = OTFullScreenAnnotationViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Annotate", style: .Plain, target: self, action: #selector(AnnotationOnScreenViewController.startAnnotation))
        
        let statusButton = UIButton(frame: CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), 20))
        statusButton.addTarget(self, action: #selector(AnnotationOnScreenViewController.stopAnnotation), forControlEvents: .TouchUpInside)
        statusButton.backgroundColor = UIColor(red: 118.0/255.0, green: 206.0/255.0, blue: 31.0/255.0, alpha: 1.0)
        statusButton.setTitle("You are annotating your screen, Tap here to dismiss", forState: .Normal)
        statusButton.titleLabel!.font = UIFont.systemFontOfSize(12.0)
        annotationOverContentViewController.view.addSubview(statusButton)
    }
    
    @IBAction func viewPressed(sender: UIView!) {
        self.view.bringSubviewToFront(sender)
    }
    
    
    func startAnnotation() {
        
        UIApplication.sharedApplication().statusBarHidden = true
        let navigationBarFrame = navigationController!.navigationBar.frame
        let newFrame = CGRectMake(navigationBarFrame.origin.x, navigationBarFrame.origin.y, navigationBarFrame.size.width, 64)
        navigationController!.navigationBar.frame = newFrame
        self.presentViewController(annotationOverContentViewController, animated: true, completion: nil)
    }
    
    func stopAnnotation() {
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
