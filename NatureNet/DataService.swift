//
//  DataService.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/20/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import Firebase
import MapKit

// This class is a singleton, meaning only one instance is going to be created from this class. That only instance is DataService.ds
// So, to use this class call its function by referencing the only instance, like this: DataService.ds.SignOut()
class DataService  {
    
    // This is the only instance of this singleton class
    static let ds = DataService()
    
    // reference to the Firebase "real-time database"
    private var db_ref: DatabaseReference!
    
    // The current user is either nil which means nobody is logged-in in the device, or it has a value indicating some user is logged in. This is a private member and is referenced only in the class functions for example in the LoggedIn() function.
    private var currentUser: User?
    
    // The sites array contains (siteId, siteName) sorted in an array. It will be initialized in the init, and the function "GetSites" returns it.
    private var sites = Array<(key : String, value : String)>()
    
    // reference to the observer handle of sites. This observer looks for changes in sites, and updates the "sites" array if new site is being added, or changed. The reference is mainly for "dispose" to remove the handle.
    private var sitesHandle: UInt!
    
    // The projects stored by their site. This dictionary is like: {siteName -> [NNProject1, NNProject2, ...]}. Note that we might have projects duplicated in multiple sites.
    private var projects = [String: [NNProject]]()
    // reference to the observer handle of projects. This observer looks for changes in projects, and updates the "projects" array if new project is being added, or changed. The reference is mainly for "dispose" to remove the handle.
    private var projectsHandle: UInt!
    
    // The users stored by their affiliation. This dictionary is like: {siteName -> [NNUser1, NNUser2, ...]}.
    private var users = [String: [NNUser]]()
    // reference to the observer handle of users. This observer looks for changes in users, and updates the "users" array if new user is being added, or changed. The reference is mainly for "dispose" to remove the handle.
    private var usersHandle: UInt!
    
    // The observations stored in an array sorted by their recency. The first item is the most recent one.
    private var observations = [NNObservation]()
    // reference to the observer handle of observations. This observer looks for additions to the observations, and updates the "observations" array if new observation is being added. The reference is mainly for "dispose" to remove the handle.
    private var observationsAddHandle: UInt!
    // reference to the observer handle of observations. This observer looks for removals to the observations, and updates the "observations" array if an observation is being removed. The reference is mainly for "dispose" to remove the handle.
    private var observationsRemoveHandle: UInt!
    // reference to the observer handle of observations. This observer looks for changes to the observations, and updates the "observations" array if an observation is being changed. The reference is mainly for "dispose" to remove the handle.
    private var observationsChangeHandle: UInt!
    
    // The design ideas stored in an array sorted by their recency. The first item is the most recent one.
    private var designIdeas = [NNDesignIdea]()
    // reference to the observer handle of design ideas. This observer looks for additions to the design ideas, and updates the "designIdeas" array if new idea is being added. The reference is mainly for "dispose" to remove the handle.
    private var designIdeasAddHandle: UInt!
    // reference to the observer handle of design ideas. This observer looks for removals to the design ideas, and updates the "designIdeas" array if an idea is being removed. The reference is mainly for "dispose" to remove the handle.
    private var designIdeasRemoveHandle: UInt!
    // reference to the observer handle of design ideas. This observer looks for changes to the design ideas, and updates the "designIdeas" array if an idea is being changed. The reference is mainly for "dispose" to remove the handle.
    private var designIdeasChangeHandle: UInt!
    
    // The comments stored in an array sorted by their recency. The first item is the most recent one.
    private var commentsOnObservations = [NNComment]()
    private var commentsOnDesignIdeas = [NNComment]()
    // reference to the observer handle of comments. This observer looks for additions to the comments, and updates the "commentsOnObservations" or "commentsOnDesignIdeas" arrays if new comment is being added. The reference is mainly for "dispose" to remove the handle.
    private var commentsHandle: UInt!
    
    init() {
        // initializing the reference to the database
        db_ref = Database.database().reference()
        
        // initializing observers
        initSitesObserver()
        initProjectsObserver()
        initUsersObserver()
        initObservationsObserver()
        initDesignIdeasObserver()
        initCommentsObserver()
    }
    
