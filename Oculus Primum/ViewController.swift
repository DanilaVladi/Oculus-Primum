//
//  ViewController.swift
//  Oculus Primum
//
//  Created by Vladimir Danila on 17/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITabBarDelegate {

    enum SelectedItem {
        case See
        case Read
    }
    
    var selectedItem: SelectedItem = .See
    
    @IBOutlet var tapBar: UITabBar!
    @IBOutlet var seeBarItem: UITabBarItem!
    @IBOutlet var readBarItem: UITabBarItem!
    
    @IBOutlet var pictureButton: UIButton!
    @IBOutlet var captureView: UIView!
    
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
        let cognitiveServices = CognitiveServices.sharedInstance
        
        
        let deviceOrientation = UIDevice.currentDevice().orientation
        let videoOrientation = self.videoOrientationForDeviceOrientation(deviceOrientation)
        
        pictureButton.enabled = false
        let waiteAnnouncement = "Analyzing Image, please wait!".speak()
        
        
        camera.takePhotoWithCaptureView(captureView, videoOrientation: videoOrientation, cropSize: CGSizeMake(captureView.frame.width/*/2*/, captureView.frame.height/*/2*/), completion: { image in
            
            
            do {
                let imageData = UIImagePNGRepresentation(image)
                
                
                switch self.selectedItem {
                    
                case .See:
                    let analyzeImage = cognitiveServices.analyzeImage
                        try analyzeImage.analyzeImage(imageData!, visualFeatures: .Description) { response in
                            let description = analyzeImage.extractDescriptionFromDictionary(response!)
                            
                            
                            var prefix: String {
                                if description.confidence > 0.8 {
                                    return ""
                                }
                                else if description.confidence > 0.5 {
                                    return "I think it's "
                                }
                                else {
                                    return "This might be "
                                }
                            }
                            
                            waiteAnnouncement.stopSpeakingAtBoundary(.Immediate)
                            
                            (prefix + description.text).speak()
                            self.pictureButton.enabled = true
                    }

                case .Read:
                    let ocr = cognitiveServices.ocr
                    try ocr.recognizeCharactersOnImageData(imageData!, language: .Automatic, completion: { (response) in
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

