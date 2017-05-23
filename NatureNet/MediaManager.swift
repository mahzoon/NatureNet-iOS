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
import Alamofire

// This class is a singleton, meaning only one instance is going to be created from this class. That only instance is MediaManager.md
// So, to use this class call its function by referencing the only instance, like this: MediaManager.md.SomeMethod()
class MediaManager {
    // This is the only instance of this singleton class
    static let md = MediaManager()
    
    //private var managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    private let iconCache = NSCache<NSString, UIImage>()
    private var tasks = [String: URLSessionDataTask]()
    
    func getOrDownloadIcon(requesterId: String, urlString: String, completion: @escaping (UIImage?, String) -> Void) {
        let url = makeUrlSecure(url: urlString)
        // step 1: cancel previous requests with the same requester if any
        tasks[requesterId]?.cancel()
        // step 2: check cache, if the image is already downloaded send back the image
        if let img = iconCache.object(forKey: url as NSString) {
            completion(img, "")
        } else {
            // step 3: the image needs to be downloaded and set in the cache
            downloadImage(requesterId: requesterId, urlString: url, completion: completion)
        }
    }
    
    private func downloadImage(requesterId: String, urlString: String, completion: @escaping (UIImage?, String) -> Void) {
        if let url = URL(string: urlString) {
            let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URLRequest(url: url),
                                                                                           completionHandler: { (data, response, error) in
                // since the request is completed (either with error or success) we need to remove it from our dictionary
                self.tasks.removeValue(forKey: requesterId)
                
                if let e = error {
                    print(e)
                    completion(nil, e.localizedDescription)
                } else {
                    if let d = data {
                        if let img = UIImage(data: d) {
                            // set the image in cache
                            self.iconCache.setObject(img, forKey: urlString as NSString)
                            completion(img, "")
                        } else {
                            completion(nil, "cannot covert the downloaded content to an image.")
                        }
                    } else {
                        completion(nil, "no data received.")
                    }
                }
                
            })
            // register the task in our dictionary
            self.tasks[requesterId] = task
            // run the task
            task.resume()
        }
    }
    
    private func makeUrlSecure(url: String) -> String {
        return url.replacingOccurrences(of: "http://", with: "https://")
    }
    
    private func addIcon(id: String, url: String, img: UIImage) {
//        let icon = NSEntityDescription.insertNewObject(forEntityName: "IconResource", into: managedContext)
//        icon.setValue(id, forKey: "id")
//        icon.setValue(url, forKey: "url")
//        icon.setValue(img, forKey: "data")
//        do {
//            try managedContext.save()
//        } catch {
//            print("error saving data: \(error)")
//        }
    }
    
//    private func getIcon(id: String) -> IconResource? {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "IconResource")
//        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
//        do {
//            if let fetchResult = try managedContext.execute(fetchRequest) as? [IconResource] {
//                if fetchResult.count > 0 {
//                    return fetchResult[0]
//                }
//            }
//            return nil
//        } catch {
//            print("error fetching data: \(error)")
//        }
//    }
}
