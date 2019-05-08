//
//  ViewController.swift
//  GeoFencing
//
//  Created by Pankaj kumar on 03/05/19.
//  Copyright © 2019 Pankaj kumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct PreferenceKeys {
    static let savedRegions = "savedRegions"
}

class RegionListController: UIViewController {

    @IBOutlet weak private var filterRegionList: UISegmentedControl!
    @IBOutlet weak private var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private var regionData: [RegionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        loadAllRegions()
    }
    
    @IBAction private func zoomCurrentLocation(_ sender: UIButton) {
        mapView.zoomToUserLocation()
    }
    @IBAction private func filterRegionsList(_ sender: UISegmentedControl) {
        //loadAllRegions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRegions" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddRegionsController
            vc.delegate = self
        }
    }

    //MARK: load and save regions data functions.
    private func loadAllRegions() {
        regionData.removeAll()
        let allRegions = RegionData.allRegionsList()
        allRegions.forEach{ add(region: $0)}
        
        //        if filterRegionList.selectedSegmentIndex == 1 {
        //
        //        } else if filterRegionList.selectedSegmentIndex == 2 {
        //
        //        } else {
        //
        //        }
    }
    
    private func saveAllRegions() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(regionData)
            UserDefaults.standard.set(data, forKey: PreferenceKeys.savedRegions)
        }
        catch {
            print("Error in encoding regions data")
        }
    }
    
    // MARK: Functions that update the model/associated views with region changes
    private func add(region: RegionData) {
        regionData.append(region)
        mapView.addAnnotation(region)
        addRadiusOverlay(region: region)
        updateRegionsCount()
    }
    
    private func remove(region: RegionData) {
        guard let index = regionData.firstIndex(of: region) else { return }
        regionData.remove(at: index)
        mapView.removeAnnotation(region)
        removeRadiusOverlay(region: region)
        updateRegionsCount()
    }
    
    private func updateRegionsCount() {
        title = "Regions(\(regionData.count))"
        navigationItem.rightBarButtonItem?.isEnabled = (regionData.count < 20)
    }
    
    // MARK: Map overlay functions
    private func addRadiusOverlay(region: RegionData) {
        mapView?.addOverlay(MKCircle(center: region.coordinate, radius: region.radius))
    }
    
    private func removeRadiusOverlay(region: RegionData) {
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            if circleOverlay.radius == region.radius {
                mapView?.removeOverlay(circleOverlay)
                break
            }
        }
    }
    
    //MARK: Monitoring functions
    private func region(regions: RegionData) -> CLCircularRegion {
        let region = CLCircularRegion(center: regions.coordinate, radius: regions.radius, identifier: regions.identifier)
        region.notifyOnEntry = (regions.event == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    private func startMonitoring(regions: RegionData) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your region is saved but will only be activated once you grant
      permission to access the device location.
      """
            showAlert(withTitle:"Warning", message: message)
        }
        
        let fenceRegion = region(regions: regions)
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    private func stopMonitoring(regions: RegionData) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == regions.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
}

// MARK: - Location Manager Delegate
extension RegionListController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

//MARK: Add Regions Delegate
extension RegionListController: AddRegionsControllerDelegate {
    func addRegionsController(controller: AddRegionsController, coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: RegionData.EventType) {
        controller.dismiss(animated: true, completion: nil)
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let region = RegionData(event: eventType, coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note)
        add(region: region)
        startMonitoring(regions: region)
        saveAllRegions()
    }
}

// MARK: - MapView Delegate
extension RegionListController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myRegions"
        if annotation is RegionData {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteRegion")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let region = view.annotation as! RegionData
        remove(region: region)
        saveAllRegions()
    }
    
}
