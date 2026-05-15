import SwiftUI
import AVKit

struct PlayerView: View {
    @ObservedObject var viewModel: ZAnimeViewModel
    let episode: Episode
    
    @State private var player: AVPlayer?
    @State private var showControls = true
    @State private var showQualityMenu = false
    @State private var selectedQuality: VideoSource?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView().tint(.red).scaleEffect(2)
            } else if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showControls.toggle() }
                    }
                    .overlay(
                        playerOverlay()
                    )
            } else {
                Text("No Video Source Found")
                    .foregroundColor(.white)
            }
        }
        .task {
            await viewModel.extractVideo(episode: episode)
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        // Find best non-premium quality (e.g., 1080p -> 720p -> 480p)
        guard let source = viewModel.currentVideoSources.first(where: { !$0.premium }) else { return }
        selectedQuality = source
        if let url = URL(string: source.src) {
            player = AVPlayer(url: url)
            player?.play()
        }
    }
    
    private func changeQuality(to source: VideoSource) {
        guard let url = URL(string: source.src), let player = player else { return }
        let currentTime = player.currentTime()
        let newPlayer = AVPlayer(url: url)
        newPlayer.seek(to: currentTime)
        self.player = newPlayer
        self.player?.play()
        self.selectedQuality = source
        self.showQualityMenu = false
    }
    
    @ViewBuilder
    private func playerOverlay() -> some View {
        if showControls {
            ZStack {
                Color.black.opacity(0.5).ignoresSafeArea()
                
                VStack {
                    // Top Bar
                    HStack {
                        Spacer()
                        Button(action: { showQualityMenu.toggle() }) {
                            Text(selectedQuality?.label ?? "Quality")
                                .font(.subheadline).bold()
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    Spacer()
                }
                
                if showQualityMenu {
                    VStack(spacing: 0) {
                        ForEach(viewModel.currentVideoSources.filter { !$0.premium }, id: \.self) { source in
                            Button(action: { changeQuality(to: source) }) {
                                Text(source.label)
                                    .foregroundColor(selectedQuality == source ? .red : .white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.8))
                            }
                            Divider().background(Color.gray)
                        }
                    }
                    .frame(width: 150)
                    .cornerRadius(12)
                }
            }
            .transition(.opacity)
        }
    }
}
