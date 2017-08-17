//
//  MapViewController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 8/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // reference to the map component
    @IBOutlet weak var mapView: MKMapView!
    
    var firstTimeLoad = true
    
    var listObservations = [NNObservation]()
    
    let locationManager = CLLocationManager()
    
    public var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        mapView.showsUserLocation = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mapView.showsUserLocation = false
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if self.firstTimeLoad {
            let initialLocation = CLLocation(latitude: MAP_INITLOCATION_LATITUDE, longitude: MAP_INITLOCATION_LONGITUDE)
            self.centerMapOnLocation(location: initialLocation)
            // check if we can center map on user location
            self.checkUserLocation()
            self.firstTimeLoad = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DispatchQueue.main.async {
            if !self.firstTimeLoad {
                self.mapView.removeAnnotations(self.listObservations)
                self.listObservations = DataService.ds.GetObservations(near: self.mapView.region, searchFilter: self.searchText)
                self.mapView.addAnnotations(self.listObservations)
            }
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
                            MediaManager.md.getOrDownloadImage(requesterId: "\(observationId)", urlString: observation.getThumbnailUrlWithWidth(width: MAP_ANNOTATION_LAYOVER_WIDTH), completion: { img, err in
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? NNObservation {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EXPLORE_ANNOTATION_ID)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: EXPLORE_ANNOTATION_ID)
            }
            
            annotationView?.annotation = annotation
            annotationView?.canShowCallout = true
            
            let snapshotView = UIView()
            let widthConstraint = NSLayoutConstraint(item: snapshotView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(MAP_ANNOTATION_LAYOVER_WIDTH))
            snapshotView.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: snapshotView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(MAP_ANNOTATION_LAYOVER_HEIGHT))
            snapshotView.addConstraint(heightConstraint)
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: MAP_ANNOTATION_LAYOVER_WIDTH, height: MAP_ANNOTATION_LAYOVER_HEIGHT))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            
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
        self.parent!.performSegue(withIdentifier: SEGUE_DETAILS, sender: id)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let id = segue.identifier {
//            if id == SEGUE_DETAILS {
//                if let dest = segue.destination as? GalleryDetailController {
//                    if sender as? UITapGestureRecognizer != nil {
//                        if let view = (sender as! UITapGestureRecognizer).view {
//                            if let observationId = view.accessibilityIdentifier {
//                                if let observation = DataService.ds.GetObservation(with: observationId) {
//                                    dest.observationObj = observation
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func checkUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            if let loc = self.locationManager.location {
                self.centerMapOnLocation(location: loc)
            }
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    public func reloadData() {
        mapView.removeAnnotations(self.listObservations)
        self.listObservations = DataService.ds.GetObservations(near: mapView.region, searchFilter: self.searchText)
        mapView.addAnnotations(self.listObservations)
    }
}
