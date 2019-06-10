//
//  ViewController.swift
//  LocationTrackingUsingMapKit
//
//  Created by Meenal Kewat on 6/8/19.
//  Copyright © 2019 Meenal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager!
    var previousLocation:CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        // user activated automatic authorization info mode
        
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indecating location authorization required
            //and offer to take the user to setting for the app via UIApplication -openUrl: and UIApplicationOpenSettingsUrlString
            
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        
        
        //mapview setup to show user location
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    }
    
    
    //function to add annotation to map view
    func addAnnotationsOnMap(locationToPoint : CLLocation){
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemrak = placemarks[0]
                var addressDictionary = placemrak.addressDictionary
                annotation.title = addressDictionary?["Name"] as? String
                
                self.mapView.addAnnotation(annotation)
            }
        })
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
      
        
        for c in locations{
        
            var co = c.coordinate
            let polyLine = MKPolyline(coordinates: &co, count: locations.count)
            self.mapView.addOverlay(polyLine)
            
             //calculation for location selection and pointing annotation
            if (previousLocation as CLLocation?) != nil{
                 //case if previous location exists
                if previousLocation.distance(from: c) > 200 {
                    addAnnotationsOnMap(locationToPoint: c)
                    previousLocation = c
                }
            }else{
                // in case previous location doesn't exist
                addAnnotationsOnMap(locationToPoint: c)
                previousLocation = c
            }
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var pr:MKPolylineRenderer?
        if (overlay is MKPolyline){
             pr = MKPolylineRenderer(overlay: overlay)
            pr?.strokeColor = UIColor.blue
            pr?.lineWidth = 5
          
        }
        return pr!
    }
    

    

    


}

