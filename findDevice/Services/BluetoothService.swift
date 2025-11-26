//
//  BluetoothService.swift
//  findDevice
//
//  Created by Daniel on 26.11.2025.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothService: NSObject, ObservableObject {
    static let shared = BluetoothService()
    
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var errorMessage: String?
    
    private var centralManager: CBCentralManager?
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var scanTimeout: Timer?
    private let scanDuration: TimeInterval = 15.0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard let centralManager = centralManager else { return }
        
        guard centralManager.state == .poweredOn else {
            errorMessage = "Bluetooth недоступен. Пожалуйста, включите Bluetooth в настройках."
            return
        }
        
        isScanning = true
        discoveredPeripherals.removeAll()
        discoveredDevices.removeAll()
        errorMessage = nil
        
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        scanTimeout = Timer.scheduledTimer(withTimeInterval: scanDuration, repeats: false) { [weak self] _ in
            self?.stopScanning()
        }
    }
    
    func stopScanning() {
        centralManager?.stopScan()
        scanTimeout?.invalidate()
        scanTimeout = nil
        isScanning = false
    }
    
    func getRSSI(for peripheral: CBPeripheral) -> Int {
        return peripheral.rssi?.intValue ?? 0
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            errorMessage = "Bluetooth выключен. Пожалуйста, включите Bluetooth."
            stopScanning()
        case .unauthorized:
            errorMessage = "Нет разрешения на использование Bluetooth."
            stopScanning()
        case .unsupported:
            errorMessage = "Bluetooth не поддерживается на этом устройстве."
            stopScanning()
        case .resetting:
            break
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if discoveredPeripherals[peripheral.identifier] == nil {
            discoveredPeripherals[peripheral.identifier] = peripheral
            peripheral.rssi = RSSI
            discoveredDevices.append(peripheral)
        } else {
            peripheral.rssi = RSSI
        }
    }
}

extension CBPeripheral {
    private struct AssociatedKeys {
        static var rssi = "rssi"
    }
    
    var rssi: NSNumber? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rssi) as? NSNumber
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rssi, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

