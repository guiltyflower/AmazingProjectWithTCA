import SwiftUI
import ComposableArchitecture
//TODO: loading 4 movies


@ViewAction(for: BestMovieFeature.self)
struct BestMovieView: View {
@Bindable var store: StoreOf<BestMovieFeature>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
        List {

          if store.isLoading && !store.isSearching {
            VStack(){
              ProgressView("Loading movies")
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
          }

          if store.isSearching && store.isLoadingSearch {
            VStack(){
              ProgressView("Searching...")
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
          }

          if let err = store.searchError, store.isSearching {
            Text("Error: \(err)").foregroundStyle(.red)
          }

          ForEach(store.isSearching ? store.searchResults : store.movies) { movie in
            NavigationLink(state: MovieDetailFeature.State(movie: movie)) {
              HStack(spacing: 12){
                AsyncImage(url: URL(string: movie.posterURL ?? "")) { image in
                  image.resizable().scaledToFill()
                } placeholder: {
                  Circle().fill(.gray.opacity(0.3))
                    .overlay(ProgressView().scaleEffect(0.6))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(radius: 1)

                Text(movie.title).font(.headline)

                Spacer()

                Button {
                  send(.favoriteButtonTapped(id: movie.id))
                } label: {
                  Image(systemName: movie.isFavorite ? "heart.fill" : "heart")
                }
                .buttonStyle(.plain)
                .foregroundStyle(movie.isFavorite ? .red : .secondary)
              }
              .padding(.vertical, 4)
            }
          }

          if store.isSearching,
             !store.isLoadingSearch,
             store.searchResults.isEmpty,
             store.searchError == nil {
            Text("No results").foregroundStyle(.secondary)
          }
        }
        .navigationTitle("Best Movies")
        .onAppear {
          send(.refreshFavorites)
        }
        .searchable(
          text: $store.searchText.sending(\.internal.searchTextChanged),
          placement: .navigationBarDrawer(displayMode: .always),
          prompt: "Search movies"
        )
        .onSubmit(of: .search) {
          send(.submitTapped)
        }
    } destination: { store in
      MovieDetailView(store: store)
    }
    .task {
      send(.task)
    }
  }
}
