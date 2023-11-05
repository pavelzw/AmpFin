//
//  AlbumView+Additional.swift
//  Music
//
//  Created by Rasmus Krämer on 17.10.23.
//

import SwiftUI

extension AlbumView {
    struct AdditionalAlbums: View {
        let album: Album
        
        @State var alsoFromArtist: [Album]?
        @State var similar: [Album]?
        
        var body: some View {
            // i hate this so much
            Divider()
                .frame(height: 0)
                .listRowSeparator(.hidden)
                .padding(.horizontal)
                .task(fetchAlbums)
            
            if let alsoFromArtist = alsoFromArtist, alsoFromArtist.count > 1 {
                AlbumRow(title: "Also by \(album.artists.first?.name ?? "this artist")", albums: alsoFromArtist)
            }
            
            if let similar = similar, !similar.isEmpty {
                AlbumRow(title: "Similar", albums: similar)
            }
        }
    }
}

// MARK: Helper

extension AlbumView.AdditionalAlbums {
    @Sendable
    func fetchAlbums() {
        Task.detached {
            if let artist = album.artists.first {
                alsoFromArtist = try? await JellyfinClient.shared.getArtistAlbums(artistId: artist.id, sortOrder: .released, ascending: false).filter { $0.id != album.id }
            }
        }
        Task.detached {
            similar = try? await JellyfinClient.shared.getSimilarAlbums(albumId: album.id)
        }
    }
}
