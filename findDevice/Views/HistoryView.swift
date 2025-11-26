//
//  HistoryView.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var selectedDevice: Device?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.filteredSessions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("История пуста")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Выполните сканирование, чтобы увидеть историю")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredSessions) { session in
                            NavigationLink {
                                SessionDevicesView(session: session)
                            } label: {
                                SessionRowView(session: session)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteSession(viewModel.filteredSessions[index])
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Поиск по имени устройства")
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.applyFilter()
                    }
                }
            }
            .navigationTitle("История")
            .onAppear {
                viewModel.loadSessions()
            }
        }
    }
}

struct SessionRowView: View {
    let session: ScanSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(session.startTime))
                    .font(.headline)
                Spacer()
                Text("\(session.deviceCount) устройств")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let endTime = session.endTime {
                Text("Длительность: \(formatDuration(session.duration))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct SessionDevicesView: View {
    let session: ScanSession
    
    var body: some View {
        List {
            if session.devices.isEmpty {
                Text("Устройства не найдены")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(Array(session.devices)) { device in
                    NavigationLink(destination: DeviceDetailView(device: device)) {
                        DeviceRowView(device: device)
                    }
                }
            }
        }
        .navigationTitle("Устройства")
        .navigationBarTitleDisplayMode(.inline)
    }
}

