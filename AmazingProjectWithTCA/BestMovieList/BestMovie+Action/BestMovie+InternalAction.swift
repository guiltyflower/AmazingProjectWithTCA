import ComposableArchitecture
import Foundation

extension BestMovieFeature {
  func handleInternalAction(_ action: Action.Internal, state: inout BestMovieFeature.State) -> Effect<Action> {

    switch action{
    case .fetchMovies:
      guard state.movies.isEmpty else {
        return .none
      }
      state.isLoading.toggle()
      return .run { send in
        try await Task.sleep(for: .milliseconds(50))
        let movies = try await movieAPI.fetchPopular(page: 1)
        await send(.internal(.setMovies(movies)))
      }

    case .setMovies(let movies):
      var list = movies
      let ids = Set(state.favoriteStore.map(\.tmdbID))
      applyFavorite(ids, to: &list)
      state.movies = list
      state.isLoading = false
      return .none



    case let .searchTextChanged(text):
      state.searchText = text
      state.searchError = nil

      let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
      state.isSearching = !trimmed.isEmpty

      guard state.isSearching else {
        state.searchResults = []
        state.isLoadingSearch = false
        return .cancel(id: CancelID.search)
      }

      state.isLoadingSearch = true
      return .run { [trimmed] send in
        try await Task.sleep(for: .milliseconds(500))
        do {
          let results = try await movieSearch.search(query: trimmed, page: 1)
          await send(.internal(.searchResponse(results)))
        } catch {
          await send(.internal(.searchResponseFail(error.localizedDescription)))
        }
      }
      .cancellable(id: CancelID.search, cancelInFlight: true)

    case let .searchResponse(results):
      state.isLoadingSearch = false
      var res = results
      let ids = Set(state.favoriteStore.map(\.tmdbID))
      applyFavorite(ids, to: &res)
      state.searchResults = res
      state.searchError = nil
      return .none

    case .searchResponseFail(let error ):
      state.searchResults = []
      state.searchError = error
      return .none
    }
  }
}
