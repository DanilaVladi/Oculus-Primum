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


import UIKit

/**
 RequestObject is the required parameter for the AnalyzeImage API containing all required information to perform a request
 - parameter resource: The path or data of the image or
 - parameter visualFeatures, details: Read more about those [here](https://dev.projectoxford.ai/docs/services/56f91f2d778daf23d8ec6739/operations/56f91f2e778daf14a499e1fa)
*/
typealias AnalyzeImageRequestObject = (resource: AnyObject, visualFeatures: AnalyzeImage.AnalyzeImageVisualFeatures)


/**
 Analyze Image
 
This operation extracts a rich set of visual features based on the image content. 
 
 - You can try Image Analysation here: https://www.microsoft.com/cognitive-services/en-us/computer-vision-api
 
 */
class AnalyzeImage: NSObject {
    

    /// The url to perform the requests on
    let url = "https://api.projectoxford.ai/vision/v1.0/analyze"
    
    /// Your private API key. If you havn't changed it yet, go ahead!
    let key = CognitiveServicesApiKeys.ComputerVision.rawValue

    enum AnalyseImageErros: ErrorType {
        
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
    func analyzeImageWithRequestObject(requestObject: AnalyzeImageRequestObject, completion: (response: [String : AnyObject]?) -> Void) throws {
        
        //Query parameters
        let parameters = ["entities=true", "visualFeatures=\(requestObject.visualFeatures.rawValue)"].joinWithSeparator("&")
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
        
        request.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil{
                print("Error -> \(error)")
                completion(response: nil)
                return
            }else{
                let results = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
                
                // Hand dict over
                dispatch_async(dispatch_get_main_queue()) {
                    completion(response: results)
                }
            }
            
        }
        task.resume()
        
    }
    
    
    
    func extractDescriptionFromDictionary(dictionary: [String : AnyObject]) -> (text: String, confidence: Float) {
        let description = dictionary["description"] as! [String : AnyObject]
        let captions = (description["captions"] as! NSArray)[0] as! [String : AnyObject]
        let text = captions["text"] as! String
        let confidence = captions["confidence"] as! Float
        return (text, confidence)
    }
  
    func extractTagsFromDictionary(dictionary: [String : AnyObject]) -> [String] {
        let description = dictionary["description"] as! [String : AnyObject]
        let captions = (description["tags"] as! [String])
        return captions
    }
    
    
}
