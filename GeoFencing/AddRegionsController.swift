//
//  AddRegionsController.swift
//  GeoFencing
//
//  Created by Pankaj kumar on 05/05/19.
//  Copyright © 2019 Pankaj kumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol AddRegionsControllerDelegate: AnyObject {
    func addRegionsController(controller: AddRegionsController, coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: RegionData.EventType)
}

class AddRegionsController: UIViewController {

    @IBOutlet weak private var saveButton: UIButton!
    @IBOutlet weak private var noteField: UITextField!
    @IBOutlet weak private var radiusField: UITextField!
    @IBOutlet weak private var mapView: MKMapView!
    @IBOutlet weak private var entryRadioImage: UIImageView!
    @IBOutlet weak private var exitRadioImage: UIImageView!
    
    weak var delegate: AddRegionsControllerDelegate?
    private var addEntryRegion = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        mapView.zoomToUserLocation(latitudeMeters: 500, longitudeMeters: 500)
    }
    
    @IBAction private func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func textFieldEditingChanged(sender: UITextField) {
        saveButton.isEnabled = !radiusField.text!.isEmpty && !noteField.text!.isEmpty
    }
    
    @IBAction private func entryClick(_ sender: UIButton) {
        entryRadioImage.image = #imageLiteral(resourceName: "checked")
        exitRadioImage.image = #imageLiteral(resourceName: "unchecked")
        addEntryRegion = true
    }
    
    @IBAction private func exitClick(_ sender: UIButton) {
        exitRadioImage.image = #imageLiteral(resourceName: "checked")
        entryRadioImage.image = #imageLiteral(resourceName: "unchecked")
        addEntryRegion = false
    }
    
    @IBAction private func saveClick(_ sender: UIButton) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusField.text!) ?? 0
        let identifier = NSUUID().uuidString
        let note = noteField.text
        let eventType: RegionData.EventType = (addEntryRegion == true) ? .onEntry : .onExit
        delegate?.addRegionsController( controller: self, coordinate: coordinate, radius: radius, identifier: identifier, note: note!, eventType: eventType)
    }
    
    @IBAction private func zoomClick(_ sender: UIButton) {
        mapView.zoomToUserLocation(latitudeMeters: 100, longitudeMeters: 100)
    }
}
