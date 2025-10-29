import ComposableArchitecture

@Reducer
public struct FavoriteListFeature {
  @ObservableState
  public struct State: Equatable, Sendable {
    var items: [Movie] = []
  }
  public enum Action: Equatable, Sendable {
    case onAppear
    case removeTapped(id: Movie.ID)
    case reload
  }

  @Dependency(\.favorites) var favorites

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear, .reload:
        state.items = favorites.getAllMovies()
        return .none

      case let .removeTapped(id):
        guard let tmdbID = state.items.first(where: { $0.id == id })?.tmdbID else {
          return .none
        }
        state.items = favorites.remove(tmdbID)
        return .none
      }    }
  }
}

