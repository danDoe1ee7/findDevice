//
//  Device.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import Foundation
import RealmSwift

class Device: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String = ""
	@Persisted var type: String = DeviceType.bluetooth.rawValue
    @Persisted var uuid: String = ""
    @Persisted var ipAddress: String = ""
    @Persisted var macAddress: String = ""
    @Persisted var rssi: Int = 0
	@Persisted var status: String = DeviceStatus.unknown.rawValue
    @Persisted var scanSessionId: String = ""
    @Persisted var createdAt: Date = Date()
    
    var deviceType: DeviceType {
        get { DeviceType(rawValue: type) ?? .bluetooth }
        set { type = newValue.rawValue }
    }
    
    var deviceStatus: DeviceStatus {
        get { DeviceStatus(rawValue: status) ?? .unknown }
        set { status = newValue.rawValue }
    }
}

