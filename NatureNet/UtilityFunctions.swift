//
//  UtilityFunctions.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/18/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import UserNotifications

class UtilityFunctions {
    
    
    static func showErrorMessage(theView: UIViewController, title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
        theView.present(alert, animated: true, completion: nil)
    }
    
    static func showAuthenticationRequiredMessage(theView: UIViewController, completion: (() -> Void)?) {
        let alert = UIAlertController(title: AUTHENTICATION_REQUIRED_TITLE,
                                      message: AUTHENTICATION_REQUIRED_MESSAGE, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: AUTHENTICATION_REQUIRED_BUTTON_CANCEL_TEXT, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: AUTHENTICATION_REQUIRED_BUTTON_SIGNIN_TEXT, style: .default, handler: { a in
            if let c = completion {
                c()
            }
        }))
        theView.present(alert, animated: true, completion: nil)
    }
    
    static func convertTimestampToDateString(date: NSNumber) -> String {
        let d = NSDate(timeIntervalSince1970:Double(date)/1000)
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.timeZone = NSTimeZone.local
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: d as Date)
    }
    
    static func isPointInRegion(point: CLLocationCoordinate2D, region: MKCoordinateRegion) -> Bool {
        var result = true
        result = result && (cos((region.center.latitude - point.latitude) * .pi / 180.0) > cos((region.span.latitudeDelta/2.0) * .pi / 180.0))
        result = result && (cos((region.center.longitude - point.longitude) * .pi / 180.0) > cos((region.span.longitudeDelta/2.0) * .pi / 180.0))
        return result
    }
    
    static func getVisibleViewController() -> UIViewController? {
        var visible = UIApplication.shared.keyWindow?.rootViewController
        while visible?.presentedViewController != nil {
            visible = visible?.presentedViewController
        }
        
        if let navigationController = visible as? UINavigationController {
            visible = navigationController.viewControllers.first
        }
        if let tabBarController = visible as? UITabBarController {
            visible = tabBarController.selectedViewController
        }
        return visible
    }
    
    static func setupNotifications() {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as! AppDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            //FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    static func NSRangeFromRange(text: String, range : Range<String.Index>) -> NSRange {
        let utf16view = text.utf16
        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
        let to = String.UTF16View.Index(range.upperBound, within: utf16view)
        return NSMakeRange(from - utf16view.startIndex, to - from)
    }
    
    static func getOccurranceIndices(text: String, query: String) -> [Range<String.Index>] {
        var searchRange = text.startIndex..<text.endIndex
        var indices: [Range<String.Index>] = []
        while let range = text.range(of: query, options: .caseInsensitive, range: searchRange) {
            searchRange = range.upperBound..<searchRange.upperBound
            indices.append(range)
        }
        return indices
    }
    
    static func convertTextToAttributedString(text: String) -> NSMutableAttributedString {
        let s = NSMutableAttributedString(string: text)
        for word in text.components(separatedBy: [",", " ", "\n"]) {
            if word.hasPrefix("#") || word.hasPrefix("@")  {
                let ranges = getOccurranceIndices(text: text, query: word)
                for range in ranges {
                    s.addAttribute(NSLinkAttributeName, value: word, range: NSRangeFromRange(text: text, range : range))
                }
            }
        }
        return s
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedOutside() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIImage {
    
    /// Extension to fix orientation of an UIImage without EXIF
    func fixOrientation() -> UIImage {
        
        guard let cgImage = cgImage else { return self }
        
        if imageOrientation == .up { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -1 * .pi / 2)
            
        case .up, .upMirrored:
            break
        }
        
        switch imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .up, .down, .left, .right:
            break
        }
        
        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            
            ctx.concatenate(transform)
            
            switch imageOrientation {
                
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }
        
        // something failed -- return original
        return self
    }
}
