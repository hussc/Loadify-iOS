//
//  NavigationBar.swift
//  Loadify
//
//  Created by Vishweshwaran on 2023-11-23.
//

import SwiftUI

struct LoadifyNavigationBar: ToolbarContent {
    
    @Environment(\.presentationMode) var presentationMode
    
    private let screenHeight: CGFloat
    private let shouldDisableBackButton: Bool
    
    init(_ screenHeight: CGFloat, isBackButtonDisabled: Bool) {
        self.screenHeight = screenHeight
        self.shouldDisableBackButton = isBackButtonDisabled
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Image(systemName: "chevron.backward")
                .font(Font.body.weight(.bold))
                .foregroundColor(LoadifyColors.blueAccent)
                .disabled(shouldDisableBackButton)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        
        ToolbarItem(placement: .principal) {
            LoadifyAssets.loadifyHorizontal
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.050)
        }
    }
}

#Preview {
    NavigationView {
        Color.blue
            .frame(width: 100, height: 100)
            .toolbar {
                LoadifyNavigationBar(750, isBackButtonDisabled: false)
            }
    }
    .preferredColorScheme(.dark)
}
