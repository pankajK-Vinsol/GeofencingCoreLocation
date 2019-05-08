//
//  RegionData.swift
//  GeoFencing
//
//  Created by Pankaj kumar on 07/05/19.
//  Copyright © 2019 Pankaj kumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RegionData: NSObject, Codable, MKAnnotation {
    
    enum EventType: String {
        case onEntry = "Entry"
        case onExit = "Exit"
    }
    
    enum codingKeys: String, CodingKey {
        case latitude, longitude, event, radius, identifier, note
    }
    
    var coordinate: CLLocationCoordinate2D
    var event: EventType
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    
    var title: String? {
        if note.isEmpty {
            return "No Title"
        }
        return note
    }
    var subtitle: String? {
        let text = event.rawValue
        return "\(radius)m - \(text)"
    }
    
    init(event: EventType, coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String) {
        self.coordinate = coordinate
        self.event = event
        self.radius = radius
        self.identifier = identifier
        self.note = note
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingKeys.self)
        let latitude = try values.decode(Double.self, forKey: .latitude)
        let longitude = try values.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        radius = try values.decode(Double.self, forKey: .radius)
        identifier = try values.decode(String.self, forKey: .identifier)
        let eventType = try values.decode(String.self, forKey: .event)
        event = EventType(rawValue: eventType) ?? .onEntry
        note = try values.decode(String.self, forKey: .note)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: codingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(note, forKey: .note)
        try container.encode(event.rawValue, forKey: .event)
    }
}

extension RegionData {
    public class func allRegionsList() -> [RegionData] {
        guard let savedData = UserDefaults.standard.data(forKey: PreferenceKeys.savedRegions) else {
            return []
        }
        let decoder = JSONDecoder()
        if let savedRegions = try? decoder.decode(Array.self, from: savedData) as [RegionData] {
            return savedRegions
        }
        return []
    }
}
