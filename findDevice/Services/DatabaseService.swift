//
//  DatabaseService.swift
//  findDevice
//
//  Created by Daniel on 26.11.2025.
//

import Foundation
import RealmSwift

class DatabaseService {
    static let shared = DatabaseService()
    
    private var realm: Realm?
    
    init() {
        do {
            let config = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { _, _ in }
            )
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
        } catch {
            print("Ошибка инициализации Realm: \(error)")
        }
    }
    
    func saveDevice(_ device: Device) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(device, update: .modified)
            }
        } catch {
            print("Ошибка сохранения устройства: \(error)")
        }
    }
    
    func saveScanSession(_ session: ScanSession) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(session, update: .modified)
            }
        } catch {
            print("Ошибка сохранения сессии сканирования: \(error)")
        }
    }
    
    func getAllScanSessions() -> [ScanSession] {
        guard let realm = realm else { return [] }
        return Array(realm.objects(ScanSession.self).sorted(byKeyPath: "startTime", ascending: false))
    }
    
    func getDevicesForSession(_ sessionId: String) -> [Device] {
        guard let realm = realm else { return [] }
        return Array(realm.objects(Device.self).filter("scanSessionId == %@", sessionId))
    }
    
    func getDevices(filteredBy predicate: NSPredicate) -> [Device] {
        guard let realm = realm else { return [] }
        return Array(realm.objects(Device.self).filter(predicate))
    }
    
    func deleteScanSession(_ session: ScanSession) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.delete(session.devices)
                realm.delete(session)
            }
        } catch {
            print("Ошибка удаления сессии: \(error)")
        }
    }
}

