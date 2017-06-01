//
//  DocumentViewerController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 6/1/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class DocumentViewerController: UIViewController {

    var documentPath: URL?
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let url = documentPath {
            let req = URLRequest(url: url)
            webView.loadRequest(req)
        }
    }
    
    @IBAction func documentHoldGesture(_ sender: Any) {
        let alert = UIAlertController(title: SAVE_OBSV_ALERT_TITLE, message: SAVE_OBSV_ALERT_MESSAGE, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_CANCEL, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_SHARE, style: .default, handler: { (action: UIAlertAction) in
            let activityVC = UIActivityViewController(activityItems: [self.documentPath ?? ""], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
}
