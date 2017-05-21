//
//  DataService.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/20/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import Firebase

class DataService  {
    
    static let ds = DataService()
    
    //private var _REF_BASE = Firebase()
    
    private var currentUser: User?
    
    func Authenticate(email: String, pass: String,
                             completion: @escaping (Bool, String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            self.currentUser = user
            if let e = error {
                completion(false, e.localizedDescription)
            } else {
                completion(true, "")
            }
        }
    }
    
    func LoggedIn() -> Bool {
        if currentUser == nil {
            if Auth.auth().currentUser == nil {
                return false
            } else {
                self.currentUser = Auth.auth().currentUser
                return true
            }
        }
        return true
    }
    
}
