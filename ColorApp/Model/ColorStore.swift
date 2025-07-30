//
//  ColorStore.swift
//  ColorApp
//
//  Created by Mayur on 30/07/25.
//
import Foundation

struct ColorData: Identifiable, Codable {
    let id: UUID
    let hexCode: String
    let timestamp: Date
    var isSynced: Bool
    
    init(id: UUID = UUID(), hexCode: String, timestamp: Date, isSynced: Bool) {
        self.id = id
        self.hexCode = hexCode
        self.timestamp = timestamp
        self.isSynced = isSynced
    }
}

class ColorStore {
    private let storageKey = "savedColors"
    
    func loadColors() -> [ColorData] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("No data found in UserDefaults for key: \(storageKey)")
            return []
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let savedColors = try decoder.decode([ColorData].self, from: data)
            return savedColors
        } catch {
            print("Error decoding colors: \(error)")
            return []
        }
    }
    
    func addColor(_ color: ColorData) {
        var colors = loadColors()
        colors.append(color)
        saveColors(colors)
        print("Saved color: \(color.hexCode)")
    }
    
    func markAsSynced(_ color: ColorData) {
        var colors = loadColors()
        if let index = colors.firstIndex(where: { $0.id == color.id }) {
            colors[index].isSynced = true
            saveColors(colors)
            print("Marked color as synced: \(color.hexCode)")
        }
    }
    
    private func saveColors(_ colors: [ColorData]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(colors)
            UserDefaults.standard.set(data, forKey: storageKey)
            UserDefaults.standard.synchronize()
            print("Saved \(colors.count) colors to UserDefaults")
        } catch {
            print("Error encoding colors: \(error)")
        }
    }
}
