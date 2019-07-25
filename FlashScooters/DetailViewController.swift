//
//  DetailViewController.swift
//  FlashScooters
//
//  Created by Alexander Koglin on 25.07.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var selectedIndex: Int? = nil
    var selectedVehicle: Vehicle? = nil

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descr: UILabel!
    @IBOutlet weak var battery: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchVehicle(at: selectedIndex!) { result in
            switch result {
            case .success(let vehicle):
                print(vehicle)
                DispatchQueue.main.async {
                    self.name.text = vehicle.name
                    self.descr.text = vehicle.description
                    self.battery.text = "\(vehicle.batteryLevel) %"
                    self.time.text = "\(vehicle.timestamp.description)"
                    self.price.text = "\(vehicle.price) \(vehicle.currency)"
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.showAlert(error: error)
                }
            }
        }
        
    }

    @IBAction func dismissDetailView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func fetchVehicle(at index: Int, with completion: @escaping (_ result: Result<Vehicle, LoadingError>) -> Void) {
        
        let url = URL(string: "https://my-json-server.typicode.com/FlashScooters/Challenge/vehicles/\(index)")!
        
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
                let vehicle = try decoder.decode(Vehicle.self, from: data)
                completion(.success(vehicle))
            } catch {
                completion(.failure(.invalidJSON(underlyingError: error)))
            }
        }
        task.resume()
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
