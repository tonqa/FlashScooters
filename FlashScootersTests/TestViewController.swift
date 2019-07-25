//
//  TestViewController.swift
//  FlashScootersTests
//
//  Created by Alexander Koglin on 25.07.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import XCTest
import MapKit
@testable import FlashScooters

class TestViewController: XCTestCase {

    var viewController = ViewController()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVehicleIsAvailable() {
        
        let vehicle = Vehicle(id: 1234)
        var vehicles = [Vehicle]()
        vehicles.append(vehicle)
        
        let mapView = MKMapView()
        viewController.mapView = mapView
        viewController.updateMap(vehicles)
        
        assert(viewController.vehicleIdToVehicles[1234]!.id == vehicle.id, "Vehicle is available")

    }

}
