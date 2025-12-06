//
//  Button.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(FontStyle.heading)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.medium)
                .background(ColorPalette.primary)
                .cornerRadius(Radius.medium)
        }
    }
}
