import ComposableArchitecture

extension BestMovieFeature {
  func handleViewAction(_ action: BestMovieFeature.Action.ViewAction, state: inout BestMovieFeature.State) -> Effect<Action> {

    switch action{
    case let .favoriteButtonTapped(id):
      if state.isSearching, let i = state.searchResults.firstIndex(where: { $0.id == id }) {
        state.searchResults[i].isFavorite.toggle()
        let movie = state.searchResults[i]
        _ = favorites.toggle(movie)
        if let tid = movie.tmdbID,
           let j = state.movies.firstIndex(where: { $0.tmdbID == tid }) {
          state.movies[j].isFavorite = movie.isFavorite
        }
        return .none
      }

      if let i = state.movies.firstIndex(where: { $0.id == id }) {
        state.movies[i].isFavorite.toggle()
        let movie = state.movies[i]
        _ = favorites.toggle(movie)
        if let tid = movie.tmdbID,
           let j = state.searchResults.firstIndex(where: { $0.tmdbID == tid }) {
          state.searchResults[j].isFavorite = movie.isFavorite
        }
      }
      return .none
    case .task:
      return .send(.internal(.fetchMovies))

    case .submitTapped:
      return .send(.internal(.searchTextChanged(state.searchText)))

    case .refreshFavorites:
      let favIDs = Set(favorites.getAllIDs())
      applyFavorite(favIDs, to: &state.movies)
      applyFavorite(favIDs, to: &state.searchResults)
      return .none

    }
  }
}
