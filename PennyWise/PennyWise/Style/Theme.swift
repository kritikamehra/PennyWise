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
    static let title = Font.system(.title, design: .rounded)
    static let heading = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
}


// MARK: - Spacing
enum Spacing {
    static let small: CGFloat = 6
    static let medium: CGFloat = 12
    static let large: CGFloat = 20
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
