import ComposableArchitecture
import Foundation
import Dependencies
import DependenciesMacros

private struct SearchTMDBMovie: Decodable, Sendable {
  let id: Int
  let title: String
  let poster_path: String?
}

private struct SearchTMDBMoviesResponse: Decodable, Sendable {
  let results: [SearchTMDBMovie]
}

@DependencyClient
public struct MovieSearchClient: Sendable {
  public var search: @Sendable (_ query: String, _ page: Int) async throws -> [Movie]
}
extension MovieSearchClient: DependencyKey {
  public static let liveValue: MovieSearchClient = .init(
    search: { query, page in
      guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

      var components = URLComponents(string: "https://api.themoviedb.org/3/search/movie")!
      components.queryItems = [
        .init(name: "query", value: query),
        .init(name: "include_adult", value: "false"),
        .init(name: "language", value: "en-US"),
        .init(name: "page", value: String(page)),
      ]

      var request = URLRequest(url: components.url!)
      request.httpMethod = "GET"
      request.timeoutInterval = 10
      request.setValue("application/json", forHTTPHeaderField: "accept")

      request.setValue(
        "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjMWU0YjMyYWIzN2U1MDg2ZmU1YzA5NTIxYzBlNjdhNyIsInN1YiI6IjU2NTYzOTFlOTI1MTQxMDllODAwMDMyZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.CnjFlQK6eKafVglC_aN3jx98dn9TD_SulgMz86RGohw",
        forHTTPHeaderField: "Authorization"
      )

      let (data, response) = try await URLSession.shared.data(for: request)
      guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode)
      else { throw URLError(.badServerResponse) }

      let decoded = try JSONDecoder().decode(SearchTMDBMoviesResponse.self, from: data)

      let baseImage = "https://image.tmdb.org/t/p/w500"
      return decoded.results.map {
    Movie(
      tmdbID: $0.id,
      title: $0.title,
      posterURL: $0.poster_path.map { baseImage + $0 },
      isFavorite: false
    )
  }
    }
  )
}

public extension DependencyValues {
  var movieSearch: MovieSearchClient {
    get { self[MovieSearchClient.self] }
    set { self[MovieSearchClient.self] = newValue }
  }
}


