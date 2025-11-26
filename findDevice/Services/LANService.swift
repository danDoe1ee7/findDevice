//
//  LANService.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import Foundation
import Combine
import LanScanner
import Network

class LANService: NSObject, ObservableObject {
    static let shared = LANService()
    
    @Published var discoveredDevices: [LANDevice] = []
    @Published var isScanning = false
    @Published var errorMessage: String?
    @Published var scanProgress: Double = 0.0
    
    private var scanner: LanScanner?
    private var scanTimeout: Timer?
    private let scanDuration: TimeInterval = 15.0
    private let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private let monitorQueue = DispatchQueue(label: "LANServiceMonitorQueue")
    
    struct LANDevice: Identifiable {
        let id = UUID()
        let ipAddress: String
        let macAddress: String
        let hostname: String?
    }
    
    override init() {
        super.init()
        monitor.start(queue: monitorQueue)
    }
    
    func startScanning() {
        let path = monitor.currentPath
        if path.status != .satisfied {
            isScanning = false
            errorMessage = "Нет доступа к локальной сети. Подключитесь к Wi‑Fi."
            return
        }
        
        isScanning = true
        discoveredDevices.removeAll()
        scanProgress = 0.0
        errorMessage = nil
        
        scanner = LanScanner(delegate: self)
        scanner?.start()
        
        scanTimeout = Timer.scheduledTimer(withTimeInterval: scanDuration, repeats: false) { [weak self] _ in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        scanner?.stop()
        scanTimeout?.invalidate()
        scanTimeout = nil
        isScanning = false
        scanProgress = 1.0
    }
    
}

extension LANService: LanScannerDelegate {
    func lanScanHasUpdatedProgress(_ progress: CGFloat, address: String) {
        DispatchQueue.main.async { [weak self] in
            self?.scanProgress = Double(progress)
        }
    }
    
    func lanScanDidFindNewDevice(_ device: LanDevice) {
        let lanDevice = LANDevice(
            ipAddress: device.ipAddress,
			macAddress: device.mac,
            hostname: device.name
        )
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.discoveredDevices.contains(where: { $0.ipAddress == lanDevice.ipAddress }) {
                self.discoveredDevices.append(lanDevice)
            }
        }
    }
    
    func lanScanDidFinishScanning() {
        DispatchQueue.main.async { [weak self] in
            self?.isScanning = false
            self?.scanTimeout?.invalidate()
            self?.scanProgress = 1.0
        }
    }
}

