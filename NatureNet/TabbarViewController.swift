//
//  CameraViewController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/29/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiddleButton()
    }
    
    func setupMiddleButton() {
        let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = view.bounds.height - menuButtonFrame.height
        menuButtonFrame.origin.x = view.bounds.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        
        menuButton.backgroundColor = UIColor.red
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        view.addSubview(menuButton)
        
        menuButton.setImage(ICON_CAMERA_TABBAR_BUTTON, for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        
        view.layoutIfNeeded()
    }
    
    @objc private func menuButtonAction(sender: UIButton) {
        self.performSegue(withIdentifier: SEGUE_ADD_OBSV, sender: nil)
    }
}
