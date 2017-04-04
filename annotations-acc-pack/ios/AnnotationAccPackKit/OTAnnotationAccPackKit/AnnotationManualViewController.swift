//
//  AnnotationManualViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit

class AnnotationManualViewController: UIViewController {
    
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
        
        let p1: OTAnnotationPoint = OTAnnotationPoint(x: 119, andY: 16)
        let p2: OTAnnotationPoint = OTAnnotationPoint(x: 122, andY: 16)
        let p3: OTAnnotationPoint = OTAnnotationPoint(x: 126, andY: 18)
        let p4: OTAnnotationPoint = OTAnnotationPoint(x: 119, andY: 16)
        let p5: OTAnnotationPoint = OTAnnotationPoint(x: 144, andY: 28)
        let path = OTAnnotationPath(points: [p1, p2, p3, p4, p5], stroke: nil)
        screenShareView.annotationView.add(path)
        
        let p6: OTAnnotationPoint = OTAnnotationPoint(x: 160, andY: 16)
        let p7: OTAnnotationPoint = OTAnnotationPoint(x: 160, andY: 20)
        let p8: OTAnnotationPoint = OTAnnotationPoint(x: 160, andY: 24)
        let p9: OTAnnotationPoint = OTAnnotationPoint(x: 160, andY: 26)
        let p10: OTAnnotationPoint = OTAnnotationPoint(x: 160, andY: 30)
        let path2 = OTAnnotationPath(points: [p6, p7, p8, p9, p10], stroke: UIColor.red)
        screenShareView.annotationView.add(path2)
    }
}
