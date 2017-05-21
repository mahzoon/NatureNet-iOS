//
//  UITable+HeaderAutoResize.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/19/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func FixHeaderLayout() {
        
        if let headerView = self.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.tableHeaderView = headerView
            }
        }
    }
}
