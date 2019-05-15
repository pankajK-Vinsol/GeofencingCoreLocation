
import UIKit
import MapKit

extension UIViewController {
  func showAlert(withTitle title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension MKMapView {
    func zoomToUserLocation(latitudeMeters: Double, longitudeMeters: Double) {
    guard let coordinate = userLocation.location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: latitudeMeters, longitudinalMeters: latitudeMeters)
    setRegion(region, animated: true)
  }
}
