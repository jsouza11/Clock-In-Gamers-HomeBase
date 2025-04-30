//
//  SettingsRowView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/29/25.
//

import SwiftUI

struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
        }
        
    }
}

#Preview {
    SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
