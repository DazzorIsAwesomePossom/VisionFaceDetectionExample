//
//  AVFaceAnalyzer.swift
//  AVFaceDetection
//
//  Created by Dan Fechtmann on 04/11/2018.
//  Copyright © 2018 Dan Fechtmann. All rights reserved.
//

import Foundation
import Vision
import AVKit

//Class responsible for the analysis of faces using Vision.
class AVFaceAnalyzer {
    
    weak var delegate: AVFaceAnalyzerDelegate?
    
    init(delegate: AVFaceAnalyzerDelegate) {
        
        self.delegate = delegate
        
    }
    
    //This function analyses the sampleBuffer it recieves from AVFaceDetectionManager which itself recieves it from AVCameraManager.
    //This method then returns an array of faces or an error.
    func detectFacesIn(sampleBuffer: CMSampleBuffer) {
        autoreleasepool {
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                delegate?.handleFaceObservationError(e: AVFaceAnalyzerError.FailedToConvertSampleBufferToPixelBuffer)
                return
            }
            
            let faceDection = VNDetectFaceRectanglesRequest { (request, error) in
                if let e = error {
                    self.delegate?.handleFaceObservationError(e: e)
                    return
                }
                if let results = request.results as? [VNFaceObservation] {
                    self.delegate?.handleReturnedObservableFaces(facedObserved: results)
                }
            }
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try requestHandler.perform([faceDection])
            } catch let e {
                delegate?.handleFaceObservationError(e: e)
            }
        }
    }
}


protocol AVFaceAnalyzerDelegate: class {
    
    func handleReturnedObservableFaces(facedObserved: [VNFaceObservation])
    func handleFaceObservationError(e: Error)
    
}

enum AVFaceAnalyzerError: Error {
    
    case FailedToConvertSampleBufferToPixelBuffer
    
}
