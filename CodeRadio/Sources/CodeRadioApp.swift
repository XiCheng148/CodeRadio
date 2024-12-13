import SwiftUI
import UserNotifications

@main
struct CodeRadioApp: App {
    @StateObject private var player = RadioPlayer()
    
    init() {
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("通知权限已获取")
            } else if let error = error {
                print("获取通知权限失败: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        MenuBarExtra("Code Radio", systemImage: player.isPlaying ? "radio.fill" : "radio") {
            ContentView(player: player)
        }
        .menuBarExtraStyle(.window)
    }
}
