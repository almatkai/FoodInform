//
//  DIPLOMA_SWIFTUIApp.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 14.02.2024.
//

import SwiftUI

@main
struct DIPLOMA_SWIFTUIApp: App {
    
    @StateObject private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(vm: vm)
                .environmentObject(vm)
                .task {
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
    
}
