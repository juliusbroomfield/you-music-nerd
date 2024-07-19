//
//  ArtistInputView.swift
//  you-music-nerd
//
//  Created by Julius Broomfield on 7/19/24.
//

import SwiftUI

struct ArtistInputView: View {
    @StateObject private var viewModel = ArtistSearchViewModel()
    @State private var selectedArtist: String?
    @State private var showGameView: Bool = false

    var body: some View {
        VStack {
            Text("Are you a true music fan?")
                .font(.title)
                .padding()

            TextField("Type an artist's name", text: $viewModel.artistName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !viewModel.suggestions.isEmpty {
                List(viewModel.suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .onTapGesture {
                            selectedArtist = suggestion
                            viewModel.artistName = suggestion
                            viewModel.suggestions = []
                            fetchSongsForArtist()
                        }
                }
                .frame(height: 200)
            }

            if selectedArtist != nil && !viewModel.songs.isEmpty {
                Button(action: {
                    showGameView = true
                }) {
                    Text("Let's go")
                        .font(.title)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(40)
                }
                .padding()
                .fullScreenCover(isPresented: $showGameView) {
                    GameView(viewModel: viewModel)
                }
            }
        }
        .padding()
    }

    private func fetchSongsForArtist() {
        guard let artistId = viewModel.suggestions.first(where: { $0 == viewModel.artistName }) else { return }
        viewModel.fetchSongs(for: artistId)
    }
}
