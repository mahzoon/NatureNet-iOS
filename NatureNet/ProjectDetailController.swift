//
//  ProjectDetailController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ProjectDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var projectDetailTable: UITableView!
    
    @IBOutlet weak var projectIcon: UIImageView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var descriptionText: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        projectDetailTable.delegate = self
        projectDetailTable.dataSource = self
        
        descriptionText.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        projectDetailTable.FixHeaderLayout()
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
