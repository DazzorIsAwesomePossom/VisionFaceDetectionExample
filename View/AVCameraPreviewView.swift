//
//  AVCameraPreviewView.swift
//  AVFaceDetection
//
//  Created by Dan Fechtmann on 04/11/2018.
//  Copyright © 2018 Dan Fechtmann. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class AVCameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}
