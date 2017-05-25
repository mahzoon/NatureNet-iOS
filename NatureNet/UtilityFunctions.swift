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
        alert.addAction(UIAlertAction(title: AUTHENTICATION_REQUIRED_BUTTON_SIGNIN_TEXT, style: .default, handler: nil))
        theView.present(theView, animated: true, completion: completion)
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
