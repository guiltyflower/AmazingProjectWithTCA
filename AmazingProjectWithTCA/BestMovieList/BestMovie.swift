import ComposableArchitecture
import Foundation
import SwiftUI


public struct Movie: Identifiable, Equatable, Sendable {
  public let id: UUID
  public let tmdbID: Int?
  public var title: String
  public var posterURL: String?
  public var isFavorite: Bool


  public init(id: UUID = .init(), tmdbID: Int? = nil, title: String, posterURL: String? = nil, isFavorite: Bool = false) {
    self.id = id
    self.tmdbID = tmdbID
    self.title = title
    self.posterURL = posterURL
    self.isFavorite = isFavorite

  }
}

@Reducer
public struct BestMovieFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    var isLoading = false
    var movies: [Movie] = []
    var path = StackState<MovieDetailFeature.State>()

    var searchText: String = ""
    var searchResults: [Movie] = []
    var isSearching: Bool = false
    var isLoadingSearch: Bool = false
    var searchError: String?
  }

  @CasePathable
  public enum Action: Equatable,Sendable, ViewAction, BindableAction {
    case `internal`(Internal)
    case view(View)
    case path(StackActionOf<MovieDetailFeature>)
    case binding(BindingAction<State>)

    @CasePathable
    public enum Internal: Equatable, Sendable {
      case fetchMovies
      case setMovies([Movie])
      case searchResponseFail(String)
      case searchResponse([Movie])
      case searchTextChanged(String)
    }

    @CasePathable
    public enum View: Equatable, Sendable {
      case favoriteButtonTapped(id: Movie.ID)
      case submitTapped
      case task
      case refreshFavorites
    }
  }

  public enum CancelID {
    case search
  }

  @Dependency(\.movieAPI) var movieAPI
  @Dependency(\.movieSearch) var movieSearch
  @Dependency(\.favoritesService) var favorites


  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {

      case .binding:
        return .none

      case .internal(let internalAction):
        return handleInternalAction(internalAction, state: &state)

      case .view(let viewAction):
        return handleViewAction(viewAction, state: &state)


      case let .path(.element(_, action: .delegate(.movieUpdated(movie)))):
        if let i = state.movies.firstIndex(where: { $0.id == movie.id }) {
          state.movies[i] = movie
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


 func applyFavorite(_ ids: Set<Int>, to list: inout [Movie]) {
  for i in list.indices {
    if let tid = list[i].tmdbID {
      list[i].isFavorite = ids.contains(tid)
    }
  }
}
