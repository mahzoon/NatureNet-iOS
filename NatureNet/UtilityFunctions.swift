//
//  UtilityFunctions.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/18/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import UIKit

class UtilityFunctions {
    
    
    static func showErrorMessage(theView: UIViewController, title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .cancel, handler: nil))
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
