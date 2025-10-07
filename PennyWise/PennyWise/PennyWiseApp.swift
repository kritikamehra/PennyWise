//
//  PennyWiseApp.swift
//  PennyWise
//
//  Created by Kritika Mehra on 04/10/25.
//

import SwiftUI
import SwiftData

@main
struct PennyWiseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Transaction.self])
                .modelContainer(for: [Category.self])
        }
    }
}
