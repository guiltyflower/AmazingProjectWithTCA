import Foundation

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


public struct FavoriteMovie: Codable, Equatable, Sendable {
  public let tmdbID: Int
  public let title: String
  public let posterURL: String?
}
