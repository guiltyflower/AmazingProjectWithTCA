import ComposableArchitecture


@Reducer
public struct MovieDetailFeature {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var movie: Movie
    @Shared(.appStorage("favorite_movies")) var favoriteStore: [FavoriteMovie] = []
  }

  public enum Action: Equatable, Sendable {
      case favoriteButtonTapped
      case delegate(Delegate)

      public enum Delegate: Equatable, Sendable {
        case movieUpdated(Movie)
    }
  }



  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .favoriteButtonTapped:
        guard let tid = state.movie.tmdbID else { return .none }
        let ids = Set(state.favoriteStore.map(\.tmdbID))
        if ids.contains(tid) {
          state.$favoriteStore.withLock { store in
            store.removeAll { $0.tmdbID == tid }
          }
          state.movie.isFavorite = false
        } else {
          state.$favoriteStore.withLock { store in
            store.removeAll { $0.tmdbID == tid }
            store.append(.init(
              tmdbID: tid,
              title: state.movie.title,
              posterURL: state.movie.posterURL
            ))
          }
          state.movie.isFavorite = true
        }
        return .send(.delegate(.movieUpdated(state.movie)))


      case .delegate:
        return .none
      }
    }
  }
}
