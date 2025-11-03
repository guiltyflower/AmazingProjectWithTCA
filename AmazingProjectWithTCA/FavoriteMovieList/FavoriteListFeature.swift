import ComposableArchitecture
import Dependencies
import DependenciesMacros




@Reducer
public struct FavoriteListFeature {
  @ObservableState
  public struct State: Equatable, Sendable {
    var path = StackState<MovieDetailFeature.State>()
    @Shared(.appStorage("favorite_movies")) var favoriteStore: [FavoriteMovie] = []
  }
  public enum Action: Equatable, Sendable {
  
    case removeTapped(tmdbID: Int )
    case path(StackActionOf<MovieDetailFeature>)

  }


  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {


      case let .removeTapped(tmdbID):
        state.$favoriteStore.withLock { store in
          store.removeAll { $0.tmdbID == tmdbID }
        }
        return .none

      case let .path(.element(elementID, action: .delegate(.movieUpdated(movie)))):
        /*if let tid = movie.tmdbID, !movie.isFavorite {
          state.$favoriteStore.withLock { store in
            store.removeAll { $0.tmdbID == tid }
          }
         

          if state.path.ids.last == elementID {
            state.path.removeLast()
          } else if let idx = state.path.ids.firstIndex(of: elementID) {
            state.path.remove(at: idx)
          }

        }*/
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

