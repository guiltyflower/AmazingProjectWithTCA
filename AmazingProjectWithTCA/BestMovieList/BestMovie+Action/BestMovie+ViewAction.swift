import ComposableArchitecture
import Dependencies
import DependenciesMacros


extension BestMovieFeature {
  func handleViewAction(_ action: BestMovieFeature.Action.ViewAction, state: inout BestMovieFeature.State) -> Effect<Action> {

    switch action{
    case let .favoriteButtonTapped(id):
      if state.isSearching, let i = state.searchResults.firstIndex(where: { $0.id == id }) {
        var movie = state.searchResults[i]
        guard let tid = movie.tmdbID else { return .none }

        let ids = favoriteIDs(from: state.favoriteStore)
        if ids.contains(tid) {
          state.$favoriteStore.withLock { store in
            store.removeAll { $0.tmdbID == tid }
          }
          movie.isFavorite = false
        } else {
          state.$favoriteStore.withLock { store in

            store.removeAll { $0.tmdbID == tid }
            store.append(.init(tmdbID: tid, title: movie.title, posterURL: movie.posterURL))
          }
          movie.isFavorite = true
        }

        state.searchResults[i] = movie

        let newIDs = favoriteIDs(from: state.favoriteStore)
        applyFavorite(newIDs, to: &state.movies)
        applyFavorite(newIDs, to: &state.searchResults)
        return .none
      }


      if let i = state.movies.firstIndex(where: { $0.id == id }) {
        var movie = state.movies[i]
        guard let tid = movie.tmdbID else { return .none }

        let ids = favoriteIDs(from: state.favoriteStore)
        if ids.contains(tid) {
          state.$favoriteStore.withLock { store in
            store.removeAll { $0.tmdbID == tid }
          }
          movie.isFavorite = false
        } else {
          state.$favoriteStore.withLock { store in
            store.removeAll { $0.tmdbID == tid }
            store.append(.init(tmdbID: tid, title: movie.title, posterURL: movie.posterURL))
          }
          movie.isFavorite = true
        }

        state.movies[i] = movie

        let newIDs = favoriteIDs(from: state.favoriteStore)
        applyFavorite(newIDs, to: &state.movies)
        applyFavorite(newIDs, to: &state.searchResults)
      }
      return .none

    case .task:
      return .send(.internal(.fetchMovies))

    case .submitTapped:
      return .send(.internal(.searchTextChanged(state.searchText)))

    case .refreshFavorites:
      let favIDs = Set(state.favoriteStore.map(\.tmdbID))
      applyFavorite(favIDs, to: &state.movies)
      applyFavorite(favIDs, to: &state.searchResults)
      return .none

    }
  }
}



 func favoriteIDs(from store: [FavoriteMovie]) -> Set<Int> {
  Set(store.map(\.tmdbID))
}
