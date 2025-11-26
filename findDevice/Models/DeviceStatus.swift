//
//  DeviceStatus.swift
//  findDevice
//
//  Created by Daniel on 26.11.2025.
//

import Foundation

enum DeviceStatus: String, Codable {
    case disconnected
    case connecting
    case connected
    case unknown
}

