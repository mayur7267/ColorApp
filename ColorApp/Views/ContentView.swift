//
//  ContentView.swift
//  ColorApp
//
//  Created by Mayur on 30/07/25.
//
import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ColorViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Network: \(networkMonitor.isConnected ? "Online" : "Offline")")
                        .foregroundColor(networkMonitor.isConnected ? .green : .red)
                    Spacer()
                }
                .padding()
                
                Button(action: { viewModel.generateColor() }) {
                    Text("Generate Color")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.blue , .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button("Refresh") {
                    viewModel.printStoredColors()
                }
                .padding(.horizontal)
                
                
                List(viewModel.colors, id: \.id) { color in
                    ColorCardView(hexCode: color.hexCode, timestamp: color.timestamp)
                }
                .listStyle(.plain)
                .id(refreshID)
                
            }
            .navigationTitle("Color Generator")
            .onAppear {
                viewModel.loadColors()
                refreshID = UUID()
                print("ContentView appeared, colors count: \(viewModel.colors.count)")
            }
            .onChange(of: networkMonitor.isConnected) { newValue in
                if newValue {
                    viewModel.syncColors()
                }
            }
        }
    }
}

struct ColorCardView: View {
    let hexCode: String
    let timestamp: Date
    
    var body: some View {
        ZStack {
            Color(hex: hexCode)
                .cornerRadius(10)
                .frame(height: 100)
            
            VStack {
                Text(hexCode)
                    .foregroundColor(.white)
                    .font(.headline)
                Text(timestamp, style: .date)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ColorViewModel(networkMonitor: NetworkMonitor()))
            .environmentObject(NetworkMonitor())
    }
}
