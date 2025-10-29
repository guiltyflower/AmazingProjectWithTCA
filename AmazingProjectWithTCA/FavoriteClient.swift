import ComposableArchitecture
import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct FavoritesClient: Sendable {
  public var getAllMovies: () -> [Movie] = { [] }
  public var getAllIDs: () -> [Int] = { [] }
  public var toggle: (_ movie: Movie) -> [Movie] = { _ in [] }
  public var remove: (_ tmdbID: Int) -> [Movie] = { _ in [] }
}

private enum FavoritesStorage {
  static let key = "favorite_movies"

  struct StoredFavorite: Codable, Sendable, Equatable {
    let tmdbID: Int
    let title: String
    let posterURL: String?
  }

  static func load() -> [StoredFavorite] {
    guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
    return (try? JSONDecoder().decode([StoredFavorite].self, from: data)) ?? []
  }

  static func save(_ items: [StoredFavorite]) {
    let data = try? JSONEncoder().encode(items)
    UserDefaults.standard.set(data, forKey: key)
  }
}

extension FavoritesClient: DependencyKey {
  public static let liveValue: FavoritesClient = .init(
    getAllMovies: {
      FavoritesStorage.load().map {
        Movie(
          tmdbID: $0.tmdbID,
          title: $0.title,
          posterURL: $0.posterURL,
          isFavorite: true
        )
      }
    },
    getAllIDs: {
      FavoritesStorage.load().map(\.tmdbID)
    },
    toggle: { movie in
      guard let tmdbID = movie.tmdbID else {
        return FavoritesStorage.load().map {
          Movie(tmdbID: $0.tmdbID, title: $0.title, posterURL: $0.posterURL, isFavorite: true)
        }
      }
      var stored = FavoritesStorage.load()
      if let i = stored.firstIndex(where: { $0.tmdbID == tmdbID }) {
        stored.remove(at: i)
      } else {
        stored.append(.init(tmdbID: tmdbID, title: movie.title, posterURL: movie.posterURL))
      }
      FavoritesStorage.save(stored)
      return stored.map {
        Movie(tmdbID: $0.tmdbID, title: $0.title, posterURL: $0.posterURL, isFavorite: true)
      }
    },
    remove: { tmdbID in
      var stored = FavoritesStorage.load()
      stored.removeAll { $0.tmdbID == tmdbID }
      FavoritesStorage.save(stored)
      return stored.map {
        Movie(tmdbID: $0.tmdbID, title: $0.title, posterURL: $0.posterURL, isFavorite: true)
      }
    }
  )
}

public extension DependencyValues {
  var favoritesService: FavoritesClient {
    get { self[FavoritesClient.self] }
    set { self[FavoritesClient.self] = newValue }
  }
}
