//
//  Project.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/21/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation

// Modeling the "activities" key from the Firebase database.
// Even though the corresponding model in Firebase is called activities, here in NatureNet we call them Projects
class NNProject {
    // describes what is the project about
    var descriptionText: String!
    // url to the icon for the project
    var iconUrl: String!
    // id of the project
    var id: String!
    // the time of the latest contribution made for this project in "timestamp" format
    var latestContribution: NSNumber!
    // the name of the project
    var name: String!
    // sites that this project belongs to
    var sites: [String]!
    // sites that this project belongs to
    var sitesRaw: [String: AnyObject]!
    // timestamp of the creation time
    var createdAt: NSNumber!
    // timestamp of the updated time
    var updatedAt: NSNumber!
    
    // the initializer. Note that sites is a dictionary of siteId -> true
    init(desc: String, icon: String, id: String, latestContrib: NSNumber, name: String, sites: [String: AnyObject], created: NSNumber, updated: NSNumber) {
        self.descriptionText = desc
        self.iconUrl = icon
        self.id = id
        self.latestContribution = latestContrib
        self.name = name
        self.sitesRaw = sites
        self.sites = []
        // to extract sites we need only the key of the passed dictionary
        for (k, _) in sites {
            self.sites.append(k)
        }
        self.createdAt = created
        self.updatedAt = updated
    }
    
    func getDictionaryRepresentation() -> [String: AnyObject] {
        var retVal = [String: AnyObject]()
        retVal["created_at"] = self.createdAt
        retVal["updated_at"] = self.updatedAt
        retVal["id"] = self.id as AnyObject
        retVal["description"] = self.descriptionText as AnyObject
        retVal["icon_url"] = self.iconUrl as AnyObject
        retVal["latest_contribution"] = self.latestContribution as AnyObject
        retVal["name"] = self.name as AnyObject
        retVal["sites"] = self.sitesRaw as AnyObject
        return retVal
    }
    
    static func createProjectFromFirebase(with snapshot: [String: AnyObject]) -> NNProject {
        // setting default values
        var activityName = ""
        var activityId = ""
        var activityDesc = ""
        var activityIcon = ""
        var activityLatest: NSNumber = 0
        var activitySites: [String:AnyObject] = ["": "" as AnyObject]
        var activityCreated: NSNumber = 0
        var activityUpdated: NSNumber = 0
        // setting values when possible
        if let tmp = snapshot["name"], (tmp as? String) != nil {
            activityName = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            activityId = tmp as! String
        }
        if let tmp = snapshot["description"], (tmp as? String) != nil {
            activityDesc = tmp as! String
        }
        if let tmp = snapshot["icon_url"], (tmp as? String) != nil {
            activityIcon = tmp as! String
        }
        if let tmp = snapshot["latest_contribution"], (tmp as? NSNumber) != nil {
            activityLatest = tmp as! NSNumber
        }
        if let tmp = snapshot["sites"], (tmp as? [String:AnyObject]) != nil {
            activitySites = tmp as! [String:AnyObject]
        }
        if let tmp = snapshot["created_at"], (tmp as? NSNumber) != nil {
            activityCreated = tmp as! NSNumber
        }
        if let tmp = snapshot["updated_at"], (tmp as? NSNumber) != nil {
            activityUpdated = tmp as! NSNumber
        }
        let project = NNProject(desc: activityDesc, icon: activityIcon, id: activityId, latestContrib: activityLatest, name: activityName, sites: activitySites, created: activityCreated, updated: activityUpdated)
        return project
    }
    
}
