//
//  AddRegionsController.swift
//  GeoFencing
//
//  Created by Pankaj kumar on 05/05/19.
//  Copyright © 2019 Pankaj kumar. All rights reserved.
//

import UIKit
import MapKit

protocol AddRegionsControllerDelegate: AnyObject {
    func addRegionsController(controller: AddRegionsController, coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: RegionData.EventType)
}

class AddRegionsController: UIViewController {

    @IBOutlet weak private var save: UIButton!
    @IBOutlet weak private var noteField: UITextField!
    @IBOutlet weak private var radiusField: UITextField!
    @IBOutlet weak private var entryExitField: UISegmentedControl!
    @IBOutlet weak private var mapView: MKMapView!
    
    weak var delegate: AddRegionsControllerDelegate?
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        save.isEnabled = false
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction private func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func textFieldEditingChanged(sender: UITextField) {
        save.isEnabled = !radiusField.text!.isEmpty && !noteField.text!.isEmpty
    }
    
    @IBAction private func saveClick(_ sender: UIButton) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusField.text!) ?? 0
        let identifier = NSUUID().uuidString
        let note = noteField.text
        let eventType: RegionData.EventType = (entryExitField.selectedSegmentIndex == 0) ? .onEntry : .onExit
        delegate?.addRegionsController( controller: self, coordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
    }
    
    @IBAction private func zoomClick(_ sender: UIButton) {
        mapView.zoomToUserLocation()
    }
}

 //MARK: - Location Manager Delegate
extension AddRegionsController: CLLocationManagerDelegate {
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
