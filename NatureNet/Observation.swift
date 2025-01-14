//
//  Observation.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import MapKit

// Modeling the "observations" key from the Firebase database.
class NNObservation: NSObject, MKAnnotation {
    
    // the activity which this observation belongs to
    var project: String!
    // the site which this observation belongs to
    var site: String!
    // observer is the user id who made this observation
    var observer: String!
    // id of the observation
    var id: String!
    // data can have multiple interpretations that each has its own key-value in the dictionary. Current possibilities are "text", and "image"
    var data: [String: String]!
    // coordinates of the observation. The dictionary keys are 0 (latitude) and 1 (longitude)
    var location: [Double]!
    // timestamp of the creation time
    var createdAt: NSNumber!
    // timestamp of the updated time
    var updatedAt: NSNumber!
    // status
    var status: String!
    // likes is a dictionary of users who liked/disliked this observation. If the value of the dictionary is true the user liked this else disliked it. So, the key is user id and the value is true(like) or false(dislike).
    var likes: [String: Bool]
    // user specified location
    var locationCustom: String!
    
    // returns the text of the observation
    var observationText: String {
        return data["text"] ?? ""
    }
    // return the text if any as the title
    var title: String? {
        return data["text"]
    }
    // returns the image url
    var observationImageUrl: String {
        return data["image"] ?? ""
    }
    // returns the document attached to the observation (if any)
    var observationDoc: String {
        return data["doc"] ?? ""
    }
    // returns coordinates object
    var locationCoordinate: CLLocationCoordinate2D {
        if location.count != 2 {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        } else {
            return CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        }
    }
    var coordinate: CLLocationCoordinate2D {
        return locationCoordinate
    }
    // return pin color
    var pinColor: UIColor {
        return PIN_COLORS[site] ?? DEFAULT_PIN_COLOR
    }
    // return likes
    var Likes: [String: Bool] {
        let l = likes.filter({ (_: String, value: Bool) -> Bool in
            return value
        })
        var ret_val = [String:Bool]()
        for result in l {
            ret_val[result.0] = result.1
        }
        return ret_val
    }
    // return dislikes
    var Dislikes: [String: Bool] {
        let l = likes.filter({ (_: String, value: Bool) -> Bool in
            return !value
        })
        var ret_val = [String:Bool]()
        for result in l {
            ret_val[result.0] = result.1
        }
        return ret_val
    }
    
    // the initializer.
    init(project: String, site: String, observer: String, id: String, data: [String: String], location: [Double], created: NSNumber, updated: NSNumber, status: String, likes: [String: Bool], userSpecLocation: String) {
        self.project = project
        self.site = site
        self.id = id
        self.observer = observer
        self.data = data
        self.location = location
        self.createdAt = created
        self.updatedAt = updated
        self.status = status
        self.likes = likes
        self.locationCustom = userSpecLocation
    }
    
    func getDictionaryRepresentation() -> [String: AnyObject] {
        var retVal = [String: AnyObject]()
        retVal["created_at"] = self.createdAt
        retVal["updated_at"] = self.updatedAt
        retVal["id"] = self.id as AnyObject
        retVal["activity"] = self.project as AnyObject
        retVal["site"] = self.site as AnyObject
        retVal["data"] = self.data as AnyObject
        retVal["l"] = ["0": self.coordinate.latitude, "1": self.coordinate.longitude] as AnyObject
        retVal["observer"] = self.observer as AnyObject
        retVal["where"] = self.locationCustom as AnyObject
        retVal["source"] = DB_SOURCE as AnyObject
        return retVal
    }
    
    func getThumbnailUrlWithHeight(height: Int) -> String {
        if observationImageUrl != "" {
            let index = observationImageUrl.range(of: "/", options:String.CompareOptions.backwards, range: nil, locale: nil)
            if let idIndex = index {
                let thumbnailUrl = CLOUDINARY_BASE_URL + "h_\(height)" +
                    observationImageUrl.substring(from: idIndex.lowerBound)
                return thumbnailUrl
            }
        }
        return ""
    }
    
    func getThumbnailUrlWithWidth(width: Int) -> String {
        if observationImageUrl != "" {
            if !observationImageUrl.contains(CLOUDINARY_BASE_URL) {
                // no api for thumbnails
                return observationImageUrl
            } else {
                // use cloudinary api functions to get a thumbnail
                let index = observationImageUrl.range(of: "/", options:String.CompareOptions.backwards, range: nil, locale: nil)
                if let idIndex = index {
                    let imageId = observationImageUrl.substring(from: idIndex.lowerBound)
                    let nonBaseUrl = observationImageUrl.substring(from: CLOUDINARY_BASE_URL.index(CLOUDINARY_BASE_URL.startIndex, offsetBy: CLOUDINARY_BASE_URL.characters.count))
                    let imageIdComponents = nonBaseUrl.components(separatedBy: "/")
                    if imageIdComponents.count > 2 {
                        return "\(CLOUDINARY_BASE_URL)w_\(width)/\(imageIdComponents[1])\(imageId)"
                    }
                    return "\(CLOUDINARY_BASE_URL)w_\(width)\(imageId)"
                }
            }
        }
        return ""
    }
    
    static func createObservationFromFirebase(with snapshot: [String: AnyObject]) -> NNObservation {
        // setting default values
        var obsProject = ""
        var obsId = ""
        var obsSite = ""
        var obsObserver = ""
        var obsData = [String: String]()
        var obsLocation = [Double]()
        var obsCreated: NSNumber = 0
        var obsUpdated: NSNumber = 0
        var obsStatus = ""
        var obsLocationCustom = ""
        var obsLikes = [String: Bool]()
        // setting values when possible
        if let tmp = snapshot["activity"], (tmp as? String) != nil {
            obsProject = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            obsId = tmp as! String
        }
        if let tmp = snapshot["site"], (tmp as? String) != nil {
            obsSite = tmp as! String
        }
        if let tmp = snapshot["observer"], (tmp as? String) != nil {
            obsObserver = tmp as! String
        }
        if let tmp = snapshot["data"], (tmp as? [String: String]) != nil {
            obsData = tmp as! [String: String]
        }
        if let tmp = snapshot["l"], (tmp as? [Double]) != nil {
            obsLocation = tmp as! [Double]
        }
        if let tmp = snapshot["created_at"], (tmp as? NSNumber) != nil {
            obsCreated = tmp as! NSNumber
        }
        if let tmp = snapshot["updated_at"], (tmp as? NSNumber) != nil {
            obsUpdated = tmp as! NSNumber
        }
        if let tmp = snapshot["status"], (tmp as? String) != nil {
            obsStatus = tmp as! String
        }
        if let tmp = snapshot["where"], (tmp as? String) != nil {
            obsLocationCustom = tmp as! String
        }
        if let tmp = snapshot["likes"], (tmp as? [String: Bool]) != nil {
            obsLikes = tmp as! [String: Bool]
        }
        let observation = NNObservation(project: obsProject, site: obsSite, observer: obsObserver, id: obsId, data: obsData, location: obsLocation, created: obsCreated, updated: obsUpdated, status: obsStatus, likes: obsLikes, userSpecLocation: obsLocationCustom)
        return observation
    }

}
