//
//  ScanSession.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import Foundation
import RealmSwift

class ScanSession: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var startTime: Date = Date()
    @Persisted var endTime: Date?
    @Persisted var devices = List<Device>()
    @Persisted var isCompleted: Bool = false
    
    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    
    var deviceCount: Int {
        devices.count
    }
}

