//
//  ColorViewModel.swift
//  ColorApp
//
//  Created by Mayur on 30/07/25.
//
import Foundation
import FirebaseFirestore
import Combine

class ColorViewModel: ObservableObject {
    @Published var colors: [ColorData] = []
    private let colorStore: ColorStore
    private let db = Firestore.firestore()
    private var networkMonitor: NetworkMonitor
    
    init(networkMonitor: NetworkMonitor) {
        self.colorStore = ColorStore()
        self.networkMonitor = networkMonitor
        loadColors() // Load colors at initialization
    }
    
    func loadColors() {
        let loadedColors = colorStore.loadColors()
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.colors = loadedColors
            print("Loaded \(loadedColors.count) colors: \(loadedColors.map { $0.hexCode })")
        }
    }
    
    func generateColor() {
        let hexCode = String(format: "#%06X", (Int.random(in: 0...0xFFFFFF)))
        let newColor = ColorData(id: UUID(), hexCode: hexCode, timestamp: Date(), isSynced: false)
        colorStore.addColor(newColor)
        loadColors()
        print("Generated new color: \(hexCode)")
        
        if networkMonitor.isConnected {
            syncColors()
        }
    }
    
    func syncColors() {
        let unsyncedColors = colors.filter { !$0.isSynced }
        guard !unsyncedColors.isEmpty else {
            print("No unsynced colors to sync")
            return
        }
        
        for color in unsyncedColors {
            db.collection("colors").addDocument(data: [
                "hexCode": color.hexCode,
                "timestamp": Timestamp(date: color.timestamp)
            ]) { error in
                if let error = error {
                    print("Error syncing color: \(error)")
                } else {
                    self.colorStore.markAsSynced(color)
                    self.loadColors()
                    print("Synced color: \(color.hexCode)")
                }
            }
        }
    }
    
    func printStoredColors() {
        let storedColors = colorStore.loadColors()
        print("Stored colors in UserDefaults: \(storedColors.map { $0.hexCode })")
    }
}
