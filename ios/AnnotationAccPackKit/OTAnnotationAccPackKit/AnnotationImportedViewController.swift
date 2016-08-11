//
//  AnnotationImportedViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit

class AnnotationImportedViewController: UIViewController {
    
    private let screenShareView = OTAnnotationScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds) - 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = UIImage(named: "mvc") else {
            return;
        }
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        
        screenShareView.addContentView(imageView)
        screenShareView.initializeToolbarView()
        let height = screenShareView.toolbarView!.bounds.size.height
        screenShareView.toolbarView!.frame = CGRectMake(0, CGRectGetHeight(UIScreen.mainScreen().bounds) - height, screenShareView.toolbarView!.bounds.size.width, height)
        
        self.view.addSubview(screenShareView)
        self.view.addSubview(screenShareView.toolbarView!)
    }
}
