//
//  SigninViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/15/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class SigninViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailAddress.delegate = self
        password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailAddress {
            self.password.becomeFirstResponder()
        } else {
        self.view.endEditing(true)
        }
        return true
    }

    @IBAction func submitSignIn(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    
    @IBAction func cancelSignIn(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
