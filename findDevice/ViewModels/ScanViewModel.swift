//
//  ScanViewModel.swift
//  findDevice
//
//  Created by Daniel on 26.11.2025.
//

import Foundation
import Combine
import CoreBluetooth
import RealmSwift

class ScanViewModel: ObservableObject {
    @Published var bluetoothDevices: [Device] = []
    @Published var lanDevices: [Device] = []
    @Published var isScanning = false
    @Published var scanProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    private let bluetoothService = BluetoothService.shared
    private let lanService = LANService.shared
    private let databaseService = DatabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    private var currentSession: ScanSession?
    private var progressTimer: Timer?
    private var scanStartTime: Date?
    private let scanDuration: TimeInterval = 15.0
    private var realProgress: Double = 0.0
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        bluetoothService.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peripherals in
                self?.updateBluetoothDevices(from: peripherals)
            }
            .store(in: &cancellables)
        
        bluetoothService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error
                    self?.showError = true
                }
            }
            .store(in: &cancellables)
        
        lanService.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                self?.updateLANDevices(from: devices)
            }
            .store(in: &cancellables)
        
        lanService.$scanProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.realProgress = progress
                self?.updateCombinedProgress()
            }
            .store(in: &cancellables)
        
        lanService.$isScanning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isScanning in
                guard let self = self else { return }
                if !isScanning && self.bluetoothService.isScanning == false && self.currentSession != nil {
                    self.finishScanning()
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            bluetoothService.$isScanning,
            lanService.$isScanning
        )
        .receive(on: DispatchQueue.main)
        .map { $0 || $1 }
        .assign(to: &$isScanning)
        
        lanService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error
                    self?.showError = true
                }
            }
            .store(in: &cancellables)
    }
    
    func startScanning() {
        // очищаем состояние UI
        bluetoothDevices.removeAll()
        lanDevices.removeAll()
        scanProgress = 0.0
        realProgress = 0.0
        errorMessage = nil
        showError = false
        showSuccess = false
        
        // запускаем сервисы
        bluetoothService.startScanning()
        lanService.startScanning()
        
        // если ни один сервис реально не стартанул выходим без сессии и таймера
        if !bluetoothService.isScanning && !lanService.isScanning {
            isScanning = false
            currentSession = nil
            return
        }
        
        // хотя бы один сервис сканирует — создаём сессию и запускаем "общий" прогресс
        currentSession = ScanSession()
        isScanning = true
        scanStartTime = Date()
        startProgressTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) { [weak self] in
            self?.finishScanning()
        }
    }
    
    func stopScanning() {
        stopProgressTimer()
        bluetoothService.stopScanning()
        lanService.stopScanning()
        finishScanning()
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTimeBasedProgress()
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func updateTimeBasedProgress() {
        guard let startTime = scanStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let timeProgress = min(elapsed / scanDuration, 0.95)
        updateCombinedProgress(timeProgress: timeProgress)
    }
    
    private func updateCombinedProgress(timeProgress: Double? = nil) {
        let timeBased = timeProgress ?? {
            guard let startTime = scanStartTime else { return 0.0 }
            let elapsed = Date().timeIntervalSince(startTime)
            return min(elapsed / scanDuration, 0.95)
        }()
        
        scanProgress = max(timeBased, realProgress)
    }
    
    private func finishScanning() {
        stopProgressTimer()
        
        guard let session = currentSession else { return }
        
        session.endTime = Date()
        session.isCompleted = true
        
        scanProgress = 1.0
        
        let allDevices = bluetoothDevices + lanDevices
        for device in allDevices {
            device.scanSessionId = session.id
            databaseService.saveDevice(device)
            session.devices.append(device)
        }
        
        databaseService.saveScanSession(session)
        
        let totalCount = allDevices.count
        successMessage = "Сканирование завершено. Найдено устройств: \(totalCount)"
        showSuccess = true
        
        isScanning = false
        currentSession = nil
        scanStartTime = nil
    }
    
    private func updateBluetoothDevices(from peripherals: [CBPeripheral]) {
        var updatedDevices: [Device] = []
        
        for peripheral in peripherals {
            let device = Device()
            device.name = peripheral.name ?? "Неизвестное устройство"
            device.uuid = peripheral.identifier.uuidString
            device.deviceType = .bluetooth
            device.rssi = bluetoothService.getRSSI(for: peripheral)
            device.deviceStatus = .disconnected
            
            if let existingIndex = bluetoothDevices.firstIndex(where: { $0.uuid == device.uuid }) {
                updatedDevices.append(bluetoothDevices[existingIndex])
                bluetoothDevices[existingIndex].rssi = device.rssi
            } else {
                updatedDevices.append(device)
            }
        }
        
        bluetoothDevices = updatedDevices
    }
    
    private func updateLANDevices(from devices: [LANService.LANDevice]) {
        var updatedDevices: [Device] = []
        
        for lanDevice in devices {
            let device = Device()
            device.name = lanDevice.hostname ?? "Неизвестное устройство"
            device.ipAddress = lanDevice.ipAddress
            device.macAddress = lanDevice.macAddress
            device.deviceType = .lan
            device.deviceStatus = .connected
            
            if let existingIndex = lanDevices.firstIndex(where: { $0.ipAddress == device.ipAddress }) {
                updatedDevices.append(lanDevices[existingIndex])
            } else {
                updatedDevices.append(device)
            }
        }
        
        lanDevices = updatedDevices
    }
    
    var allDevices: [Device] {
        bluetoothDevices + lanDevices
    }
}

