//
//  NetworkMonitor.swift
//  ColorApp
//
//  Created by Mayur on 30/07/25.
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                print("Network status changed: \(self.isConnected ? "Online" : "Offline")")
            }
        }
        monitor.start(queue: queue)
    }
}
