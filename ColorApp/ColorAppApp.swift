//
//  ColorAppApp.swift
//  ColorApp
//
//  Created by Mayur on 30/07/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

@main
struct ColorApp: App {
    @StateObject private var networkMonitor = NetworkMonitor()
    
    init() {
        
        do {
            try FirebaseApp.configure()
            print("Firebase configured successfully at \(Date())")
        } catch {
            print("Firebase configuration failed: \(error.localizedDescription) at \(Date())")
        }
        
       
        do {
            let factory = DebugAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(factory)
            print("App Check configured with Debug provider at \(Date())")
        } catch {
            print("App Check configuration failed: \(error.localizedDescription) at \(Date())")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ColorViewModel(networkMonitor: networkMonitor))
                .environmentObject(networkMonitor)
        }
    }
}


class DebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppCheckDebugProvider(app: app)
    }
}
