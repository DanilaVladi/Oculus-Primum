//
//  ViewController.swift
//  Oculus Primum
//
//  Created by Vladimir Danila on 17/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITabBarDelegate, AnalyzeImageDelegate {

    enum SelectedItem {
        case See
        case Read
    }
    
    var selectedItem: SelectedItem = .See
    
    @IBOutlet var tapBar: UITabBar!
    @IBOutlet var seeBarItem: UITabBarItem!
    @IBOutlet var readBarItem: UITabBarItem!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet var pictureButton: UIButton!
    @IBOutlet var captureView: UIView!
    
    @IBOutlet weak var requestProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    let camera = TGCamera(flashButton: UIButton())
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        camera.startRunning()
        camera.insertSublayerWithCaptureView(captureView, atRootView: self.view)
        
        
        self.tapBar.selectedItem = seeBarItem
        self.tapBar.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        camera.stopRunning()
    }
    
    
    // MARK: - Buttons
    
    @IBAction func readDidPush() {
        
        requestProgressView.setProgress(0.0, animated: false)
        
        let cognitiveServices = CognitiveServices.sharedInstance
        
        
        let deviceOrientation = UIDevice.currentDevice().orientation
        let videoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
        
        pictureButton.enabled = false
        let waiteAnnouncement = "Analyzing Image, please wait!".speak()
        
        
        camera.takePhotoWithCaptureView(captureView, videoOrientation: videoOrientation, completion: { image in
            
            self.previewImageView.hidden = false
            self.previewImageView.image = image
            UIView.animateWithDuration(2.0, animations: {
                self.previewImageView.alpha = 1.0
            })
            
            
            
            do {
                
                let imageData = UIImageJPEGRepresentation(image, 0.7)
                
                
                switch self.selectedItem {
                    
                case .See:
                    let analyzeImage = cognitiveServices.analyzeImage
                    
                    let visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures] = [.Categories, .Description, .Faces, .ImageType, .Color, .Adult]
                    let requestObject: AnalyzeImageRequestObject = (imageData!, visualFeatures)
                    
                    analyzeImage.delegate = self
                    
                    try analyzeImage.analyzeImageWithRequestObject(requestObject, completion: { (response) in
                        
                        
                        self.requestProgressView.setProgress(0.5, animated: true)
                        waiteAnnouncement.stopSpeakingAtBoundary(.Immediate)

                    })
                    
                    
                case .Read:
                    let ocr = cognitiveServices.ocr
                    let requestObject: OCRRequestObject = (resource: imageData!, language: .Automatic, detectOrientation: true)
                    try ocr.recognizeCharactersWithRequestObject(requestObject, completion: { (response) in
                        
                        let text = ocr.extractStringFromDictionary(response!)

                        
                        waiteAnnouncement.stopSpeakingAtBoundary(.Immediate)
                        
                        text.speak()
                        self.pictureButton.enabled = true

                    })

                    
                }
                    
                    
                    
            } catch {
                
            }
            
            
        })
        
        
    }
    
    
    // MARK: - Analyze API
    
    func finnishedGeneratingObject(analyzeImageObject: AnalyzeImage.AnalyzeImageObject) {
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            self.requestProgressView.setProgress(1.0, animated: true)
            
            let description = analyzeImageObject.generateDescription()
            
            
            if let description = description {
                description.speak()
            }
            
            
            UIView.animateWithDuration(1, animations: {
                self.previewImageView.alpha = 0.0
                }, completion: { _ in
                    self.previewImageView.hidden = true
                    self.previewImageView.image = nil
            })
            
            self.pictureButton.enabled = true
            
        }
        
    
    }
    
    

    // MARK: - Tab Bar controller
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item == seeBarItem {
            pictureButton.setTitle("Describe", forState: .Normal)
            pictureButton.setTitle("Describe", forState: .Selected)
            selectedItem = .See
        }
        else if item == readBarItem {
            pictureButton.setTitle("  Read  ", forState: .Normal)
            pictureButton.setTitle("  Read  ", forState: .Selected)
            pictureButton.titleLabel?.text = "  Read  "
            selectedItem = .Read
        }
    }
 
    
    // MARK: - Trait Collection
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    }

    
    // MARK: - Camera
    
    func videoOrientationForDeviceOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result: AVCaptureVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        switch deviceOrientation {
        case .LandscapeLeft:
            result = .LandscapeRight
        case .LandscapeRight:
            result = .LandscapeLeft
        default:
            break
        }
        
        return result
    }
    
}

