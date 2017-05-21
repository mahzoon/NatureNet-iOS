//
//  ImageViewController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/20/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    var barVisible = true
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var theImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barVisible = true
        imageScrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return theImage
    }
    
//    @IBAction func singleTapDetected(_ sender: Any) {
//        if barVisible {
//            hideBars()
//        } else {
//            showBars()
//        }
//    }
    
//    func zoomImage() {
//        
//    }
//
//    func hideBars() {
//        self.navigationController?.isNavigationBarHidden = true
//        self.tabBarController?.tabBar.isHidden = true
//        self.barVisible = false
//        self.view.backgroundColor = UIColor.black
//    }
//    
//    func showBars() {
//        self.navigationController?.isNavigationBarHidden = false
//        self.tabBarController?.tabBar.isHidden = false
//        self.barVisible = true
//        self.view.backgroundColor = UIColor.white
//    }
}
