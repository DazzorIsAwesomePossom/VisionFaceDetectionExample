//
//  AVFaceDetectionManager.swift
//  AVFaceDetection
//
//  Created by Dan Fechtmann on 05/11/2018.
//  Copyright © 2018 Dan Fechtmann. All rights reserved.
//

import Foundation
import AVKit
import Vision

//This is the class with which the user is supposed to interact. It hold references to AVCameraManager and AVFaceAnalyzer
//and confroms to their protocols so it acts like their delegate.
final class AVFaceDetectionManager: AVCameraManagerDelegate, AVFaceAnalyzerDelegate {
    
    private var onSuccessMethod: ()->()?
    private var onFailMethod: (_ e: Error)->()?
    
    private var previousResult = 0
    
    var cameraManager: AVCameraManager?
    var faceAnalyzer: AVFaceAnalyzer?
    
    let managerDispatchQueue = DispatchQueue(label: "managerQueue")
    
    init(avCaptureDeviceType: AVCaptureDevice.DeviceType, mediaType: AVMediaType,  position: AVCaptureDevice.Position, dispatchQueue: DispatchQueue, detectionSuccess: @escaping ()->(), detectionFailed:@escaping (_ e: Error)->()) throws {
        
        //Two of the method calls to be called when a face is detected or notdetected/error occured
        onSuccessMethod = detectionSuccess
        onFailMethod = detectionFailed
        
        faceAnalyzer = AVFaceAnalyzer(delegate: self)
        
        do {
            cameraManager = try AVCameraManager(avCaptureDeviceType: avCaptureDeviceType, mediaType: mediaType, position: position, dispatchQueue: dispatchQueue, outPutDelegate: self)
        }
        catch let e {
            throw e
        }
    }
    
    
    private func calculateFaceMiddlePointFrom(rect: CGRect) -> CGPoint {
        
        return CGPoint(x: rect.width / 2, y: rect.height / 2)
        
    }
    
    //Sets the preview session and starts the entire process, this happens on a thread different from main because it's a heavy task.
    func beginFacialAnalysis(previewSessionView: AVCameraPreviewView) {
        
        previewSessionView.videoPreviewLayer.session = cameraManager?.captureSession
        managerDispatchQueue.async {
            self.cameraManager?.captureSession.startRunning()
        }
        
    }
    
    //AVCameraManagerDelegate method for handing the samplebuffer and passing it to the analyzer
    func handleSampleBuffer(sampleBuffer: CMSampleBuffer) {
        self.faceAnalyzer?.detectFacesIn(sampleBuffer: sampleBuffer)
    }
    
    //Responsible for handling the raw array of faces returned from the analyzer
    func handleReturnedObservableFaces(facedObserved: [VNFaceObservation]) {
        
        //This simple if checks whether there are any faces or not and if the result is different from the privious time
        //as to ensure I don't call the ViewCOntroller's closures every frame.
        if facedObserved.count > 0 && facedObserved.count != previousResult {
            previousResult = facedObserved.count
            let middleOfFacePoint = calculateFaceMiddlePointFrom(rect: facedObserved[0].boundingBox)
            do {
                try cameraManager?.setExposureAndFocusTo(point: middleOfFacePoint)
            }
            catch let e {
                onFailMethod(e)
            }
            onSuccessMethod()
        }
        else if facedObserved.count == 0 && facedObserved.count != previousResult{
            previousResult = facedObserved.count
            onFailMethod(AVFaceDetectionManagerError.NotAbleToFindFace)
        }
        
    }
    
    //AVFaceAnalyzerDelegate method for error handling
    func handleFaceObservationError(e: Error) {
        onFailMethod(e)
    }
    
}

enum AVFaceDetectionManagerError: Error {
    
    case NotAbleToFindFace
    
}
