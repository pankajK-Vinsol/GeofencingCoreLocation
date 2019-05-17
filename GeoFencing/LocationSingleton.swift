//
//  LocationSingleton.swift
//  GeoFencing
//
//  Created by Pankaj kumar on 17/05/19.
//  Copyright © 2019 Pankaj kumar. All rights reserved.
//

import UIKit
import CoreLocation

class LocationSingleton: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    
    static let sharedInstance:LocationSingleton = {
        let instance = LocationSingleton()
        return instance
    }()
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager?.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            break
        case .restricted:
            // restricted, User can't enable Location Services
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager?.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last!
    }
    
}
