//
//  DeviceDetailView.swift
//  findDevice
//
//  Created by Daniel on 26.11.2025.
//

import SwiftUI

struct DeviceDetailView: View {
    let device: Device
    
    var body: some View {
        List {
            Section("Основная информация") {
                DetailRow(title: "Имя", value: device.name)
                DetailRow(title: "Тип", value: device.deviceType == .bluetooth ? "Bluetooth" : "LAN")
                DetailRow(title: "Статус", value: statusText)
            }
            
            if device.deviceType == .bluetooth {
                Section("Bluetooth информация") {
                    DetailRow(title: "UUID", value: device.uuid)
                    DetailRow(title: "RSSI", value: "\(device.rssi) dBm")
                }
            } else {
                Section("Сетевая информация") {
                    DetailRow(title: "IP адрес", value: device.ipAddress)
                    if !device.macAddress.isEmpty {
                        DetailRow(title: "MAC адрес", value: device.macAddress)
                    }
                }
            }
            
            Section("Дополнительно") {
                DetailRow(title: "Дата создания", value: formatDate(device.createdAt))
            }
        }
        .navigationTitle("Детали устройства")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusText: String {
        switch device.deviceStatus {
        case .connected: return "Подключено"
        case .connecting: return "Подключение"
        case .disconnected: return "Отключено"
        case .unknown: return "Неизвестно"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

