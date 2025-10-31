import ComposableArchitecture
import Dependencies
import DependenciesMacros




@Reducer
public struct FavoriteListFeature {
  @ObservableState
  public struct State: Equatable, Sendable {
    var items: [Movie] = []
    var path = StackState<MovieDetailFeature.State>()
    @Shared(.appStorage("favorite_movies")) var favoriteStore: [FavoriteMovie] = []
  }
  public enum Action: Equatable, Sendable {
    case onAppear
    case removeTapped(id: Movie.ID)
    case path(StackActionOf<MovieDetailFeature>)
    case reload
  }


  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear, .reload:
        state.items = state.favoriteStore.map {
          Movie(tmdbID: $0.tmdbID, title: $0.title, posterURL: $0.posterURL, isFavorite: true)
        }
        return .none

      case let .removeTapped(id):
        guard let tid = state.items.first(where: { $0.id == id })?.tmdbID else { return .none }
        state.$favoriteStore.withLock { store in
          store.removeAll { $0.tmdbID == tid }
        }
        state.items.removeAll { $0.id == id }
        return .none

      case let .path(.element(_, action: .delegate(.movieUpdated(movie)))):
        if let i = state.items.firstIndex(where: { $0.id == movie.id }) {
          state.items[i] = movie
        }
        return .none


      case .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      MovieDetailFeature()
    }
  }
}

