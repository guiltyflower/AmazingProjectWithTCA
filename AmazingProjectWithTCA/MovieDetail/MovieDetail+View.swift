import SwiftUI
import ComposableArchitecture

struct MovieDetailView: View {
  let store: StoreOf<MovieDetailFeature>

  var body: some View {
    Form {
      VStack {
        AsyncImage(url: URL(string: store.movie.posterURL ?? "")) { image in
          image
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } placeholder: {
          RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .overlay(
              Image(systemName: "film")
                .foregroundStyle(.gray.opacity(0.7))
            )
            .frame(height: 250)
        }
        .frame(maxWidth: 300, maxHeight: 400)
        .shadow(radius: 2)


        Text(store.movie.title)
          .font(.title2)

        Button {
          store.send(.favoriteButtonTapped)
        } label: {
          Image(systemName: store.movie.isFavorite ? "heart.fill" : "heart")
        }
        .buttonStyle(.plain)
        .foregroundStyle(store.movie.isFavorite ? .red : .secondary)

      }
    }
    .navigationTitle(store.movie.title)
  }
}



#Preview {
  NavigationStack {
    MovieDetailView(
      store: Store(
        initialState: MovieDetailFeature.State(
          movie: Movie(id: UUID(), title: "Lollino1")
        )
      ) {
        MovieDetailFeature()
      }
    )
  }
}
