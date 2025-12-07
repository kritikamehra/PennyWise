//
//  SectionHeader.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let systemIcon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.systemIcon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if let icon = systemIcon {
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textSecondary)
            }
            
            Rectangle()
                .frame(height: 0.6)
                .foregroundColor(.secondary.opacity(0.2))
        }
        .padding(.bottom, 4)
    }
}
