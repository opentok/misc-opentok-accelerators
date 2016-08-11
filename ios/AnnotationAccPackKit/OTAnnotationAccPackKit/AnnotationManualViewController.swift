//
//  AnnotationManualViewController.swift
//
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import UIKit

class AnnotationManualViewController: UIViewController {
    
    private let annotationScrollView = OTAnnotationScrollView(frame: CGRectMake(0,
        64,
        CGRectGetWidth(UIScreen.mainScreen().bounds),
        CGRectGetHeight(UIScreen.mainScreen().bounds) - 64))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let image = UIImage(named: "mvc") else {
            return;
        }
        let imageView = UIImageView(image: image)
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        annotationScrollView.addContentView(imageView)
        view.addSubview(annotationScrollView)
        
        let p1 = OTAnnotationPoint(x: 119, andY: 16)
        let p2 = OTAnnotationPoint(x: 122, andY: 16)
        let p3 = OTAnnotationPoint(x: 126, andY: 18)
        let p4 = OTAnnotationPoint(x: 119, andY: 16)
        let p5 = OTAnnotationPoint(x: 144, andY: 28)
        let path = OTAnnotationPath(points: [p1, p2, p3, p4, p5], strokeColor: nil)
        annotationScrollView.annotationView.addAnnotatable(path)
        
        let p6 = OTAnnotationPoint(x: 160, andY: 16)
        let p7 = OTAnnotationPoint(x: 160, andY: 20)
        let p8 = OTAnnotationPoint(x: 160, andY: 24)
        let p9 = OTAnnotationPoint(x: 160, andY: 26)
        let p10 = OTAnnotationPoint(x: 160, andY: 30)
        let path2 = OTAnnotationPath(points: [p6, p7, p8, p9, p10], strokeColor: UIColor.redColor())
        annotationScrollView.annotationView.addAnnotatable(path2)
    }
}
