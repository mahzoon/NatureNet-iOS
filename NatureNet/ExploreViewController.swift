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
//    let sample_image1 = UIImage(named: "sample_image1")
//    
//    let sample_latitude2 = 35.292279//39.1949966
//    let sample_longitude2 = -80.750205//-106.8214056
//    let sample_image2 = UIImage(named: "sample_image3")
    
    let width = 100
    let height = 75
    
    var firstTimeLoad = true
    
    var listObservations = [NNObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        searchBar.delegate = self
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
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if firstTimeLoad {
            let initialLocation = CLLocation(latitude: sample_latitude1, longitude: sample_longitude1)
            DispatchQueue.main.async {
                self.centerMapOnLocation(location: initialLocation)
            }
            firstTimeLoad = false
        }
    }
    
    // To center the map on location we need a location (the input parameter) and a region radius. The radius is defined in the Constants.swift file
    func centerMapOnLocation(location: CLLocation) {
        // the parameters: long. and lat. distances, are defined as the region diameter = 2*the region radius
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, MAP_CENTER_REGION_RADIUS * 2.0, MAP_CENTER_REGION_RADIUS * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let v = view.detailCalloutAccessoryView {
            if v.subviews.count > 0 {
                let u = v.subviews[0]
                if u as? UIImageView != nil {
                    let imageView = u as! UIImageView
                    if let observationId = v.accessibilityIdentifier {
                        if let observation = DataService.ds.GetObservation(with: observationId) {
                            // load the observation image
                            MediaManager.md.getOrDownloadImage(requesterId: "\(observationId)", urlString: observation.observationImageUrl, completion: { img, err in
                                if let i = img {
                                    DispatchQueue.main.async {
                                        imageView.image = i
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(self.listObservations)
        self.listObservations = DataService.ds.GetObservations(near: mapView.region, searchFilter: self.searchBar.text ?? "")
        mapView.addAnnotations(self.listObservations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? NNObservation {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EXPLORE_ANNOTATION_ID)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: EXPLORE_ANNOTATION_ID)
                annotationView?.canShowCallout = true
            } else {
                annotationView!.annotation = annotation
            }

            let snapshotView = UIView()
            let widthConstraint = NSLayoutConstraint(item: snapshotView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(self.width))
            snapshotView.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: snapshotView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(self.height))
            snapshotView.addConstraint(heightConstraint)
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
            //imageView.image = annotation.observationImageUrl
            // set the picture here
            snapshotView.addSubview(imageView)
    
            annotationView?.detailCalloutAccessoryView = snapshotView
            (annotationView as! MKPinAnnotationView).pinTintColor = annotation.pinColor
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            snapshotView.addGestureRecognizer(tapGesture)
            snapshotView.accessibilityIdentifier = annotation.id
            
            return annotationView
        }
        return nil
    }
    
    func tapped(id: NSObject) {
        self.performSegue(withIdentifier: SEGUE_DETAILS, sender: id)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchText == "" {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        }
        mapView.removeAnnotations(self.listObservations)
        self.listObservations = DataService.ds.GetObservations(near: mapView.region, searchFilter: self.searchBar.text ?? "")
        mapView.addAnnotations(self.listObservations)
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
            if id == SEGUE_DETAILS {
                if let dest = segue.destination as? GalleryDetailController {
                    if sender as? UITapGestureRecognizer != nil {
                        if let view = (sender as! UITapGestureRecognizer).view {
                            if let observationId = view.accessibilityIdentifier {
                                if let observation = DataService.ds.GetObservation(with: observationId) {
                                    dest.observationObj = observation
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // remove the focus from the search bar if the user clicked on the cross button on the search bar. This will also causes the keyboard to hide.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
