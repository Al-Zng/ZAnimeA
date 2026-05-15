import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = ZAnimeViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.trendingAnime) { anime in
                            NavigationLink(destination: AnimeDetailView(viewModel: viewModel, anime: anime)) {
                                AnimeCard(anime: anime)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("ZAnime")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ZAnime").font(.headline).foregroundColor(.red)
                }
            }
        }
        .task {
            await viewModel.loadHome()
        }
    }
}

struct AnimeCard: View {
    let anime: Anime
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: anime.posterURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color(white: 0.1))
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(anime.title)
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(anime.episodeCount)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
