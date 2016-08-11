//
//  AnnotationBlankViewController.swift
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 8/8/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

class AnnotationBlankCanvasViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue()) {
            let screenShareView = OTAnnotationScrollView(frame: CGRectMake(0, 64, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds) - 50 - 64))
            screenShareView.initializeToolbarView()
            let height = screenShareView.toolbarView!.bounds.size.height
            screenShareView.toolbarView!.frame = CGRectMake(0, CGRectGetHeight(UIScreen.mainScreen().bounds) - height, screenShareView.toolbarView!.bounds.size.width, height)
            
            self.view.addSubview(screenShareView)
            self.view.addSubview(screenShareView.toolbarView!)
        }
    }
}
