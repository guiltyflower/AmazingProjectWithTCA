import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
  struct State: Equatable {
    var tab1 = BestMovieFeature.State()
    var tab2 = FavoriteListFeature.State()
  }
  enum Action {
    case tab1(BestMovieFeature.Action)
    case tab2(FavoriteListFeature.Action)
  }
  var body: some ReducerOf<Self> {
    Scope(state: \.tab1, action: \.tab1) {
      BestMovieFeature()
    }
    Scope(state: \.tab2, action: \.tab2) {
      FavoriteListFeature()
    }
    Reduce { state, action in

      return .none
    }
  }
}

import SwiftUI


struct AppView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    TabView {
      BestMovieView(store: store.scope(state: \.tab1, action: \.tab1))
        .tabItem {
          Text("Popular")
        }

      FavoriteListView(store: store.scope(state: \.tab2, action: \.tab2))
        .tabItem {
          Text("Favorite")
        }
    }
  }
}


#Preview {
  AppView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
}
