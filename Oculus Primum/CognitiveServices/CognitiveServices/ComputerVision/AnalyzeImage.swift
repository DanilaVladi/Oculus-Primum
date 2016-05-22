//  AnalyzeImageComputerVision.swift
//
//  Copyright (c) 2016 Vladimir Danila
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import Foundation

/**
 RequestObject is the required parameter for the AnalyzeImage API containing all required information to perform a request
 - parameter resource: The path or data of the image or
 - parameter visualFeatures, details: Read more about those [here](https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa)
*/
typealias AnalyzeImageRequestObject = (resource: AnyObject, visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures])


/**
 Analyze Image
 
This operation extracts a rich set of visual features based on the image content. 
 
 - You can try Image Analysation here: https://www.microsoft.com/cognitive-services/en-us/computer-vision-api
 
 */
class AnalyzeImage: NSObject {
    
    
    class AnalyzeImageObject {
        
        // Categories 
        var categories: [[String : AnyObject]]?
        
        // Faces
        var faces: [FaceObject]? = []
        
        // Metadata
        var rawMetaData: [String : AnyObject]?
        var imageSize: CGSize?
        var imageFormat: String?
        
        // ImageType
        var imageType: (clipArtType: Int?, lineDrawingType: Int?)?
        
        
        // Description
        var rawDescription: [String : AnyObject]?
        var rawDescriptionCaptions: [String : AnyObject]?
        var descriptionText: String?
        var descriptionTextConfidence: Float?
        var tags: [String]?

        // Color
        var blackAndWhite: Bool?
        var dominantColors: [String]?
        var accentColorHex: String?
        var dominantForegroundColor: String?
        var dominantBackgroundColor: String?
        
        
        var isAdultContent: Bool?
        var adultScore: Float?
        var isRacyContent: Bool?
        var racyContentScore: Float?

        
        var rawDict: [String : AnyObject]?
        var requestID: String?
        
        
        // Intern Object classes
        struct FaceObject {
            let age: Int?
            let gender: String?
            let faceRectangle: CGRect?
        }
        
    }
    

    /// The url to perform the requests on
    let url = "https://api.projectoxford.ai/vision/v1.0/analyze"
    
    /// Your private API key. If you havn't changed it yet, go ahead!
    let key = CognitiveServicesApiKeys.ComputerVision.rawValue

    enum AnalyzeImageErros: ErrorType {
        
        case ImageUrlWrongFormatted
        
        // Response 400
        case InvalidImageUrl
        case InvalidImageFormat
        case InvalidImageSize
        case NotSupportedVisualFeature
        case NotSupportedImage
        case InvalidDetails

        // Response 415
        case InvalidMediaType
        
        // Response 500
        case FailedToProcess
        case Timeout
        case InternalServerError
    }
    
    
    
    /**
     Used as a parameter for `recognizeCharactersOnImageUrl`
     
    Read more about it [here](https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa)
    */
    enum AnalyzeImageVisualFeatures: String {
        case None = ""
        case Categories = "Categories"
        case Tags = "Tags"
        case Description = "Description"
        case Faces = "Faces"
        case ImageType = "ImageType"
        case Color = "Color"
        case Adult = "Adult"
    }
    
    
    
    /**
    Used as a parameter for `recognizeCharactersOnImageUrl`
    
    Read more about it [here](https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa)
    */
    enum AnalyzeImageDetails: String {
        case None = ""
        case Description = "Description"
    }
 
    
    
    /**
     This operation extracts a rich set of visual features based on the image content.
     - parameter requestObject: The required information required to perform a request
     - parameter completion: Once the request has been performed the response is returend as a Dictionary in the completion block.
     */
    func analyzeImageWithRequestObject(requestObject: AnalyzeImageRequestObject, completion: (response: AnalyzeImageObject?) -> Void) throws {
        
        //Query parameters
        let visualFeatures = requestObject.visualFeatures
            .map {$0.rawValue}
            .joinWithSeparator(",")
        
        let parameters = ["visualFeatures=\(visualFeatures)"].joinWithSeparator("&")
        let requestURL = NSURL(string: url + "?" + parameters)!
        
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "POST"
        
        // Request Parameter
        if let path = requestObject.resource as? String {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"url\":\"\(path)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        }
        else if let imageData = requestObject.resource as? NSData {
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = imageData
        }
        else {
            throw AnalyzeImageErros.InvalidImageFormat
        }
        
        request.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let started = NSDate()
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil{
                print("Error -> \(error)")
                completion(response: nil)
                return
            } else {
                                
                let results = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                let analyzeObject = self.objectFromDict(results)
                
                let interval = NSDate().timeIntervalSinceDate(started)
                print(interval)
                
                // Hand dict over
                dispatch_async(dispatch_get_main_queue()) {
                    completion(response: analyzeObject)
                }
            }
            
        }
        task.resume()
        
    }
    
    
    private func objectFromDict(dict: [String : AnyObject]?) -> AnalyzeImageObject {
        let analyzeObject = AnalyzeImageObject()
        
        analyzeObject.rawDict = dict
        
        if let categories = dict?["categories"] as? [[String : AnyObject]] {
            analyzeObject.categories = categories
        }
        
        
        if let faces = dict?["faces"] as? [[String : AnyObject]] {
            faces.forEach({ faceDict in
                let age = faceDict["age"] as? Int
                let gender = faceDict["gender"] as? String
                let faceRect = faceDict["faceRectangle"] as? [String : CGFloat]
                
                
                var rect: CGRect? {
                    if let left = faceRect?["left"],
                        let top = faceRect?["top"],
                        let width = faceRect?["width"],
                        let height = faceRect?["height"] {
                        
                        return CGRectMake(left, top, width, height)
                    }
                    
                    return nil
                }
                    
                
                let face = AnalyzeImageObject.FaceObject(age: age,
                    gender: gender,
                    faceRectangle: rect
                )

                analyzeObject.faces?.append(face)
            })
            
            
        }
        
        
        analyzeObject.requestID = dict?["requestId"] as? String
        
        
        // Medadata values
        if let metaData = dict?["metadata"] as? [String : AnyObject] {
            analyzeObject.rawMetaData = metaData
            
            if let width = metaData["width"] as? CGFloat,
               let height = metaData["height"] as? CGFloat {
                
                    analyzeObject.imageSize = CGSizeMake(width, height)
            }

            analyzeObject.imageFormat = metaData["format"] as? String
        }
        
        
        if let imageType = dict?["imageType"] as? [String : Int] {
            analyzeObject.imageType = (imageType["clipArtType"], imageType["lineDrawingType"])
        }
    
        // Description values
        if let description = dict?["description"] as? [String : AnyObject] {
        
            analyzeObject.rawDescription = description
            analyzeObject.tags = description["tags"] as? [String]
            
            // Captions values
            if let captionsRaw = description["captions"] as? NSArray {
                let captions = captionsRaw.firstObject as? [String : AnyObject]
                analyzeObject.rawDescriptionCaptions = captions
                
                analyzeObject.descriptionText = captions?["text"] as? String
            }
            
        }
        
        
        if let color = dict?["color"] as? [String : AnyObject] {
            analyzeObject.blackAndWhite = color["isBWImg"] as? Bool
            analyzeObject.dominantForegroundColor = color["dominantColorForeground"] as? String
            analyzeObject.dominantBackgroundColor = color["dominantColorBackground"] as? String
            analyzeObject.dominantColors = color["dominantColors"] as? [String]
            analyzeObject.accentColorHex = color["accentColor"] as? String
        }
        
        
        return analyzeObject
    }
    
}
