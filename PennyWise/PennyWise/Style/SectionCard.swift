//
//  SectionCard.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//
import SwiftUI

struct Card<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            content()
        }
        .padding(.all, Spacing.medium)
        .background(ColorPalette.surface)
        .cornerRadius(Radius.medium)
        .shadow(ShadowStyle.subtle)
    }
}
