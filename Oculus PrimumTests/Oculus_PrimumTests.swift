//
//  Oculus_PrimumTests.swift
//  Oculus PrimumTests
//
//  Created by Vladimir Danila on 17/05/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import XCTest
@testable import Oculus_Primum

class Oculus_PrimumTests: XCTestCase {
    
    let responseObject = AnalyzeImage.AnalyzeImageObject()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
   
    
    
    // Description tests
    
    
    func testDescriptionGenerationWithOnePerson() {
        responseObject.descriptionText = "A man smmiling to the camera"
        
        responseObject.dominantForegroundColor = "Red"
        responseObject.dominantBackgroundColor = "Green"
     
        let face1 = AnalyzeImage.AnalyzeImageObject.createTestFace()
        responseObject.faces = [face1]
        
        let description = responseObject.generateDescription()
        
        XCTAssertEqual("This might be A man smmiling to the camera. He is approximately \(face1.age!) years old. I think that his primary emotion is \(face1.emotion!). In the foreground the color Red is dominating. In the background it\'s Green.", description!)
    }
    
    func testDescriptionGenerationWithTwoPersons() {
        responseObject.descriptionText = "a group of people smiling to the camera"
        
        responseObject.dominantForegroundColor = "Red"
        responseObject.dominantBackgroundColor = "Green"
        
        let face1 = AnalyzeImage.AnalyzeImageObject.createTestFace()
        let face2 = AnalyzeImage.AnalyzeImageObject.createTestFace()

        responseObject.faces = [face1, face2]
        
        let description = responseObject.generateDescription()!
        
        let hardCodedDescription = "This might be a group of people smiling to the camera. There are 2 persons in the image. Starting from the left to the right, The person is a approximately \(face1.age!) years old Male. I think that his primary emotion is \(face1.emotion!).The next person is a approximately \(face2.age!) years old Male. I think that his primary emotion is \(face2.emotion!). In the foreground the color Red is dominating. In the background it\'s Green."
        
        
        XCTAssertEqual(hardCodedDescription, description)
    }
    

    func testDescriptionGenerationWithThreePersons() {
        responseObject.descriptionText = "a group of people smiling to the camera"
        
        responseObject.dominantForegroundColor = "Red"
        responseObject.dominantBackgroundColor = "Green"
        
        let face1 = AnalyzeImage.AnalyzeImageObject.createTestFace()
        let face2 = AnalyzeImage.AnalyzeImageObject.createTestFace()
        let face3 = AnalyzeImage.AnalyzeImageObject.createTestFace()
        
        responseObject.faces = [face1, face2, face3]
        
        let description = responseObject.generateDescription()!
        
        let hardCodedDescription = "This might be a group of people smiling to the camera. There are 2 persons in the image. Starting from the left to the right, The person is a approximately \(face1.age!) years old Male. I think that his primary emotion is \(face1.emotion!).The next person is a approximately \(face2.age!) years old Male. I think that his primary emotion is \(face2.emotion!). In the foreground the color Red is dominating. In the background it\'s Green."
        
        
        XCTAssertEqual(hardCodedDescription, description)
    }
    
    
}