    func dispose() {
        // disposing all data objects
        sites.removeAll()
        projects.removeAll()
        users.removeAll()
        observations.removeAll()
        designIdeas.removeAll()
        commentsOnDesignIdeas.removeAll()
        commentsOnObservations.removeAll()
        currentUser = nil
        // remove site observer
        db_ref.removeObserver(withHandle: sitesHandle)
        // remove projects observer
        db_ref.removeObserver(withHandle: projectsHandle)
        // remove users observer
        db_ref.removeObserver(withHandle: usersHandle)
        // remove add observations observer
        db_ref.removeObserver(withHandle: observationsAddHandle)
        // remove remove observations observer
        db_ref.removeObserver(withHandle: observationsChangeHandle)
        // remove change observations observer
        db_ref.removeObserver(withHandle: observationsRemoveHandle)
        // remove add design ideas observer
        db_ref.removeObserver(withHandle: designIdeasAddHandle)
        // remove remove design ideas observer
        db_ref.removeObserver(withHandle: designIdeasRemoveHandle)
        // remove changed design ideas observer
        db_ref.removeObserver(withHandle: designIdeasChangeHandle)
        // remove comment observer
        db_ref.removeObserver(withHandle: commentsHandle)
    }
    
    //////////////////////////////////////////////////////////////
    //
    //                      Authentication
    //
    //////////////////////////////////////////////////////////////
    
    // To authenticate a user using email/password use this function. Upon success, the function calls the "completion" callback parameter with "true" and empty string parameters. If there is any error in signing in, then the parameters of "completion" callback would be false (indicating that the sign in process was not successful) and error string. The error string is generated by Firebase, and is hopefully desciptive enough about the error.
    func Authenticate(email: String, pass: String,
                             completion: @escaping (Bool, String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            self.currentUser = user
            if let e = error {
                // the localized description contains error's description
                completion(false, e.localizedDescription)
            } else {
                completion(true, "")
            }
        }
    }
    
    // To check if anybody is logged-in in this device, call this. It returns true if somebody is logged in and false otherwise.
    func LoggedIn() -> Bool {
        if currentUser == nil {
            // if currentUser is nil, we need to check Firebase auth again. Maybe we lost the user, but the user is still logged in. A typical scenario which supports this case is that the user logged-in but closes the app. The user is still logged in but the app looses the pointer to the currentUser.
            if Auth.auth().currentUser == nil {
                return false
            } else {
                // update our pointer to the current user
                self.currentUser = Auth.auth().currentUser
                return true
            }
        }
        return true
    }
    
