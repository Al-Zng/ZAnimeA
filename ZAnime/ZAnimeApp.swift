import Foundation
import SwiftUI

@MainActor
class ZAnimeViewModel: ObservableObject {
    @Published var trendingAnime: [Anime] = []
    @Published var selectedEpisodes: [Episode] = []
    @Published var currentVideoSources: [VideoSource] = []
    @Published var isLoading: Bool = false
    
    func loadHome() async {
        isLoading = true
        do {
            trendingAnime = try await ScraperManager.shared.fetchHome()
        } catch {
            print("Home Load Error: \(error)")
        }
        isLoading = false
    }
    
    func loadDetails(anime: Anime) async {
        isLoading = true
        do {
            selectedEpisodes = try await ScraperManager.shared.fetchEpisodes(animeURL: anime.url)
        } catch {
            print("Detail Load Error: \(error)")
        }
        isLoading = false
    }
    
    func extractVideo(episode: Episode) async {
        isLoading = true
        do {
            currentVideoSources = try await ScraperManager.shared.fetchVideoSources(episodeURL: episode.url)
        } catch {
            print("Video Extraction Error: \(error)")
        }
        isLoading = false
    }
}
