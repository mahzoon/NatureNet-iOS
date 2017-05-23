//
//  ImageManager.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/22/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import Cloudinary
import UIKit
import CoreData

// This class is a singleton, meaning only one instance is going to be created from this class. That only instance is MediaManager.md
// So, to use this class call its function by referencing the only instance, like this: MediaManager.md.SomeMethod()
class MediaManager {
    // This is the only instance of this singleton class
    static let md = MediaManager()
    
    var managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func downloadData() {
        
    }
    
    //private func addIcon(st)
}
