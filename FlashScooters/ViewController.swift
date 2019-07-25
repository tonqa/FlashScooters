//
//  ViewController.swift
//  FlashScooters
//
//  Created by Alexander Koglin on 23.07.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import UIKit
import MapKit

enum LoadingError: Error {
    case networkError(underlyingError: Error)
    case invalidResponse
    case invalidJSON(underlyingError: Error)
}

/**
 * Entry page view controller showing vehicles on a map.
 */
class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet public weak var mapView: MKMapView!
        
    public var vehicleIdToVehicles = [Int: Vehicle]()
    public var vehicleIdToAnnotation = [Int: MKAnnotation]()

    var selectedVehicle: Vehicle? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchVehicles { result in
            switch result {
            case .success(let vehicles):
                print(vehicles)
                self.updateMap(vehicles)
            case .failure(let error):
                print(error)
                self.showAlert(error: error)
            }
        }

    }

    override func viewDidLayoutSubviews() {

        var region : MKCoordinateRegion = MKCoordinateRegion()
        
        let minLatitude = 52.400
        let minLongitude = 13.28
        let maxLatitude = minLatitude + 0.25
        let maxLongitude = minLongitude + 0.25
        
        region.center.latitude = (minLatitude + maxLatitude) / 2.0
        region.center.longitude = (minLongitude + maxLongitude) / 2.0
        region.span.latitudeDelta = (maxLatitude - minLatitude)
        region.span.longitudeDelta = (maxLongitude - minLongitude)

        let scaledRegion = self.mapView.regionThatFits(region)
        mapView.setRegion(scaledRegion, animated: true)
        mapView.delegate = self
        
    }
    
    func fetchVehicles(with completion: @escaping (_ result: Result<[Vehicle], LoadingError>) -> Void) {
        
        let url = URL(string: "https://my-json-server.typicode.com/FlashScooters/Challenge/vehicles")!
        
        // Reference to Shared Session
        let session = URLSession.shared
        
        // Create Data Task
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                completion(.failure(.networkError(underlyingError: error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode >= 200,
                response.statusCode < 300,
                let data = data else
            {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let vehicles = try decoder.decode([Vehicle].self, from: data)
                completion(.success(vehicles))
            } catch {
                completion(.failure(.invalidJSON(underlyingError: error)))
            }
        }
        task.resume()
    }

    public func updateMap(_ vehicles: ([Vehicle])) {
        
        for i in 0 ..< vehicles.count {
            
            let vehicle = vehicles[i]
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(
                latitude: vehicle.latitude,
                longitude: vehicle.longitude)
            annotation.coordinate = centerCoordinate
            annotation.title = vehicle.description
            self.mapView.addAnnotation(annotation)
            vehicleIdToVehicles[vehicle.id] = vehicle
            vehicleIdToAnnotation[vehicle.id] = annotation
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        self.selectedVehicle = self.lookupVehicleByAnnotation(annotationFromView: view.annotation)!
        self.performSegue(withIdentifier: "ShowModal", sender: self);
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowModal" {
            if  let vehicle = selectedVehicle,
                let viewController = segue.destination as? DetailViewController {
                
                viewController.selectedIndex = selectedVehicle?.id
                viewController.selectedVehicle = vehicle
            }
        }
    }
    
    private func lookupVehicleByAnnotation(annotationFromView: MKAnnotation?) -> Vehicle? {
        
        var iterator = vehicleIdToAnnotation.makeIterator()
        if let annotationFromView = annotationFromView {
            while let (vehicleId, annotation) = iterator.next() {
                if annotationFromView === annotation {
                    return self.vehicleIdToVehicles[vehicleId]
                }
            }
        }
        return nil

    }
    
    private func showAlert(error: Error) {
        
        let loadingError = error as? LoadingError
        var title : String? = nil
        switch loadingError {
            case .networkError?: title = "Network error"
            case .invalidResponse?: title = "Response invalid"
            case .invalidJSON?: title = "Response invalid"
            default: title = "Error occurred"
        }
        
        var message : String? = nil
        message = "Please restart to reload the data.\n" +
            error.localizedDescription

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)

    }

}

