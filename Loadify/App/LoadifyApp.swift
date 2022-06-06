//
//  LoadifyApp.swift
//  Loadify
//
//  Created by Vishweshwaran on 5/7/22.
//

import SwiftUI
import LoadifyKit
import SwiftDI

@main
struct LoadifyApp: App {
    
    @StateObject var urlViewModel = DownloaderViewModel()
    @StateObject var alertAction: AlertViewAction = .init()
    
    init() {
        SwiftDI.shared.setupDependencyInjection()
    }
    
    var body: some Scene {
        WindowGroup {
            URLView<DownloaderViewModel>()
                .embedInNavigation()
                .environmentObject(alertAction)
                .environmentObject(urlViewModel)
                .addAlertView(for: alertAction)
                .preferredColorScheme(.dark)
        }
    }
}
