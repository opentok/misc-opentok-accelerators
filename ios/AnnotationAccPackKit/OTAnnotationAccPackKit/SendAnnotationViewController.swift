//
//  SendAnnotationViewController.swift
//  OTAnnotationAccPackKit
//
//  Created by Xi Huang on 9/10/16.
//  Copyright © 2016 Tokbox, Inc. All rights reserved.
//

import Foundation

class SendAnnotationViewController: UIViewController, AnnotationDelegate {
    
    let annotator = OTAnnotator()
    let sharer = OTScreenSharer.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        sharer.connectWithView(nil) {
            [unowned self]
            (signal: ScreenShareSignal, error: NSError!) in
            
            if error == nil {
                
                if signal == .SessionDidConnect {
                    self.sharer.publishAudio = false
                    self.sharer.publishVideo = false
                }
                else if signal == .SubscriberConnect {
                    
                    self.sharer.subscriberView.removeFromSuperview()
                    self.sharer.subscriberView.frame = self.view.bounds
                    self.view.insertSubview(self.sharer.subscriberView, atIndex: 0)
                }
            }
        }
        
        annotator.delegate = self
        annotator.connectForSendingAnnotation()
        annotator.annotationView.currentAnnotatable = OTAnnotationPath.init(strokeColor: UIColor.yellowColor())
    }
    
    func annotationWithSignal(signal: OTAnnotationSignal, error: NSError!) {
        
        if signal == .SessionDidConnect {
            annotator.annotationView.frame = view.frame
            view.addSubview(annotator.annotationView)
        }
    }
}
