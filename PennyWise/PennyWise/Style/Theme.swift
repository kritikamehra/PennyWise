//
//  Theme.swift
//  PennyWise
//
//  Created by Kritika Mehra on 06/12/25.
//

import Foundation
import SwiftUI


// MARK: - Color System
enum ColorPalette {
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let primary = Color("Primary")
    static let secondary = Color("Secondary")

    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")

    static let expense = Color.red
    static let income = Color.green.opacity(0.85)
}


// MARK: - Typography
enum FontStyle {
    static let title = Font.system(size: 28, weight: .bold)
    static let heading = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
}


// MARK: - Spacing
enum Spacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
}

enum Radius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
}

// MARK: - Shadow
enum ShadowStyle {
    static let subtle = ShadowStyleConfig(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 4
    )
}

struct ShadowStyleConfig {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
}

extension View {
    func shadow(_ style: ShadowStyleConfig) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
