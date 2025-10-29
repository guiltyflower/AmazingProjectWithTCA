//
//  AmazingProjectWithTCAApp.swift
//  AmazingProjectWithTCA
//
//  Created by Giovanni Fioretto on 15/10/2025.
//
import ComposableArchitecture
import SwiftUI

@main
struct AmazingProjectWithTCAApp: App {
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }
    var body: some Scene {
        WindowGroup {
           AppView(store: AmazingProjectWithTCAApp.store)
        }
    }
}







