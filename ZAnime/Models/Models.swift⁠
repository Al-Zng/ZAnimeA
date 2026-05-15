import Foundation

struct Anime: Identifiable, Hashable {
    let id: String
    let title: String
    let posterURL: URL?
    let episodeCount: String
    let url: String
}

struct Episode: Identifiable, Hashable {
    let id: String
    let number: String
    let title: String
    let thumbnailURL: URL?
    let url: String
}

struct VideoSource: Identifiable, Decodable, Hashable {
    var id: String { src }
    let src: String
    let type: String
    let label: String
    let res: String
    let premium: Bool
}
