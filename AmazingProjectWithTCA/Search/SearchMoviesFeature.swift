/*import ComposableArchitecture
import Foundation


@ObservableState
public struct State: Equatable, Sendable {
  var query: String = ""
  var results: [Movie] = []
  var isLoading = false
  var page = 1
}

public enum Action: Equatable, Sendable {
  case queryChanged(String)
  case searchResponse(Result<[Movie], Error>)
  case dismiss
}

public var body: some ReducerOf<Self> {
  Reduce { state, action in
    switch action {
    case let .queryChanged(text):
      state.query = text
      if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        state.results = []
        state.isLoading = false
        return .cancel(id: CancelID.search)
      }
      state.isLoading = true
      let q = text
      return .run { [q] send in
        try await clock.sleep(for: .milliseconds(350))
        let movies = try await movieSearch.search(q, 1)
        await send(.searchResponse(.success(movies)))
      }
      .cancellable(id: CancelID.search, cancelInFlight: true)

    case let .searchResponse(result):
      state.isLoading = false
      if case let .success(movies) = result {
        state.results = movies
      } else {
        state.results = []
      }
      return .none

    case .dismiss:
      return .none
    }
  }
}


*/
