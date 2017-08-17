//
//  CameraViewController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/29/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {

    let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: CAMERA_MENU_BUTTON_SIZE, height: CAMERA_MENU_BUTTON_SIZE))
    
    public var transitionItemId = ""
    public var transitionViewId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiddleButton()
        updateMiddleButton(viewSize: self.view.bounds.size)
        
        if transitionViewId == DB_DESIGNIDEAS_PATH {
            self.selectedIndex = 3
            if let navigationController = selectedViewController as? UINavigationController {
                if let ideaVC = navigationController.viewControllers.first as? DesignIdeasViewController {
                    ideaVC.transitionItemId = self.transitionItemId
                }
            }
        }
        if transitionViewId == DB_OBSERVATIONS_PATH {
            self.selectedIndex = 0
            if let navigationController = selectedViewController as? UINavigationController {
                if let exploreVC = navigationController.viewControllers.first as? ExploreViewController {
                    exploreVC.transitionItemId = self.transitionItemId
                }
            }
        }
        transitionViewId = ""
        transitionItemId = ""
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateMiddleButton(viewSize: size)
    }
    
    func setupMiddleButton() {
        menuButton.setImage(ICON_CAMERA_TABBAR_BUTTON, for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        view.addSubview(menuButton)
    }
    
    func updateMiddleButton(viewSize: CGSize) {
        var menuButtonFrame = menuButton.frame
        menuButtonFrame.origin.y = viewSize.height - menuButtonFrame.height
        menuButtonFrame.origin.x = viewSize.width/2 - menuButtonFrame.size.width/2
        menuButton.frame = menuButtonFrame
        menuButton.layer.cornerRadius = menuButtonFrame.height/2
        menuButton.layer.borderWidth = 0
        view.layoutIfNeeded()
    }
    
    @objc private func menuButtonAction(sender: UIButton) {
        self.performSegue(withIdentifier: SEGUE_ADD_OBSV, sender: nil)
    }
}
