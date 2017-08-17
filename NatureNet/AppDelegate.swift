//
//  AppDelegate.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/15/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // setting up push notifications
        UtilityFunctions.setupNotifications()
        
        FirebaseApp.configure()
        // enabling offline capabilities of Firebase database object
        Database.database().isPersistenceEnabled = true
        
        // detect first time launch
        if UserDefaults.standard.object(forKey: "firstTimeNNv2") == nil {
            // remove all settings
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            
            // sign out of firebase
            DataService.ds.SignOut()
            
            UserDefaults.standard.set(false, forKey: "firstTimeNNv2")
        }
        
        // creating cloudinary instances for uploading image
        MediaManager.md.setupCloudinary()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        var token = ""
//        for i in 0..<deviceToken.count {
//            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
//        }
        // set notification_token for the user on firebase
        if let t = Messaging.messaging().fcmToken {
            DataService.ds.UpdateUserNotificationToken(token: t)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }

    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        let d : [String : Any] = dict["alert"] as! [String : Any]
        let body : String = d["body"] as! String
        let title : String = d["title"] as! String
        print("Title:\(title) + body:\(body)")
        
        if let itemId = notification.request.content.userInfo["parent"] {
            if let context = notification.request.content.userInfo["context"] {
                if let mainVC = self.window?.rootViewController as? MainViewController {
                    
                    let alertController = UIAlertController(title: notification.request.content.userInfo["title"] as? String,
                                                            message: NOTIFICATION_MESSAGE_BODY,
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NOTIFICATION_MESSAGE_BUTTON_CANCEL, style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NOTIFICATION_MESSAGE_BUTTON_OK, style: .default, handler: { (UIAlertAction) in
                        mainVC.transitionItemId = itemId as! String
                        mainVC.transitionViewId = (context as! String) + "s"
                        mainVC.dismiss(animated: false, completion: nil)
                    }))
                    UtilityFunctions.getVisibleViewController()?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let itemId = response.notification.request.content.userInfo["parent"] {
            if let context = response.notification.request.content.userInfo["context"] {
                if let mainVC = self.window?.rootViewController as? MainViewController {
                    mainVC.transitionItemId = itemId as! String
                    mainVC.transitionViewId = (context as! String) + "s"
                    mainVC.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataService.ds.dispose()
    }
}

