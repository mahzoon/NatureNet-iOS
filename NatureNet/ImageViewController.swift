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
    
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    
    
    var observationImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barVisible = true
        imageScrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // load the observation image
        self.theImage.image = IMAGE_DEFAULT_OBSERVATION
        // requesting the icon
        if let url = observationImageUrl {
            DispatchQueue.global(qos: .background).async {
                MediaManager.md.getOrDownloadImage(requesterId: "ImageViewController", urlString: url, completion: { img, err in
                    if let i = img {
                        DispatchQueue.main.async {
                            self.theImage.image = i
                            // update the scrollview's min scale to fit the image
                            self.setMinZoomScale()
                            self.updateConstraints()
                        }
                    }
                })
            }
        }
    }
    
    func setMinZoomScale() {
        if let w = self.theImage.image?.size.width, let h = self.theImage.image?.size.height {
            let widthScale = self.imageScrollView.bounds.size.width / w
            let heightScale = self.imageScrollView.bounds.size.height / h
            let minScale = min(widthScale, heightScale)
            self.imageScrollView.minimumZoomScale = minScale
            self.imageScrollView.zoomScale = minScale
        }
    }
    
    func updateConstraints() {
        if let image = theImage.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = imageScrollView.bounds.size.width
            let viewHeight = imageScrollView.bounds.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - imageScrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            // center image if it is smaller than the scroll view
            var wPadding = (viewHeight - imageScrollView.zoomScale * imageHeight) / 2
            if wPadding < 0 { wPadding = 0 }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = wPadding
            imageConstraintBottom.constant = wPadding
            
            view.layoutIfNeeded()
        }
    }

    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return theImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.updateConstraints()
    }
    
    @IBAction func holdGestureOnImageDetected(_ sender: Any) {
        let alert = UIAlertController(title: SAVE_OBSV_ALERT_TITLE, message: SAVE_OBSV_ALERT_MESSAGE, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_CANCEL, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_SAVE_PHOTO, style: .default, handler: { (action: UIAlertAction) in
            if let img = self.theImage.image {
                UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }))
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_SHARE, style: .default, handler: { (action: UIAlertAction) in
            let activityVC = UIActivityViewController(activityItems: [self.theImage.image ?? ""], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.theImage
            self.present(activityVC, animated: true, completion: nil)
        }))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.theImage
            popoverPresentationController.sourceRect = self.theImage.bounds
        }
        present(alert, animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: SAVE_OBSV_ERROR_MESSAGE, message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: SAVE_OBSV_ERROR_BUTTON_TEXT, style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: SAVE_OBSV_SUCCESS_TITLE, message: SAVE_OBSV_SUCCESS_MESSAGE, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: SAVE_OBSV_SUCCESS_BUTTON_TEXT, style: .default))
            present(ac, animated: true)
        }
    }
}
