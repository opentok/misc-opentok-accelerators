//
//  ReceiveAnnotationViewController.swift
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 9/10/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import Foundation

class ReceiveAnnotationViewController: UIViewController, AnnotationDelegate {
    
    let annotator = OTAnnotator()
    let sharer = OTScreenSharer.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        
        sharer.connectWithView(view) {
            (signal: ScreenShareSignal, error: NSError!) in
            
            if error == nil {
                
                if signal == .SessionDidConnect {
                    self.sharer.publishVideo = false
                    self.sharer.publishAudio = false
                }
                else if signal == .SubscriberConnect {
                    
                }
            }
        }
        
        annotator.delegate = self
        annotator.connectForReceivingAnnotation()
    }
    
    func annotationWithSignal(signal: OTAnnotationSignal, error: NSError!) {
        
        if signal == .SessionDidConnect {
            annotator.annotationView.frame = view.frame
            view.addSubview(annotator.annotationView)
        }
    }
}
