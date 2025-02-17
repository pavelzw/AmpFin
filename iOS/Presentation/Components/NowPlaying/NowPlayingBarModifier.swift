//
//  NowPlayingBar.swift
//  Music
//
//  Created by Rasmus Krämer on 07.09.23.
//

import SwiftUI
import AFBase
import AFPlayback

struct NowPlayingBarModifier: ViewModifier {
    @Environment(\.libraryDataProvider) var dataProvider
    @Environment(\.libraryOnline) var libraryOnline
    
    @State var playing = AudioPlayer.current.isPlaying()
    @State var currentTrack = AudioPlayer.current.nowPlaying
    
    @State var animateImage = false
    @State var animateForwards = false
    
    @State var nowPlayingSheetPresented = false
    @State var addToPlaylistSheetPresented = false
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if let currentTrack = currentTrack {
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width + 100, height: 300)
                            .offset(y: 225)
                            .blur(radius: 25)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: 15)
                            .toolbarBackground(.hidden, for: .tabBar)
                            .foregroundStyle(.ultraThinMaterial)
                            .overlay {
                                HStack {
                                    ItemImage(cover: currentTrack.cover)
                                        .frame(width: 40, height: 40)
                                        .padding(.leading, 5)
                                    
                                    Text(currentTrack.name)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Group {
                                        Button {
                                            AudioPlayer.current.setPlaying(!playing)
                                        } label: {
                                            Image(systemName: playing ?  "pause.fill" : "play.fill")
                                                .contentTransition(.symbolEffect(.replace.byLayer.downUp))
                                                .scaleEffect(animateImage ? AudioPlayer.current.isPlaying() ? 1.1 : 0.9 : 1)
                                                .animation(.spring(duration: 0.2, bounce: 0.7), value: animateImage)
                                                .onChange(of: AudioPlayer.playPause) {
                                                    withAnimation {
                                                        animateImage = true
                                                    } completion: {
                                                        animateImage = false
                                                    }
                                                }
                                        }
                                        
                                        Button {
                                            animateForwards.toggle()
                                            AudioPlayer.current.advanceToNextTrack()
                                        } label: {
                                            Image(systemName: "forward.fill")
                                                .symbolEffect(.bounce.up, value: animateForwards)
                                        }
                                        .padding(.horizontal, 10)
                                    }
                                    .imageScale(.large)
                                }
                                .padding(.horizontal, 6)
                            }
                            .foregroundStyle(.primary)
                            .frame(width: UIScreen.main.bounds.width - 30, height: 60)
                            .shadow(color: .black.opacity(0.25), radius: 20)
                            .draggable(currentTrack) {
                                TrackListRow.TrackPreview(track: currentTrack)
                            }
                            .contextMenu {
                                Button {
                                    Task {
                                        await currentTrack.setFavorite(favorite: !currentTrack.favorite)
                                    }
                                } label: {
                                    Label("favorite", systemImage: currentTrack.favorite ? "heart.fill" : "heart")
                                }
                                
                                Button {
                                    Task {
                                        try? await currentTrack.startInstantMix()
                                    }
                                } label: {
                                    Label("queue.mix", systemImage: "compass.drawing")
                                }
                                .disabled(!libraryOnline)
                                
                                Button {
                                    addToPlaylistSheetPresented.toggle()
                                } label: {
                                    Label("playlist.add", systemImage: "plus")
                                }
                                .disabled(!libraryOnline)
                                
                                Divider()
                                
                                // why is SwiftUI so stupid?
                                Button(action: {
                                    NotificationCenter.default.post(name: NavigationRoot.navigateAlbumNotification, object: currentTrack.album.id)
                                }) {
                                    Label("album.view", systemImage: "square.stack")
                                    
                                    if let albumName = currentTrack.album.name {
                                        Text(albumName)
                                    }
                                }
                                
                                if let artistId = currentTrack.artists.first?.id, let artistName = currentTrack.artists.first?.name {
                                    Button(action: {
                                        NotificationCenter.default.post(name: NavigationRoot.navigateArtistNotification, object: artistId)
                                    }) {
                                        Label("artist.view", systemImage: "music.mic")
                                        Text(artistName)
                                    }
                                }
                                
                                Divider()
                                
                                Button {
                                    AudioPlayer.current.shuffle(!AudioPlayer.current.shuffled)
                                } label: {
                                    if AudioPlayer.current.shuffled {
                                        Label("shuffle", systemImage: "checkmark")
                                    } else {
                                        Label("shuffle", systemImage: "shuffle")
                                    }
                                }
                                
                                Menu {
                                    Button {
                                        AudioPlayer.current.setRepeatMode(.none)
                                    } label: {
                                        Label("repeat.none", systemImage: "slash.circle")
                                    }
                                    
                                    Button {
                                        AudioPlayer.current.setRepeatMode(.queue)
                                    } label: {
                                        Label("repeat.queue", systemImage: "repeat")
                                    }
                                    
                                    Button {
                                        AudioPlayer.current.setRepeatMode(.track)
                                    } label: {
                                        Label("repeat.track", systemImage: "repeat.1")
                                    }
                                } label: {
                                    Label("repeat", systemImage: "repeat")
                                }
                                
                                Divider()
                                
                                Button {
                                    AudioPlayer.current.backToPreviousItem()
                                } label: {
                                    Label("playback.back", systemImage: "backward")
                                }
                                
                                Button {
                                    animateForwards.toggle()
                                    AudioPlayer.current.advanceToNextTrack()
                                } label: {
                                    Label("playback.next", systemImage: "forward")
                                }
                                
                                Divider()
                                
                                Button {
                                    AudioPlayer.current.stopPlayback()
                                } label: {
                                    Label("playback.stop", systemImage: "stop.circle")
                                }
                                
                                if AudioPlayer.current.source == .jellyfinRemote {
                                    Button {
                                        AudioPlayer.current.destroy()
                                    } label: {
                                        Label("remote.disconnect", systemImage: "xmark")
                                    }
                                }
                            } preview: {
                                VStack(alignment: .leading) {
                                    ItemImage(cover: currentTrack.cover)
                                        .padding(.bottom, 10)
                                    
                                    Text(currentTrack.name)
                                    
                                    if let artistName = currentTrack.artistName {
                                        Text(artistName)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(width: 250)
                                .padding()
                                .background(.ultraThickMaterial)
                            }
                            .padding(.bottom, 10)
                            .onTapGesture {
                                nowPlayingSheetPresented.toggle()
                            }
                            .modifier(NowPlayingSheetModifier(currentTrack: currentTrack, playing: $playing, nowPlayingSheetPresented: $nowPlayingSheetPresented))
                    }
                    .sheet(isPresented: $addToPlaylistSheetPresented) {
                        PlaylistAddSheet(track: currentTrack)
                    }
                }
            }
            .dropDestination(for: Track.self) { tracks, _ in
                AudioPlayer.current.queueTracks(tracks, index: 0)
                return true
            }
            .onReceive(NotificationCenter.default.publisher(for: AudioPlayer.trackChange), perform: { _ in
                withAnimation {
                    currentTrack = AudioPlayer.current.nowPlaying
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: AudioPlayer.playPause), perform: { _ in
                withAnimation {
                    playing = AudioPlayer.current.isPlaying()
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: NavigationRoot.navigateNotification)) { _ in
                withAnimation {
                    nowPlayingSheetPresented = false
                }
            }
    }
}

