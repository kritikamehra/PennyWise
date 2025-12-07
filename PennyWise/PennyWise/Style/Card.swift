//
//  SectionCard.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//
import SwiftUI

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(Color.surface)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

