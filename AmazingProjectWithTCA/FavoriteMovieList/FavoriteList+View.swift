import SwiftUI
import ComposableArchitecture

public struct FavoriteListView: View {
  @Bindable var store: StoreOf<FavoriteListFeature>

  public init(store: StoreOf<FavoriteListFeature>) { self.store = store }

  public var body: some View {
    List {
      ForEach(store.items) { movie in
        HStack(spacing: 12) {
          AsyncImage(url: URL(string: movie.posterURL ?? "")) { img in
            img.resizable().scaledToFill()
          } placeholder: {
            Circle().fill(.gray.opacity(0.3))
          }
          .frame(width: 40, height: 40)
          .clipShape(Circle())

          Text(movie.title).font(.headline)
          Spacer()
          Button {
            store.send(.removeTapped(id: movie.id))
          } label: {
            Image(systemName: "heart.fill")
          }
          .buttonStyle(.plain)
          .foregroundStyle(.red)
        }
      }
    }
    .navigationTitle("Favorites")
    .task { store.send(.onAppear) }
  }
}
