//
//  GameView.swift
//  you-music-nerd
//
//  Created by Julius Broomfield on 7/19/24.
//

import SwiftUI
import AVFoundation

struct GameView: View {
    @ObservedObject var viewModel: ArtistSearchViewModel
    @State private var currentSongIndex: Int = 0
    @State private var player: AVPlayer?
    @State private var score: Int = 0
    @State private var showResult: Bool = false
    @State private var resultMessage: String = ""
    
    var body: some View {
        VStack {
            if currentSongIndex < viewModel.songs.count {
                let currentSong = viewModel.songs[currentSongIndex]
                
                Text("Score: \(score)")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    playSnippet(url: currentSong.previewUrl)
                }) {
                    Text("Play Snippet")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                HStack {
                    ForEach(viewModel.songs.shuffled().prefix(3), id: \.id) { song in
                        Button(action: {
                            handleSelection(song: song)
                        }) {
                            VStack {
                                AsyncImage(url: URL(string: song.albumCoverUrl)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                
                                Text(song.name)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            } else {
                Text("Game Over")
                    .font(.largeTitle)
                    .padding()
                
                Text("Your final score is \(score)")
                    .font(.title)
                    .padding()
                
                Button(action: {
                    resetGame()
                }) {
                    Text("Play Again")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .alert(isPresented: $showResult) {
            Alert(title: Text(resultMessage), dismissButton: .default(Text("OK")) {
                nextSong()
            })
        }
        .onAppear {
            if let firstSong = viewModel.songs.first {
                playSnippet(url: firstSong.previewUrl)
            }
        }
    }
    
    private func playSnippet(url: String) {
        guard let url = URL(string: url) else { return }
        player = AVPlayer(url: url)
        player?.play()
    }
    
    private func handleSelection(song: Song) {
        let currentSong = viewModel.songs[currentSongIndex]
        if song.id == currentSong.id {
            score += 10
            resultMessage = "Correct!"
        } else {
            resultMessage = "Wrong!"
        }
        showResult = true
    }
    
    private func nextSong() {
        player?.pause()
        currentSongIndex += 1
        if currentSongIndex < viewModel.songs.count {
            playSnippet(url: viewModel.songs[currentSongIndex].previewUrl)
        }
    }
    
    private func resetGame() {
        currentSongIndex = 0
        score = 0
        if let firstSong = viewModel.songs.first {
            playSnippet(url: firstSong.previewUrl)
        }
    }
}


