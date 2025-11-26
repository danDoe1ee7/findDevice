//
//  HistoryViewModel.swift
//  findDevice
//
//  Created by Daniel on 25.11.2025.
//

import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var scanSessions: [ScanSession] = []
    @Published var filteredSessions: [ScanSession] = []
    @Published var searchText = ""
    @Published var selectedSession: ScanSession?
    
    private let databaseService = DatabaseService.shared
    
    init() {
        loadSessions()
    }
    
    func loadSessions() {
        scanSessions = databaseService.getAllScanSessions()
        applyFilter()
    }
    
    func applyFilter() {
        if searchText.isEmpty {
            filteredSessions = scanSessions
        } else {
            filteredSessions = scanSessions.filter { session in
                session.devices.contains { device in
                    device.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    func deleteSession(_ session: ScanSession) {
        databaseService.deleteScanSession(session)
        loadSessions()
    }
    
    func getDevicesForSession(_ session: ScanSession) -> [Device] {
        return Array(session.devices)
    }
}

