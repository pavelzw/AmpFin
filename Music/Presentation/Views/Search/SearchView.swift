//
//  SearchView.swift
//  Music
//
//  Created by Rasmus Krämer on 09.09.23.
//

import SwiftUI

struct SearchView: View {
    @State var query = ""
    @State var task: Task<(), Never>? = nil
    
    @State var tracks = [Track]()
    @State var albums = [Album]()
    
    @State var library: Tab = .online
    @State var dataProvider: LibraryDataProvider = OnlineLibraryDataProivder()
    
    var body: some View {
        NavigationStack {
            List {
                ProviderPicker(selection: $library)
                
                if tracks.count > 0 {
                    Section("Tracks") {
                        ForEach(Array(tracks.enumerated()), id: \.offset) { index, track in
                            TrackListRow(track: track) {
                                AudioPlayer.shared.startPlayback(tracks: tracks, startIndex: index, shuffle: false)
                            }
                            .listRowInsets(.init(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .padding(.horizontal)
                        }
                    }
                }
                
                if albums.count > 0 {
                    Section("Albums") {
                        ForEach(albums) { album in
                            NavigationLink(destination: AlbumView(album: album)) {
                                AlbumListRow(album: album)
                            }
                            .listRowInsets(.init(top: 6, leading: 0, bottom: 6, trailing: 0))
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Search")
            .modifier(NowPlayingBarSafeAreaModifier())
            // Query
            .searchable(text: $query, prompt: "Serach Tracks / Albums")
            .autocorrectionDisabled()
            #if !os(macOS)
            .textInputAutocapitalization(.never)
            #endif
            .onChange(of: query) {
                task?.cancel()
                task = Task.detached {
                    // I guess this runs in parallel?
                    (tracks, albums) = (try? await (
                        dataProvider.searchTracks(query: query.lowercased()),
                        dataProvider.searchAlbums(query: query.lowercased())
                    )) ?? ([], [])
                }
            }
            // Online / Offline
            .onChange(of: library) {
                task?.cancel()
                
                tracks = []
                albums = []
                
                switch library {
                case .online:
                    dataProvider = OnlineLibraryDataProivder()
                case .offline:
                    dataProvider = OfflineLibraryDataProvider()
                }
            }
        }
        .environment(\.libraryOnline, library == .online)
        .environment(\.libraryDataProvider, dataProvider)
    }
}

#Preview {
    SearchView()
}
