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
import MapKit
import Photos

// This class is a singleton, meaning only one instance is going to be created from this class. That only instance is MediaManager.md
// So, to use this class call its function by referencing the only instance, like this: MediaManager.md.SomeMethod()
class MediaManager {
    // This is the only instance of this singleton class
    static let md = MediaManager()
    
    //private var managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    private let iconCache = NSCache<NSString, UIImage>()
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var tasks = [String: URLSessionDataTask]()
    
    private var cloudinary_config = CLDConfiguration(cloudName: CLOUDINARY_CLOUD_NAME)
    private var cloudinary: CLDCloudinary?
    private var cloudinary_uploader: CLDUploader?
    
    func setupCloudinary() {
        cloudinary = CLDCloudinary(configuration: cloudinary_config)
        cloudinary_uploader = cloudinary?.createUploader()
    }
    
    func getOrDownloadIcon(requesterId: String, urlString: String, completion: @escaping (UIImage?, String) -> Void) {
        let url = makeUrlSecure(url: urlString)
        // step 1: cancel previous requests with the same requester if any
        tasks[requesterId]?.cancel()
        // step 2: check cache, if the image is already downloaded send back the image
        if let img = iconCache.object(forKey: url as NSString) {
            completion(img, "")
        } else {
            // step 3: the image needs to be downloaded and set in the cache
            downloadImage(requesterId: requesterId, urlString: url, cache: self.iconCache, completion: completion)
        }
    }
    
    func getOrDownloadImage(requesterId: String, urlString: String, completion: @escaping (UIImage?, String) -> Void) {
        let url = makeUrlSecure(url: urlString)
        // step 1: cancel previous requests with the same requester if any
        tasks[requesterId]?.cancel()
        // step 2: check cache, if the image is already downloaded send back the image
        if let img = imageCache.object(forKey: url as NSString) {
            completion(img, "")
        } else {
            // step 3: the image needs to be downloaded and set in the cache
            downloadImage(requesterId: requesterId, urlString: url, cache: self.imageCache, completion: completion)
        }
    }
    
    private func downloadImage(requesterId: String, urlString: String, cache: NSCache<NSString, UIImage>, completion: @escaping (UIImage?, String) -> Void) {
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
                            cache.setObject(img, forKey: urlString as NSString)
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

    func uploadImage(image: UIImage, progressHandler: ((Progress) -> Void)?, completionHandler: ((CLDUploadResult?, NSError?) -> ())?) {
        let imgData = UIImagePNGRepresentation(image)
        if let data = imgData {
            cloudinary_uploader?.upload(data: data, uploadPreset: CLOUDINARY_PRESET, params: nil, progress: progressHandler, completionHandler: completionHandler)
        }
    }
    
    func getImageCoordinates(url: URL) -> CLLocationCoordinate2D? {
        let opts = PHFetchOptions()
        opts.fetchLimit = 1
        let assets = PHAsset.fetchAssets(withALAssetURLs: [url], options: opts)
        let asset = assets[0]
        return asset.location?.coordinate
    }
    
    func saveImageToPhotosLib(img: UIImage, completion: @escaping (Bool, String, CLLocationCoordinate2D?) -> Void) {
        
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetChangeRequest.creationRequestForAsset(from: img)
        }) { success, error in
            if let err = error {
                completion(false, err.localizedDescription, nil)
            } else {
                if success {
                    let opts = PHFetchOptions()
                    opts.fetchLimit = 1
                    opts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let assets = PHAsset.fetchAssets(with: opts)
                    let asset = assets[0]
                    completion(true, "", asset.location?.coordinate)
                }
            }
        }
    }
}
