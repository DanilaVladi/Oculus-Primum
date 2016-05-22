//
//  AnalyzeImageObjectExtension.swift
//  Oculus Primum
//
//  Created by Vladimir Danila on 5/21/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension AnalyzeImage.AnalyzeImageObject {

    
    func generateDescription() -> String? {


        
        // Color description
        
        let dominantColorsBGandFGSame = self.dominantBackgroundColor == self.dominantForegroundColor
        
        var colorsSentance: String {
            if dominantColorsBGandFGSame {
                return "The dominating color in the image is \(dominantBackgroundColor!)."
            }
            else {
                return "In the foreground the color \(dominantForegroundColor!) is dominating. In the background it's \(dominantBackgroundColor!)."
            }
        }
        
        
        // Persons describing

        
        if faces?.count == 0 {
            
            guard let description = descriptionText else {
                return colorsSentance
            }
            
            if description.hasSuffix(".") {
                return description + " " + colorsSentance
            }
            
            return description + ". " + colorsSentance
        }

        let useHeOrShe = descriptionText!.containsString("person") || descriptionText!.containsString("male") || descriptionText!.containsString("female") || descriptionText!.containsString("man") ||
            descriptionText!.containsString("girl")  || descriptionText!.containsString("woman") || descriptionText!.containsString("child") || descriptionText!.containsString("boy")
        
        
        var numberOfPersons: String {
            
            if useHeOrShe {
                return ""
            }
            
            var words: (toBe: String, person: String, transistion: String) {
                if faces?.count == 1 {
                    return ("is", "person", "")
                }
                else {
                    return ("are", "persons", "Starting from the left to the right,")
                }
            }
            
            
            
            
            return "There \(words.toBe) \(faces!.count) \(words.person) in the image. \(words.transistion)"
        }
        
        var counter = 0
        
        var descriptions = [String]()
        faces?.forEach({ faceObject in
            
            var nextPlaceholderWord: String {
                if counter != 0 {
                    return " next"
                }
                
                return ""
            }
            
            
            typealias PrefabObject = (article: String, gender: String)
            var prefabs: PrefabObject {
                if useHeOrShe {
                    
                    var pronoun: PrefabObject {
                        if faceObject.gender == "Male" {
                            return ("He", "")
                        }
                        else if faceObject.gender == "Female"{
                            return ("She", "")
                        }
                        else {
                            return ("UNKNOWN", "")
                        }
                    }
                    
                    
                    return pronoun
                }
                else {
                    return ("The", " \(faceObject.gender!)")
                }
            }
            
            var person: (person: String, a: String) {
                if useHeOrShe {
                    return ("", "")
                }
                
                return (" person", "a ")
            }
            
            
            let age = "\(prefabs.article)\(nextPlaceholderWord)\(person.person) is \(person.a)\(faceObject.age!) years old\(prefabs.gender)"
            descriptions.append(age)
            
            counter += 1
        })
        
        
        let connectedDescriptions = descriptions.joinWithSeparator(".")
        
        let descriptionsJoined = "\(descriptionText!). \(numberOfPersons) \(connectedDescriptions)"
        
        
        // Prefix
        
        let needsPrefix = descriptionTextConfidence < 0.8
        
        var prefix: String {
            if descriptionTextConfidence > 0.8 {
                return ""
            }
            else if descriptionTextConfidence > 0.5 {
                return "I think it's "
            }
            else {
                return "This might be "
            }
        }
        
        var preDetailedDescription: String {
            if needsPrefix == false && useHeOrShe {
                return descriptionsJoined
            }
            
            var descriptionWordArray = descriptionsJoined.characters.split { $0 == " " }.map(String.init)
            
            if descriptionWordArray[2] == "is" {
                descriptionWordArray[2] = "who's"
            }

            return descriptionWordArray.joinWithSeparator(" ")
        }
        
        let detailedDescription = (prefix + preDetailedDescription).stringByReplacingOccurrencesOfString("\'", withString: "'")
        

        if detailedDescription.hasSuffix(".") {
            return detailedDescription + " " + colorsSentance
        }
        
        return detailedDescription + ". " + colorsSentance

    }

}