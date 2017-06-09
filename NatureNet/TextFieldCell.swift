
//
//  TextFieldCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 6/8/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textBox: UITextField!
    
    var textFieldReturnCallback: ((Void) -> (Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textBox.delegate = self
        textBox.text = ""
    }
    
    func configureCell(returnCallback: @escaping (Void) -> (Void)) {
        self.textFieldReturnCallback = returnCallback
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnCallback = textFieldReturnCallback {
            returnCallback()
        }
        return false
    }
}
