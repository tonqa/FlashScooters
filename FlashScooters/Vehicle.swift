//
//  Vehicle.swift
//  FlashScooters
//
//  Created by Alexander Koglin on 23.07.19.
//  Copyright © 2019 Alexander Koglin. All rights reserved.
//

import Foundation

struct Vehicle: Codable {
    let id: Int
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let batteryLevel: Int
    let timestamp: Date
    let price: Int
    let priceTime: Int
    let currency: String
    
    init(id: Int) {
        self.id = id
        self.name = ""
        self.description = ""
        self.latitude = 12444
        self.longitude = 123
        self.batteryLevel = Int(99)
        self.timestamp = Date()
        self.price = 20
        self.priceTime = 100
        self.currency = "EUR"
    }
}