struct NowPlayingSheetModifier: ViewModifier {
    var currentTrack: Track
    
    @Binding var playing: Bool
    @Binding var nowPlayingSheetPresented: Bool
    
    @AppStorage("presentModally") var presentModally: Bool = false
    
    func body(content: Content) -> some View {
        Group {
            if presentModally {
                content
                    .sheet(isPresented: $nowPlayingSheetPresented) {
                        NowPlayingSheet(track: currentTrack, showDragIndicator: false, playing: $playing)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    }
            } else {
                content
                    .fullScreenCover(isPresented: $nowPlayingSheetPresented) {
                        NowPlayingSheet(track: currentTrack, showDragIndicator: true, playing: $playing)
                    }
            }
        }
        .onChange(of: NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) {
            presentModally = UserDefaults.standard.bool(forKey: "presentModally")
        }
    }
}

struct NowPlayingBarSafeAreaModifier: ViewModifier {
    @State var isVisible = AudioPlayer.current.nowPlaying != nil
    
    func body(content: Content) -> some View {
        content
            .safeAreaPadding(.bottom, isVisible ? 75 : 0)
            .onReceive(NotificationCenter.default.publisher(for: AudioPlayer.trackChange), perform: { _ in
                withAnimation {
                    isVisible = AudioPlayer.current.nowPlaying != nil
                }
            })
    }
}

#Preview {
    NavigationStack {
        Rectangle()
            .foregroundStyle(.red)
            .ignoresSafeArea()
    }
    .modifier(NowPlayingBarModifier(playing: true, currentTrack: Track.fixture))
}
