//
//  SplashScreen.swift
//  you-music-nerd
//
//  Created by Julius Broomfield on 7/19/24.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        VStack {
            if isActive {
                ArtistInputView()
            } else {
                VStack {
                    Text("Music Nerd")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}
