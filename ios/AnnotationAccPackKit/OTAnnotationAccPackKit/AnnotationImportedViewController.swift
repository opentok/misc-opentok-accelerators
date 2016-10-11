//
//  AnnotationImportedViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit

class AnnotationImportedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        let topOffset = UIApplication.shared.statusBarFrame.size.height + navigationController!.navigationBar.frame.height
        let heightOfToolbar = CGFloat(50)
        
        guard let image = UIImage(named: "mvc") else {
            return;
        }
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenShareView = OTAnnotationScrollView()
        screenShareView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - heightOfToolbar - topOffset)
        screenShareView.scrollView.contentSize = image.size
        
        screenShareView.addContentView(imageView)
        
        screenShareView.initializeToolbarView()
        screenShareView.toolbarView!.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - heightOfToolbar - topOffset, width: UIScreen.main.bounds.width, height: heightOfToolbar)
        
        self.view.addSubview(screenShareView)
        self.view.addSubview(screenShareView.toolbarView!)
    }
}
