//
//  ArtistView.swift
//  Music
//
//  Created by Rasmus Krämer on 08.09.23.
//

import SwiftUI

struct ArtistView: View {
    @Environment(\.libraryDataProvider) var dataProvider
    
    let artist: Artist
    
    @State var albums: [Album]?
    @State var sortOrder = SortSelector.getSortOrder()
    
    var body: some View {
        ScrollView {
            Header(artist: artist)
            
            if let albums = albums {
                AlbumGrid(albums: albums)
                    .padding()
            }
        }
        .navigationTitle(artist.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SortSelector(sortOrder: $sortOrder)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        try? await artist.setFavorite(favorite: !artist.favorite)
                    }
                } label: {
                    Label("Favorite", systemImage: artist.favorite ? "heart.fill" : "heart")
                        .contentTransition(.symbolEffect(.replace))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
        }
        #endif
        .task(loadAlbums)
        .onChange(of: sortOrder) {
            Task {
                await loadAlbums()
            }
        }
        .modifier(NowPlayingBarSafeAreaModifier())
    }
}

// MARK: Helper

extension ArtistView {
    @Sendable
    func loadAlbums() async {
        albums = try? await dataProvider.getArtistAlbums(id: artist.id, sortOrder: sortOrder, ascending: true)
    }
}

#Preview {
    NavigationStack {
        ArtistView(artist: Artist.fixture)
    }
}
