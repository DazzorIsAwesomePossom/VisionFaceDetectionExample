//
//  AVCameraManager.swift
//  AVFaceDetection
//
//  Created by Dan Fechtmann on 04/11/2018.
//  Copyright © 2018 Dan Fechtmann. All rights reserved.
//

import Foundation
import AVKit

//This class is reponsible for managing everything related to the camera.
class AVCameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    var captureDevice: AVCaptureDevice?
    
    weak var delegate: AVCameraManagerDelegate?

    
    init(avCaptureDeviceType: AVCaptureDevice.DeviceType, mediaType: AVMediaType,  position: AVCaptureDevice.Position, dispatchQueue: DispatchQueue, outPutDelegate: AVCameraManagerDelegate) throws {
        super.init()
        delegate = outPutDelegate
        
        do {
            try initSession(avCaptureDeviceType: avCaptureDeviceType, mediaType: mediaType,  position: position, dispatchQueue: dispatchQueue)
        }
        catch let e{
            throw e
        }
        
    }
    
    
    private func initSession(avCaptureDeviceType: AVCaptureDevice.DeviceType, mediaType: AVMediaType,  position: AVCaptureDevice.Position, dispatchQueue: DispatchQueue) throws {
        
        captureSession.beginConfiguration()
        captureDevice = AVCaptureDevice.default(avCaptureDeviceType, for: mediaType, position: position)
        do {
            try configureCamera()
            let videoDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(videoDeviceInput)
        }
        catch let e {
            throw e
        }
        videoOutput.setSampleBufferDelegate(self, queue: dispatchQueue)
        captureSession.addOutput(videoOutput)
        captureSession.commitConfiguration()
        
    }
    
    private func configureCamera() throws {
        
        do {
            try captureDevice!.lockForConfiguration()
        }
        catch let e {
            throw e
        }
        captureDevice!.focusMode = .locked
        captureDevice!.exposureMode = .locked
        captureDevice!.unlockForConfiguration()
        
    }
    
    func setExposureAndFocusTo(point: CGPoint) throws {
        do {
            try captureDevice?.lockForConfiguration()
        }
        catch let e {
            throw e
        }
        captureDevice?.focusPointOfInterest = point
        captureDevice?.focusMode = .autoFocus
        captureDevice?.exposureMode = .autoExpose
        captureDevice?.exposurePointOfInterest = point
        captureDevice?.unlockForConfiguration()
    }
    
    //This delegate method is responsible for capturing the buffer and sending it back to AVFaceDetectionManager so it can be sent for further analysis.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        delegate?.handleSampleBuffer(sampleBuffer: sampleBuffer)
        
    }
    
}

protocol AVCameraManagerDelegate: class {
    
    func handleSampleBuffer(sampleBuffer: CMSampleBuffer) -> ()
    
}


enum AVCameraManagerError: Error {
    
    case FailedToInitializeCaptureDevice
    
}
