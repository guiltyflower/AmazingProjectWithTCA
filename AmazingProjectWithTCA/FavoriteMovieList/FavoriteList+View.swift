import SwiftUI
import ComposableArchitecture

public struct FavoriteListView: View {
  @Bindable var store: StoreOf<FavoriteListFeature>

  public init(store: StoreOf<FavoriteListFeature>) { self.store = store }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)){
      List {
        ForEach(store.items) { movie in
          NavigationLink(state: MovieDetailFeature.State(movie: movie)) {
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
      }
    } destination: { store in
      MovieDetailView(store: store)
    }
    .navigationTitle("Favorites")
    .task { store.send(.onAppear) }
  }
}
