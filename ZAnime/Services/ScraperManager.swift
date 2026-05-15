import Foundation
import SwiftSoup // Requires SPM: https://github.com/scinfu/SwiftSoup.git

class ScraperManager {
    static let shared = ScraperManager()
    private let baseURL = "https://anime3rb.com"
    
    private func getAuthenticatedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue(CloudflareManager.shared.userAgent, forHTTPHeaderField: "User-Agent")
        let cookieHeader = CloudflareManager.shared.cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        return request
    }
    
    func fetchHome() async throws -> [Anime] {
        let url = URL(string: baseURL)!
        let (data, _) = try await URLSession.shared.data(for: getAuthenticatedRequest(url: url))
        let html = String(data: data, encoding: .utf8) ?? ""
        let document = try SwiftSoup.parse(html)
        
        var animes: [Anime] = []
        let cards = try document.select("a.video-card")
        
        for card in cards {
            let href = try card.attr("href")
            let title = try card.select("h3.title-name").text()
            let img = try card.select("img").attr("src")
            let epCount = try card.select("p.number").text()
            
            animes.append(Anime(id: href, title: title, posterURL: URL(string: img), episodeCount: epCount, url: href))
        }
        return animes
    }
    
    func fetchEpisodes(animeURL: String) async throws -> [Episode] {
        let url = URL(string: animeURL)!
        let (data, _) = try await URLSession.shared.data(for: getAuthenticatedRequest(url: url))
        let document = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
        
        var episodes: [Episode] = []
        let list = try document.select(".video-list a")
        
        for ep in list {
            let href = try ep.attr("href")
            let img = try ep.select("img").attr("src")
            let number = try ep.select("div.video-data > div > span").text()
            let title = try ep.select("div.video-data > p").text()
            
            episodes.append(Episode(id: href, number: number, title: title, thumbnailURL: URL(string: img), url: href))
        }
        return episodes
    }
    
    func fetchVideoSources(episodeURL: String) async throws -> [VideoSource] {
        // 1. Fetch Episode Page to find iframe
        let epUrl = URL(string: episodeURL)!
        let (epData, _) = try await URLSession.shared.data(for: getAuthenticatedRequest(url: epUrl))
        let epDoc = try SwiftSoup.parse(String(data: epData, encoding: .utf8) ?? "")
        
        guard let iframeSrc = try epDoc.select("iframe").first()?.attr("src"),
              let playerUrl = URL(string: iframeSrc) else {
            throw URLError(.badURL)
        }
        
        // 2. Fetch Player Page to extract video_sources JSON array
        let (playerData, _) = try await URLSession.shared.data(for: getAuthenticatedRequest(url: playerUrl))
        let playerHtml = String(data: playerData, encoding: .utf8) ?? ""
        
        // Regex to find: var video_sources = [...];
        let pattern = "var video_sources = (\\[.*?\\]);"
        let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let nsString = playerHtml as NSString
        let results = regex.matches(in: playerHtml, range: NSRange(location: 0, length: nsString.length))
        
        guard let match = results.first else { throw URLError(.cannotParseResponse) }
        let jsonString = nsString.substring(with: match.range(at: 1))
        
        let decoder = JSONDecoder()
        let sources = try decoder.decode([VideoSource].self, from: Data(jsonString.utf8))
        
        // Filter out empty sources or premium lockouts based on user state
        return sources.filter { !$0.src.isEmpty }
    }
}
