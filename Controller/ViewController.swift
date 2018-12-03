//
//  ViewController.swift
//  AVFaceDetection
//
//  Created by Dan Fechtmann on 04/11/2018.
//  Copyright © 2018 Dan Fechtmann. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController { 

    @IBOutlet weak var previewSessionsView: AVCameraPreviewView!
    @IBOutlet weak var detectionLabel: UILabel!
    
    let videoDispatchQueue = DispatchQueue(label: "videoQueue")
    
    let FACE_DETECTED_STRING = "Face Detected"
    let FACE_NOT_DETECTED_STRING = "Face Not Detected"
    
    var faceDetectionManager: AVFaceDetectionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    
    //The functions responsible for setting up the capture and analysis session as well as starting it.
    private func setupSession () {
        
        do {
            faceDetectionManager = try AVFaceDetectionManager(avCaptureDeviceType: .builtInWideAngleCamera, mediaType: .video, position: .back, dispatchQueue: videoDispatchQueue, detectionSuccess: {
                DispatchQueue.main.async {
                    self.detectionLabel.text = self.FACE_DETECTED_STRING
                    print("detected")
                }
            }, detectionFailed: { (e) in
                DispatchQueue.main.async {
                    
                    if e.localizedDescription == AVFaceDetectionManagerError.NotAbleToFindFace.localizedDescription {
                        self.detectionLabel.text = self.FACE_NOT_DETECTED_STRING
                    }
                    else {
                        print(e)
                    }
                    
                }
            })
        }
        catch let e {
            print(e)
            return
        }
        
        faceDetectionManager?.beginFacialAnalysis(previewSessionView: previewSessionsView)
        
    }
    
    

}