    // To signout user from Firebase, call this function. SignOut returns a tuple containing result status as a boolean and error if any as a string. In case of successful signout, the return value will be (true, ""). But, in case of error the return value will be (false, <error description>).
    func SignOut() -> (Bool, String){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            return (false, signOutError.localizedDescription)
        }
        currentUser = nil
        return (true, "")
    }
    
    func Join(user: NNUser) {
        
    }
    
    //////////////////////////////////////////////////////////////
    //
    //                          Sites
    //
    //////////////////////////////////////////////////////////////
    
    private func initSitesObserver() {
        // adding observer to the sites
        sitesHandle = db_ref.child(DB_SITES_PATH).observe(.value, with: { (snapshot) in
            // snapshot will be the whole "sites" key with its children to the leaf. For example, if site/aces/description value changes, added, or removed, the whole sites/ will be returned. So, we can replace the "sites" array with site names in the snapshot.
            if let sitesSnapshot = snapshot.value as? [String:[String:AnyObject]] {
                // the sitesSnapshot is like "siteId" -> { "key" -> <object> } (the "key" that we are interested in is "name")
                var sitesDict = [String:String]()
                for (siteId, v) in sitesSnapshot {
                    if let siteName = v["name"] as? String {
                        sitesDict[siteId] = siteName
                    }
                }
                self.sites = sitesDict.sorted(by: {$0.key < $1.key})
            }
        })
    }
    
    // returns the number of sites.
    func GetNumSites() -> Int {
        return sites.count
    }
    // returning only site names sorted by their Ids
    func GetSiteNames() -> [String] {
        return self.sites.map{(k, v) -> String in return v}
    }
    // returning site name by id
    func GetSiteName(with id: String) -> String {
        for (k, v) in self.sites {
            if k == id {
                return v
            }
        }
        return ""
    }

    
    //////////////////////////////////////////////////////////////
    //
    //                          Projects
    //
    //////////////////////////////////////////////////////////////
    
    private func initProjectsObserver() {
        // adding observer to the projects (activities)
        projectsHandle = db_ref.child(DB_PROJECTS_PATH).observe(.value, with: { (snapshot) in
            // snapshot will contain the whole "activities" key with its children to the leaf.
            if let activitiesDict = snapshot.value as? [String:[String:AnyObject]] {
                // the activitiesDict looks like: {"activityId":{key:val,key:val,...}}
                for (_, projectSnapshot) in activitiesDict {
                    // create a project based on the snapshot
                    let project = NNProject.createProjectFromFirebase(with: projectSnapshot)
                    // add the project to the "projects" dictionary
                    for siteId in project.sites {
                        if (self.projects[siteId] != nil) {
                            self.projects[siteId]!.append(project)
                        } else {
                            self.projects[siteId] = [NNProject]()
                            self.projects[siteId]!.append(project)
                        }
                    }
                }
            }
            // excluding projects having no site (these are probably test projects)
            self.projects.removeValue(forKey: "")
            // sort the projects by project name
            for (k, v) in self.projects {
                self.projects[k] = v.sorted(by: { $0.name < $1.name })
            }
        })
    }
    
    // returns number of projects in the site index.
    func GetNumProjects(in siteIndex: Int, searchFilter: String) -> Int {
        if searchFilter != "" {
            return self.projects[self.sites[siteIndex].key]?.filter({ (e: NNProject) -> Bool in
                return (e.name.lowercased().range(of: searchFilter.lowercased()) != nil)
            }).count ?? 0
        } else {
            return self.projects[self.sites[siteIndex].key]?.count ?? 0
        }
    }
    
    // returns a specific project which is located at siteIndex and has index="position" in the array.
    func GetProject(in siteIndex:Int, at position: Int, searchFilter: String) -> NNProject? {
        if searchFilter != "" {
            if let ps = self.projects[self.sites[siteIndex].key]?.filter({ (e: NNProject) -> Bool in
                return (e.name.lowercased().range(of: searchFilter.lowercased()) != nil)}) {
                if position < ps.count {
                    return ps[position]
                }
            }
        } else {
            if let ps = self.projects[self.sites[siteIndex].key] {
                if position < ps.count {
                    return ps[position]
                }
            }
        }
        return nil
    }
    
    func GetProject(by id: String) -> NNProject? {
        for (_, v) in self.projects {
            if let p = v.first(where: { (project) -> Bool in
                project.id == id
            }) {
                return p
            }
        }
        return nil
    }

    //////////////////////////////////////////////////////////////
    //
    //                          Community
    //
    //////////////////////////////////////////////////////////////
    
    private func initUsersObserver() {
        // adding observer to the users
        usersHandle = db_ref.child(DB_USERS_PATH).observe(.value, with: { (snapshot) in
            // snapshot will contain the whole "users" key with its children to the leaf.
            if let usersDict = snapshot.value as? [String:[String:AnyObject]] {
                // the usersDict looks like: {"userId":{key:val,key:val,...}}
                for (_, userSnapshot) in usersDict {
                    // create a user based on the snapshot
                    let user = NNUser.createUserFromFirebase(with: userSnapshot)
                    // add the user to the "users" dictionary
                    if (self.users[user.affiliation] != nil) {
                        self.users[user.affiliation]!.append(user)
                    } else {
                        self.users[user.affiliation] = [NNUser]()
                        self.users[user.affiliation]!.append(user)
                    }
                }
            }
            // excluding users having no site (these are probably test users)
            self.users.removeValue(forKey: "")
            // sort the users by user display name
            for (k, v) in self.users {
                self.users[k] = v.sorted(by: { $0.displayName < $1.displayName })
            }
        })
    }
    
    // returns number of users in the site index.
    func GetNumUsers(in siteIndex: Int, searchFilter: String) -> Int {
        if searchFilter != "" {
            return self.users[self.sites[siteIndex].key]?.filter({ (e: NNUser) -> Bool in
                return (e.displayName.lowercased().range(of: searchFilter.lowercased()) != nil)
            }).count ?? 0
        } else {
            return self.users[self.sites[siteIndex].key]?.count ?? 0
        }
    }
    
    // returns a specific user which is affiliated to siteIndex and has index="position" in the array.
    func GetUser(in siteIndex:Int, at position: Int, searchFilter: String) -> NNUser? {
        if searchFilter != "" {
            if let ps = self.users[self.sites[siteIndex].key]?.filter({ (e: NNUser) -> Bool in
                return (e.displayName.lowercased().range(of: searchFilter.lowercased()) != nil)}) {
                if position < ps.count {
                    return ps[position]
                }
            }
        } else {
            if let ps = self.users[self.sites[siteIndex].key] {
                if position < ps.count {
                    return ps[position]
                }
            }
        }
        return nil
    }
    
    func GetUser(by id: String) -> NNUser? {
        for (_, v) in self.users {
            if let u = v.first(where: { (user) -> Bool in
                user.id == id
            }) {
                return u
            }
        }
        return nil
    }
    
    func GetCurrentUser() -> NNUser? {
        if let user = currentUser {
            let id = user.uid
            if let nnUser = GetUser(by: id) {
                return nnUser
            }
        }
        return nil
    }
    
    func GetCurrentUserId() -> String? {
        if let user = currentUser {
            return user.uid
        }
        return nil
    }
    
    func UpdateUserProfile(user: NNUser, fullname: String, demographics: [String: AnyObject]) {
        if !LoggedIn() { return }
        var c = user.getDictionaryRepresentation()
        let timestamp = Firebase.ServerValue.timestamp()
        c["updated_at"] = timestamp as AnyObject
        db_ref.child("\(DB_USERS_PATH)/\(user.id)").setValue(c)
        // update user-private information i.e. fullname, and demographics
        db_ref.child("\(DB_USERS_PRIVATE_PATH)/\(user.id)/name").setValue(fullname)
        db_ref.child("\(DB_USERS_PRIVATE_PATH)/\(user.id)/updated_at").setValue(timestamp)
        db_ref.child("\(DB_USERS_PRIVATE_PATH)/\(user.id)/demographics").setValue(demographics)
    }

    
    //////////////////////////////////////////////////////////////
    //
    //                         Observations
    //
    //////////////////////////////////////////////////////////////
    
    private func initObservationsObserver() {
        // adding "add" observer to the observations
        observationsAddHandle = db_ref.child(DB_OBSERVATIONS_PATH).observe(.childAdded, with: { (snapshot) in
            // snapshot.value is a dictionary for one Observation
            if let obsDict = snapshot.value as? [String: AnyObject] {
                let observation = NNObservation.createObservationFromFirebase(with: obsDict)
                // we don't bother adding observations that do not have updated_at timestamp. They are possibly test observations.
                if observation.updatedAt != 0 {
                    self.observations.append(observation)
                }
            }
            self.observations.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
        })
        // adding "remove" observer to the observations
        observationsRemoveHandle = db_ref.child(DB_OBSERVATIONS_PATH).observe(.childRemoved, with: { (snapshot) in
            // snapshot.value is a dictionary for one Observation
            if let obsDict = snapshot.value as? [String: AnyObject] {
                let observation = NNObservation.createObservationFromFirebase(with: obsDict)
                // find the observation in our array and remove it
            }
        })
        // adding "change" observer to the observations
        observationsChangeHandle = db_ref.child(DB_OBSERVATIONS_PATH).observe(.childRemoved, with: { (snapshot) in
            // snapshot.value is a dictionary for one Observation
            if let obsDict = snapshot.value as? [String: AnyObject] {
                let observation = NNObservation.createObservationFromFirebase(with: obsDict)
                // find the observation and replace it with the new one
            }
            self.observations.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
        })
    }
    
    func GetNumObervations(searchFilter: String) -> Int {
        if searchFilter != "" {
            return self.observations.filter({ (observation) -> Bool in
                if (observation.observationText.lowercased().range(of: searchFilter.lowercased()) != nil) ||
                    ((GetUser(by: observation.observer)?.displayName.lowercased().range(of: searchFilter.lowercased())) != nil) ||
                    ((GetProject(by: observation.project)?.name.lowercased().range(of: searchFilter.lowercased())) != nil) {
                    return true
                } else {
                    return false
                }
            }).count
        } else {
            return self.observations.count
        }
    }
    
    func GetObservation(at index: Int, searchFilter: String) -> NNObservation? {
        if searchFilter != "" {
            let listObs = self.observations.filter({ (observation) -> Bool in
                if (observation.observationText.lowercased().range(of: searchFilter.lowercased()) != nil) ||
                    ((GetUser(by: observation.observer)?.displayName.lowercased().range(of: searchFilter.lowercased())) != nil) ||
                    ((GetProject(by: observation.project)?.name.lowercased().range(of: searchFilter.lowercased())) != nil) {
                    return true
                } else {
                    return false
                }
            })
            if index < listObs.count {
                return listObs[index]
            }
        } else {
            if index < self.observations.count {
                return self.observations[index]
            }
        }
        return nil
    }
    
    func GetObservationsForProject(with id: String) -> [NNObservation] {
        let listObs = self.observations.filter { (observation) -> Bool in
            if observation.project == id {
                return true
            } else {
                return false
            }
        }
        return listObs
    }
    
    func GetObservationsForUser(with id: String) -> [NNObservation] {
        let listObs = self.observations.filter { (observation) -> Bool in
            if observation.observer == id {
                return true
            } else {
                return false
            }
        }
        return listObs
    }
    
    func GetObservations(near: MKCoordinateRegion, searchFilter: String) -> [NNObservation] {
        if searchFilter != "" {
            let listObs = self.observations.filter { (observation) -> Bool in
                return UtilityFunctions.isPointInRegion(point: observation.coordinate, region: near) &&
                    ((observation.observationText.lowercased().range(of: searchFilter.lowercased()) != nil) ||
                        ((GetUser(by: observation.observer)?.displayName.lowercased().range(of: searchFilter.lowercased())) != nil) ||
                        ((GetProject(by: observation.project)?.name.lowercased().range(of: searchFilter.lowercased())) != nil))
            }
            return listObs
        } else {
            let listObs = self.observations.filter { (observation) -> Bool in
                return UtilityFunctions.isPointInRegion(point: observation.coordinate, region: near)
            }
            return listObs
        }
    }
    
    func GetObservation(with id: String) -> NNObservation? {
        let listObs = self.observations.filter { (observation) -> Bool in
            return observation.id == id
        }
        if listObs.count == 1 {
            return listObs[0]
        }
        return nil
    }
    
    func AddObservation(observation: NNObservation) {
        if !LoggedIn() { return }
        // add the observation to the path
        let newObservationRef = db_ref.child(DB_OBSERVATIONS_PATH).childByAutoId()
        observation.id = newObservationRef.key
        var c = observation.getDictionaryRepresentation()
        let timestamp = Firebase.ServerValue.timestamp()
        c["created_at"] = timestamp as AnyObject
        c["updated_at"] = timestamp as AnyObject
        newObservationRef.setValue(c)
        // change the observation's activity's latest_contribution
        db_ref.child("\(DB_PROJECTS_PATH)/\(observation.project)/\(DB_LATEST_CONTRIBUTION)").setValue(timestamp)
        // change the user's latest_contribution
        db_ref.child("\(DB_USERS_PATH)/\(observation.observer)/\(DB_LATEST_CONTRIBUTION)").setValue(timestamp)
    }
    
    
    //////////////////////////////////////////////////////////////
    //
    //                        Design Ideas
    //
    //////////////////////////////////////////////////////////////
    
    private func initDesignIdeasObserver() {
        // adding "add" observer to the design ideas
        designIdeasAddHandle = db_ref.child(DB_DESIGNIDEAS_PATH).observe(.childAdded, with: { (snapshot) in
            // snapshot.value is a dictionary for one Design Idea
            if let ideaDict = snapshot.value as? [String: AnyObject] {
                let idea = NNDesignIdea.createDesignIdeaFromFirebase(with: ideaDict)
                // we don't bother adding ideas that do not have updated_at timestamp. They are possibly test ideas.
                if idea.updatedAt != 0 {
                    self.designIdeas.append(idea)
                }
            }
            self.designIdeas.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
        })
        // adding "remove" observer to the design ideas
        designIdeasRemoveHandle = db_ref.child(DB_DESIGNIDEAS_PATH).observe(.childRemoved, with: { (snapshot) in
            // snapshot.value is a dictionary for one Design Idea
            if let ideaDict = snapshot.value as? [String: AnyObject] {
                let idea = NNDesignIdea.createDesignIdeaFromFirebase(with: ideaDict)
                // find the design idea in our dictionary and remove it
            }
            self.designIdeas.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
        })
        // adding "changed" observer to the design ideas
        designIdeasChangeHandle = db_ref.child(DB_DESIGNIDEAS_PATH).observe(.childChanged, with: { (snapshot) in
            // snapshot.value is a dictionary for one Design Idea
            if let ideaDict = snapshot.value as? [String: AnyObject] {
                let idea = NNDesignIdea.createDesignIdeaFromFirebase(with: ideaDict)
                // find the design idea and replace it with the new one
            }
            self.designIdeas.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
        })
    }
    
    func GetNumDesignIdeas(searchFilter: String) -> Int {
        if searchFilter != "" {
            return self.designIdeas.filter({ (idea) -> Bool in
                if (idea.content.lowercased().range(of: searchFilter.lowercased()) != nil) ||
                    ((GetUser(by: idea.submitter)?.displayName.lowercased().range(of: searchFilter.lowercased())) != nil) {
                    return true
                } else {
                    return false
                }
            }).count
        } else {
            return self.designIdeas.count
        }
    }
    
    func GetDesignIdea(at index: Int, searchFilter: String) -> NNDesignIdea? {
        if searchFilter != "" {
            let listIdeas = self.designIdeas.filter({ (idea) -> Bool in
                if (idea.content.lowercased().range(of: searchFilter.lowercased()) != nil) ||
                    ((GetUser(by: idea.submitter)?.displayName.lowercased().range(of: searchFilter.lowercased())) != nil) {
                    return true
                } else {
                    return false
                }
            })
            if index < listIdeas.count {
                return listIdeas[index]
            }
        } else {
            if index < self.designIdeas.count {
                return self.designIdeas[index]
            }
        }
        return nil
    }
    
    func GetDesignIdeasForUser(with id: String) -> [NNDesignIdea] {
        let listIdea = self.designIdeas.filter { (idea) -> Bool in
            if idea.submitter == id {
                return true
            } else {
                return false
            }
        }
        return listIdea
    }
    
    func GetDesignIdea(with id: String) -> NNDesignIdea? {
        let listIdea = self.designIdeas.filter { (idea) -> Bool in
            return idea.id == id
        }
        if listIdea.count == 1 {
            return listIdea[0]
        }
        return nil
    }

    func AddDesignIdea(idea: NNDesignIdea) {
        if !LoggedIn() { return }
        // add the idea to the path
        let newIdeaRef = db_ref.child(DB_DESIGNIDEAS_PATH).childByAutoId()
        idea.id = newIdeaRef.key
        var c = idea.getDictionaryRepresentation()
        let timestamp = Firebase.ServerValue.timestamp()
        c["created_at"] = timestamp as AnyObject
        c["updated_at"] = timestamp as AnyObject
        newIdeaRef.setValue(c)
        // change the user's latest_contribution
        db_ref.child("\(DB_USERS_PATH)/\(idea.submitter)/\(DB_LATEST_CONTRIBUTION)").setValue(timestamp)
    }

    
    //////////////////////////////////////////////////////////////
    //
    //                          Comments
    //
    //////////////////////////////////////////////////////////////
    
    private func initCommentsObserver() {
        // adding observer to the comments
        commentsHandle = db_ref.child(DB_COMMENTS_PATH).observe(.childAdded, with: { (snapshot) in
            // snapshot.value is a dictionary for one Comment
            if let commentDict = snapshot.value as? [String: AnyObject] {
                let comment = NNComment.createCommentFromFirebase(with: commentDict)
                // we don't bother adding comments that do not have updated_at timestamp. They are possibly test comments.
                if comment.updatedAt != 0 {
                    if comment.isCommentOnObservation {
                        self.commentsOnObservations.append(comment)
                    }
                    if comment.isCommentOnDesignIdea {
                        self.commentsOnDesignIdeas.append(comment)
                    }
                }
            }
            self.commentsOnObservations.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
            self.commentsOnDesignIdeas.sort(by: { (first, second) -> Bool in
                return first.updatedAt.decimalValue > second.updatedAt.decimalValue
            })
        })
    }
    
    func GetCommentsOnDesignIdea(with id: String) -> [NNComment] {
        let commentList = self.commentsOnDesignIdeas.filter { (comment) -> Bool in
            if comment.parentContribution == id {
                return true
            } else {
                return false
            }
        }
        return commentList
    }
    
    func GetCommentsOnObservation(with id: String) -> [NNComment] {
        let commentList = self.commentsOnObservations.filter { (comment) -> Bool in
            if comment.parentContribution == id {
                return true
            } else {
                return false
            }
        }
        return commentList
    }
    
    func WriteCommentOn(context: String, comment: String, contributionId: String) {
        if !LoggedIn() { return }
        if let u = currentUser {
            // adding the comment to the "comments" key
            let newCommentRef = db_ref.child(DB_COMMENTS_PATH).childByAutoId()
            var c = NNComment(comment: comment, commenter: u.uid, id: newCommentRef.key, context: context, parentContrib: contributionId, created: 0, updated: 0).getDictionaryRepresentation()
            let timestamp = Firebase.ServerValue.timestamp()
            c["created_at"] = timestamp as AnyObject
            c["updated_at"] = timestamp as AnyObject
            newCommentRef.setValue(c)
            // adding the comment ref to the contribution (observation or design idea)
            let contributionCommentsRef = db_ref.child("\(context)/\(contributionId)/\(DB_COMMENTS_PATH)/\(newCommentRef.key)")
            contributionCommentsRef.setValue(true)
        }
    }
    
    func ToggleLikeOrDislikeOnObservation(like: Bool, observationId: String) {
        if !LoggedIn() { return }
        if let u = currentUser {
            if let obsv = self.GetObservation(with: observationId) {
                let path = "\(DB_OBSERVATIONS_PATH)/\(observationId)/\(DB_LIKES_PATH)/\(u.uid)"
                if let currentVal = obsv.likes[u.uid] {
                    if currentVal == like {
                        // this situation is either "unlike" or "undislike". In either case we should remove the value
                        db_ref.child(path).removeValue()
                        return
                    }
                }
                // change or create the value to the new value: like
                db_ref.child(path).setValue(like)
            }
        }
    }
    
    func ToggleLikeOrDislikeOnDesignIdea(like: Bool, designIdeaId: String) {
        if !LoggedIn() { return }
        if let u = currentUser {
            if let idea = self.GetDesignIdea(with: designIdeaId) {
                let path = "\(DB_DESIGNIDEAS_PATH)/\(designIdeaId)/\(DB_LIKES_PATH)/\(u.uid)"
                if let currentVal = idea.likes[u.uid] {
                    if currentVal == like {
                        // this situation is either "unlike" or "undislike". In either case we should remove the value
                        db_ref.child(path).removeValue()
                        return
                    }
                }
                // change or create the value to the new value: like
                db_ref.child(path).setValue(like)
            }
        }
    }
}
