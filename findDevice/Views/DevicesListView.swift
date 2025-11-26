//
//  DevicesListView.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import SwiftUI

struct DevicesListView: View {
    @ObservedObject var viewModel: ScanViewModel
    // @State больше не нужен
    
    var body: some View {
        List {
            if !viewModel.bluetoothDevices.isEmpty {
                Section("Bluetooth устройства") {
                    ForEach(viewModel.bluetoothDevices) { device in
                        NavigationLink(destination: DeviceDetailView(device: device)) {
                            DeviceRowView(device: device)
                        }
                    }
                }
            }
            
            if !viewModel.lanDevices.isEmpty {
                Section("LAN устройства") {
                    ForEach(viewModel.lanDevices) { device in
                        NavigationLink(destination: DeviceDetailView(device: device)) {
                            DeviceRowView(device: device)
                        }
                    }
                }
            }
            
            if viewModel.allDevices.isEmpty {
                Section {
                    Text("Устройства не найдены")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct DeviceRowView: View {
    let device: Device
    
    var body: some View {
        HStack {
            Image(systemName: device.deviceType == .bluetooth ? "wave.3.right" : "wifi")
                .foregroundColor(device.deviceType == .bluetooth ? .blue : .green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                
                if device.deviceType == .bluetooth {
                    Text("UUID: \(device.uuid)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("RSSI: \(device.rssi) dBm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("IP: \(device.ipAddress)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !device.macAddress.isEmpty {
                        Text("MAC: \(device.macAddress)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            StatusBadgeView(status: device.deviceStatus)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadgeView: View {
    let status: DeviceStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var statusText: String {
        switch status {
        case .connected: return "Подключено"
        case .connecting: return "Подключение"
        case .disconnected: return "Отключено"
        case .unknown: return "Неизвестно"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        case .unknown: return .gray
        }
    }
}

