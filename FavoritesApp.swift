// FavoritesApp.swift : Favorites
// Copyright © 2025 Auburn University. All Rights Reserved.
import SwiftUI

@main
struct FavoritesApp: App {
    @AppStorage("preferredTheme") private var preferredTheme = "system"

    private var colorScheme: ColorScheme? {
        switch preferredTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
        }
    }
}
