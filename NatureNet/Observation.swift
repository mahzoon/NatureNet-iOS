//
//  Observation.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import MapKit

class Observation: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let picture: UIImage!
    let activityId: Int!
    
    init(title: String, pic: UIImage, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, activityId: Int) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.picture = pic
        self.activityId = activityId
        super.init()
    }
    
    var Title: String? {
        return title
    }
    
    var Picture: UIImage {
        return picture
    }
    
    var ActivityId: Int {
        return activityId
    }
    
    var subtitle: String? {
        return locationName
    }
}
