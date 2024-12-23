import SwiftUI
import AVFoundation
import UserNotifications

public struct Song: Codable {
    public let text: String
    public let artist: String
    public let title: String
    public let art: String
}

struct NowPlaying: Codable {
    let duration: Int
    let elapsed: Int
    let song: Song
}

struct RadioResponse: Codable {
    let now_playing: NowPlaying
    let song_history: [HistoryItem]
    let listeners: Listeners
}

struct HistoryItem: Codable {
    let song: Song
}

struct Listeners: Codable {
    let current: Int
}

public class RadioPlayer: ObservableObject {
    @Published public var isPlaying = false
    @Published public var volume: Double = 0.5
    @Published public var currentSong: Song?
    @Published public var progress: Double = 0
    @Published public var history: [Song] = []
    @Published public var duration: Int = 0
    @Published public var elapsed: Int = 0
    @Published public var isLoading = true
    public var hasInitialized = false
    @Published public var currentListeners: Int = 0
    
    private var player: AVPlayer?
    private var progressTimer: Timer?
    
    public init() {
        setupPlayer()
        fetchNowPlaying { [weak self] in
            self?.isLoading = false
            self?.hasInitialized = true
            self?.togglePlayPause()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: "https://coderadio-admin-v2.freecodecamp.org/listen/coderadio/radio.mp3") else { return }
        player = AVPlayer(url: url)
    }
    
    private func setupProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            self.elapsed += 1
            if self.elapsed >= self.duration {
                // 如果超过当前歌曲时长，重新获取数据
                self.fetchNowPlaying()
            } else {
                self.progress = Double(self.elapsed) / Double(self.duration)
            }
        }
    }
    
    public func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            player?.play()
            setupProgressTimer()
        } else {
            player?.pause()
            progressTimer?.invalidate()
        }
    }
    
    public func setVolume(_ value: Double) {
        volume = value
        player?.volume = Float(value)
    }
    
    public func fetchNowPlaying(completion: (() -> Void)? = nil) {
        guard let url = URL(string: "https://coderadio-admin-v2.freecodecamp.org/api/nowplaying_static/coderadio.json") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            if let response = try? JSONDecoder().decode(RadioResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.currentSong = response.now_playing.song
                    self?.duration = response.now_playing.duration
                    self?.elapsed = response.now_playing.elapsed
                    self?.progress = Double(response.now_playing.elapsed) / Double(response.now_playing.duration)
                    self?.history = response.song_history.map { $0.song }
                    self?.currentListeners = response.listeners.current
                    completion?()
                }
            }
        }.resume()
    }
    
    public func downloadArtwork(from urlString: String) {
        guard let url = URL(string: urlString),
              let downloadsURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            showNotification(title: "下载失败", body: "无法获取下载路径")
            return
        }
        
        let destination = downloadsURL.appendingPathComponent("artwork_\(Date().timeIntervalSince1970).jpg")
        
        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showNotification(title: "下载失败", body: error.localizedDescription)
                }
                return
            }
            
            guard let tempURL = tempURL else { return }
            
            do {
                try FileManager.default.moveItem(at: tempURL, to: destination)
                DispatchQueue.main.async {
                    self.showNotification(title: "下载成功", body: "封面已保存到桌面")
                }
            } catch {
                DispatchQueue.main.async {
                    self.showNotification(title: "下载失败", body: error.localizedDescription)
                }
            }
        }.resume()
    }
    
    private func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // 设置通知的图标
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            content.userInfo = [
                "NSApplicationBundleIdentifier": bundleIdentifier,
                "NSApplicationName": "CodeRadio"
            ]
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            }
        }
    }
}

public struct ContentView: View {
    @ObservedObject var player: RadioPlayer
    
    public init(player: RadioPlayer) {
        self.player = player
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // 自定义播放按钮视图
    private var PlayPauseButton: some View {
        Button(action: player.togglePlayPause) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.white)
                    .offset(x: player.isPlaying ? 0 : 2)
            }
            .shadow(radius: 2)
            .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private var ScrollIndicator: some View {
        VStack(spacing: 0) {
            // 顶部分割线
            LinearGradient(
                colors: [.secondary.opacity(0.1), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)
            
            Spacer()
            
            // 底部分割线
            LinearGradient(
                colors: [.clear, .secondary.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 1)
        }
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // 封面
            if let artURL = player.currentSong?.art {
                AsyncImage(url: URL(string: artURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 196, height: 196)
                .cornerRadius(8)
                .onTapGesture(count: 2) {
                    player.downloadArtwork(from: artURL)
                }
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            
            // 歌曲信息
            VStack {
                Text(player.currentSong?.title ?? "Loading...")
                    .font(.headline)
                    .lineLimit(1)
                Text(player.currentSong?.artist ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            
            // 进度条和时间
            VStack(spacing: 4) {
                ProgressView(value: player.progress)
                    .frame(maxWidth: .infinity)
                    .tint(Color.accentColor)
                
                HStack {
                    Text(formatTime(player.elapsed))
                        .font(.caption)
                        .monospacedDigit()
                    Spacer()
                    Text(formatTime(player.duration))
                        .font(.caption)
                        .monospacedDigit()
                }
            }
            
            // 控制按钮
            HStack(alignment: .center) {
                // 左侧听众数量显示
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(player.currentListeners)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 50)
                
                Spacer()
                
                // 中间播放暂停按钮
                PlayPauseButton
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                
                Spacer()
                
                // 右侧音量控制
                Slider(
                    value: Binding(
                        get: { player.volume },
                        set: { player.setVolume($0) }
                    ),
                    in: 0.0...1.0,
                    step: 0.2
                )
                .frame(width: 50)
                .tint(Color.accentColor)
                .onHover { hovering in
                    if hovering {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            // 历史记录
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(player.history, id: \.text) { song in
                        HStack(spacing: 8) {
                            AsyncImage(url: URL(string: song.art)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(4)
                            .onTapGesture(count: 2) {
                                player.downloadArtwork(from: song.art)
                            }
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .font(.caption)
                                    .lineLimit(1)
                                Text(song.artist)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 120)
            .overlay(ScrollIndicator)
            
            // 退出按钮
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .padding(.top, 2)
        }
        .padding(12)
        .frame(width: 220)
        .onAppear {
            if player.currentSong == nil {
                player.fetchNowPlaying()
            }
        }
        .overlay(Group {
            if player.isLoading {
                Color(NSColor.windowBackgroundColor)
                    .opacity(0.8)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
        })
    }
}

// 添加 ScrollView.EdgeMask 扩展
extension ScrollView {
    struct EdgeMask: View {
        var body: some View {
            VStack(spacing: 0) {
                Color.black
                    .frame(height: 20)
                    .opacity(0.5)
                
                Color.black
                    .opacity(0)
                
                Color.black
                    .frame(height: 20)
                    .opacity(0.5)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(player: RadioPlayer())
    }
}
