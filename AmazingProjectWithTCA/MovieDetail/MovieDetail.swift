import ComposableArchitecture


@Reducer
public struct MovieDetailFeature {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var movie: Movie
  }

  public enum Action: Equatable, Sendable {
      case favoriteButtonTapped
      case delegate(Delegate)

      public enum Delegate: Equatable, Sendable {
        case movieUpdated(Movie)
    }
  }

  @Dependency(\.favoritesService) var favorites


  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .favoriteButtonTapped:
        state.movie.isFavorite.toggle()
        favorites.toggle(state.movie)
        return .send(.delegate(.movieUpdated(state.movie)))


      case .delegate:
        return .none
      }
    }
  }
}
