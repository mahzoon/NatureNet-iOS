//
//  CommunityDetailController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class CommunityDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userDetailTable: UITableView!
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var lastActivityDate: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var numObservations: UILabel!
    @IBOutlet weak var numDesignIdeas: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDetailTable.delegate = self
        userDetailTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userDetailTable.FixHeaderLayout()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(RECENT_OBSV_ESTIMATED_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell") as? GalleryCell {
            //cell.configureCell(username: "Username", affiliation: "Aspen", avatar: "join screen - user", obsImage: "sample_image1", text: "description of the observation", num_likes: "34", num_dislikes: "52", num_comments: "5", status: "icon - discussing")
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
}
