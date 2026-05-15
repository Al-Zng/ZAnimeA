import SwiftUI

struct AnimeDetailView: View {
    @ObservedObject var viewModel: ZAnimeViewModel
    let anime: Anime
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(alignment: .top, spacing: 16) {
                        AsyncImage(url: anime.posterURL) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle().fill(Color(white: 0.1))
                        }
                        .frame(width: 120)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(anime.title)
                                .font(.title2).bold().foregroundColor(.white)
                            Text("Episodes: \(viewModel.selectedEpisodes.count)")
                                .font(.subheadline).foregroundColor(.gray)
                        }
                    }
                    .padding()
                    
                    Divider().background(Color.gray)
                    
                    // Episodes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Episodes")
                            .font(.headline).foregroundColor(.red)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.selectedEpisodes) { ep in
                            NavigationLink(destination: PlayerView(viewModel: viewModel, episode: ep)) {
                                HStack {
                                    AsyncImage(url: ep.thumbnailURL) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Rectangle().fill(Color(white: 0.1))
                                    }
                                    .frame(width: 120, height: 68)
                                    .cornerRadius(6)
                                    
                                    VStack(alignment: .leading) {
                                        Text(ep.number).font(.headline).foregroundColor(.white)
                                        Text(ep.title).font(.subheadline).foregroundColor(.gray).lineLimit(2)
                                    }
                                    Spacer()
                                    Image(systemName: "play.circle.fill")
                                        .font(.title).foregroundColor(.red)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadDetails(anime: anime)
        }
    }
}
