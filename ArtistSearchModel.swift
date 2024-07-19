//
//  ArtistSearchModel.swift
//  you-music-nerd
//
//  Created by Julius Broomfield on 7/19/24.
//

import SwiftUI
import Combine

class ArtistSearchViewModel: ObservableObject {
    @Published var artistName: String = ""
    @Published var suggestions: [String] = []
    @Published var songs: [Song] = []
    private var cancellables = Set<AnyCancellable>()

    private let clientId = "4c5b70f160e446e98b65bd6f3805d2e1"
    private let clientSecret = Bundle.main.infoDictionary?["SPOTIFY_CLIENT_SECRET"] as? String
    private var accessToken: String?

    init() {
        $artistName
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] name in
                if !name.isEmpty {
                    self?.fetchSuggestions(for: name)
                } else {
                    self?.suggestions = []
                }
            }
            .store(in: &cancellables)

        getSpotifyAccessToken()
    }

    private func getSpotifyAccessToken() {
        let tokenUrl = "https://accounts.spotify.com/api/token"
        let credentials = "\(clientId):\(clientSecret)"
        let encodedCredentials = Data(credentials.utf8).base64EncodedString()

        var request = URLRequest(url: URL(string: tokenUrl)!)
        request.httpMethod = "POST"
        request.addValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Failed to get token: \(error?.localizedDescription ?? "No error description")")
                return
            }

            if let tokenResponse = try? JSONDecoder().decode(SpotifyTokenResponse.self, from: data) {
                self?.accessToken = tokenResponse.access_token
            }
        }.resume()
    }

    private func fetchSuggestions(for name: String) {
        guard let token = accessToken else { return }

        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spotify.com/v1/search?q=\(query)&type=artist&limit=5"
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch suggestions: \(error?.localizedDescription ?? "No error description")")
                return
            }

            if let searchResponse = try? JSONDecoder().decode(SpotifySearchResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.suggestions = searchResponse.artists.items.map { $0.name }
                }
            }
        }.resume()
    }

    func fetchSongs(for artistId: String) {
        guard let token = accessToken else { return }

        let urlString = "https://api.spotify.com/v1/artists/\(artistId)/top-tracks?market=US"
        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch songs: \(error?.localizedDescription ?? "No error description")")
                return
            }

            if let tracksResponse = try? JSONDecoder().decode(SpotifyTopTracksResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.songs = tracksResponse.tracks.prefix(30).map { track in
                        Song(
                            id: track.id,
                            name: track.name,
                            albumName: track.album.name,
                            albumCoverUrl: track.album.images.first?.url ?? "",
                            previewUrl: track.preview_url ?? ""
                        )
                    }
                }
            }
        }.resume()
    }
}

struct SpotifyTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}

struct SpotifySearchResponse: Decodable {
    let artists: Artists
}

struct Artists: Decodable {
    let items: [Artist]
}

struct Artist: Decodable {
    let id: String
    let name: String
}

struct SpotifyTopTracksResponse: Decodable {
    let tracks: [Track]
}

struct Track: Decodable {
    let id: String
    let name: String
    let album: Album
    let preview_url: String?
}

struct Album: Decodable {
    let name: String
    let images: [Image]
}

struct Image: Decodable {
    let url: String
}

struct Song: Identifiable {
    let id: String
    let name: String
    let albumName: String
    let albumCoverUrl: String
    let previewUrl: String
}
