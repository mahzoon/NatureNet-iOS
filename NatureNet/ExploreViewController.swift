//
//  ExploreViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit
import MapKit

class ExploreViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    // reference to the search bar
    @IBOutlet weak var searchBar: UISearchBar!
    // reference to the map component
    @IBOutlet weak var mapView: MKMapView!
    // reference to the profile icon button on the top left corner
    @IBOutlet weak var profileButton: UIButton!
    
    let sample_latitude1 = 35.232279//39.1949966
    let sample_longitude1 = -80.700205//-106.8214056
    let sample_image1 = UIImage(named: "sample_image1")
    
    let sample_latitude2 = 35.292279//39.1949966
    let sample_longitude2 = -80.750205//-106.8214056
    let sample_image2 = UIImage(named: "sample_image3")
    
    let width = 100
    let height = 75
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        searchBar.delegate = self
        
        let initialLocation = CLLocation(latitude: sample_latitude1, longitude: sample_longitude1)
        centerMapOnLocation(location: initialLocation)
        
//        let observation1 = Observation(title: "Trees", pic: sample_image1!,
//                              locationName: "Location Name",
//                              discipline: "More info",
//                              coordinate: CLLocationCoordinate2D(latitude: sample_latitude1, longitude: sample_longitude1), activityId: 0)
//        mapView.addAnnotation(observation1)
//        
//        let observation2 = Observation(title: "Colored turtle", pic: sample_image2!,
//                                      locationName: "Location Name",
//                                      discipline: "More info",
//                                      coordinate: CLLocationCoordinate2D(latitude: sample_latitude2, longitude: sample_longitude2), activityId: 1)
//        mapView.addAnnotation(observation2)
    }
    
    // Whenever this view appears, it should update user's status on the profile icon on the top left corner.
    override func viewWillAppear(_ animated: Bool) {
        // set the status of the user (i.e signed in or not) on the profile icon
        if DataService.ds.LoggedIn() {
            profileButton.setImage(ICON_PROFILE_ONLINE, for: .normal)
        } else {
            profileButton.setImage(ICON_PROFILE_OFFLINE, for: .normal)
        }
    }
    
    // To center the map on location we need a location (the input parameter) and a region radius. The radius is defined in the Constants.swift file
    func centerMapOnLocation(location: CLLocation) {
        // the parameters: long. and lat. distances, are defined as the region diameter = 2*the region radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, MAP_CENTER_REGION_RADIUS * 2.0, MAP_CENTER_REGION_RADIUS * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? NNObservation {
            
            let identifier = "MyCustomAnnotation"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }

            let snapshotView = UIView()
            //let views = ["snapshotView": snapshotView]
            //snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(\(self.width))]", options: [], metrics: nil, views: views))
            //snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(\(self.height))]", options: [], metrics: nil, views: views))
            let widthConstraint = NSLayoutConstraint(item: snapshotView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(self.width))
            snapshotView.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: snapshotView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(self.height))
            snapshotView.addConstraint(heightConstraint)
            
//            let options = MKMapSnapshotOptions()
//            options.size = CGSize(width: width, height: height)
//            options.mapType = .satelliteFlyover
//            
//            options.camera = MKMapCamera(lookingAtCenter: (annotationView!).annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
            
            //let snapshotter = MKMapSnapshotter(options: options)
            //snapshotter.start { snapshot, error in
            //    if snapshot != nil {
                    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    //imageView.image = annotation.Picture
                    // set the picture here
                    snapshotView.addSubview(imageView)
            //    }
            //}
            
            annotationView?.detailCalloutAccessoryView = snapshotView
            (annotationView as! MKPinAnnotationView).pinTintColor = annotation.pinColor
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            snapshotView.addGestureRecognizer(tapGesture)
            
            return annotationView
        }
        return nil
    }
    
    func tapped(id: NSObject) {
        //self.present(, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil && searchText != "" {
            //let lowerText = searchBar.text!.lowercased()
        } else {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        }
    }
    
    // When the profile button is tapped, we need to check if the user is authenticated, if not it should go to the sign in screen
    @IBAction func profileButtonTapped(_ sender: Any) {
        if DataService.ds.LoggedIn() {
            performSegue(withIdentifier: SEGUE_PROFILE, sender: nil)
        } else {
            performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
        }
    }
    
    // In case we needed to go to the profile screen but authentication was required we need to go to the sign in screen and set the "parentVC" and the "successSegueId" so that when the sign in was successful the segue to the profile screen is performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_SIGNIN {
                // the sign in screen is embedded in a nav controller
                let signInNav = segue.destination as! UINavigationController
                // and the nav controller has only one child i.e the sign in view controller
                let signInVC = signInNav.viewControllers.first as! SigninViewController
                signInVC.parentVC = self
                signInVC.successSegueId = SEGUE_PROFILE
            }
        }
    }
    
    // remove the focus from the search bar if the user clicked on the cross button on the search bar. This will also causes the keyboard to hide.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
