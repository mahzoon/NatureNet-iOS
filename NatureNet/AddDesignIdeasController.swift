//
//  AddDesignIdeasController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class AddDesignIdeasController: UITableViewController {

    @IBOutlet weak var ideaText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ideaText.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func addButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
