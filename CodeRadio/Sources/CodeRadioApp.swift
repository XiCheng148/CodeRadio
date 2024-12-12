import SwiftUI

@main
struct CodeRadioApp: App {
    @StateObject private var player = RadioPlayer()
    
    var body: some Scene {
        MenuBarExtra("Code Radio", systemImage: player.isPlaying ? "radio.fill" : "radio") {
            ContentView(player: player)
        }
        .menuBarExtraStyle(.window)
    }
}
