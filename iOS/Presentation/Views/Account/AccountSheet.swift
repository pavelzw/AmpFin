//
//  AccountSheet.swift
//  Music
//
//  Created by Rasmus Krämer on 27.09.23.
//

import SwiftUI
import AFBase
import AFOffline
import AFPlayback

struct AccountSheet: View {
    @State var username: String?
    @State var sessions: [Session]? = nil
    @State var downloads: [Track]? = nil
    
    var body: some View {
        List {
            HStack {
                ItemImage(cover: Item.Cover(type: .remote, url: URL(string: "\(JellyfinClient.shared.serverUrl!)/Users/\(JellyfinClient.shared.userId!)/Images/Primary?quality=90")!))
                    .frame(width: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10000))
                
                VStack(alignment: .leading) {
                    if let username = username {
                        Text(username)
                            .font(.headline)
                            .padding(.bottom, 1)
                    } else {
                        ProgressView()
                            .scaleEffect(0.5)
                            .padding(.bottom, 1)
                    }
                    
                    Text(JellyfinClient.shared.userId)
                        .font(.caption)
                }
                .padding(.trailing, 5)
            }
            
            Section {
                Button {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } label: {
                    Text("account.settings")
                }
            }
            
            Section("account.remote") {
                if JellyfinWebSocket.shared.isConnected {
                    if AudioPlayer.current.source == .jellyfinRemote {
                        Button {
                            AudioPlayer.current.destroy()
                        } label: {
                            Text("remote.disconnect")
                        }
                    } else if let sessions = sessions {
                        if sessions.count == 0 {
                            Text("account.remote.empty")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(sessions) { session in
                                Button {
                                    AudioPlayer.current.startRemoteControl(session: session)
                                } label: {
                                    VStack(alignment: .leading, spacing: 7) {
                                        Text(verbatim: "\(session.name) • \(session.client)")
                                        
                                        if let nowPlaying = session.nowPlaying {
                                            HStack {
                                                Image(systemName: "waveform")
                                                    .symbolEffect(.pulse.byLayer)
                                                
                                                Text(nowPlaying.name)
                                                
                                                Spacer()
                                            }
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text("account.remote.loading")
                            .foregroundStyle(.secondary)
                            .task {
                                sessions = await JellyfinClient.shared.getControllableSessions()
                            }
                    }
                } else {
                    Button {
                        JellyfinWebSocket.shared.connect()
                    } label: {
                        Text("remote.connect")
                    }
                }
            }
            
            Section("account.downloads.queue") {
                if let downloads = downloads {
                    if downloads.isEmpty {
                        Text("account.downloads.queue.empty")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(downloads) {
                            TrackListRow(track: $0, startPlayback: {}, disableMenu: true)
                        }
                    }
                } else {
                    ProgressView()
                        .onAppear {
                            downloads = try? OfflineManager.shared.getDownloadingTracks()
                        }
                }
            }
            
            Section() {
                Button(role: .destructive) {
                    JellyfinClient.shared.logout()
                } label: {
                    Text("account.logout")
                }
                Button(role: .destructive) {
                    try! OfflineManager.shared.deleteAll()
                } label: {
                    Text("account.deleteDownloads")
                }
                Button(role: .destructive) {
                    SpotlightHelper.deleteSpotlightIndex()
                } label: {
                    Text("account.deleteSpotlightIndex")
                }
            }
            
            Section {
                Button {
                    UIApplication.shared.open(URL(string: "https://github.com/rasmuslos/AmpFin")!)
                } label: {
                    Text("account.github")
                }
                
                Button {
                    UIApplication.shared.open(URL(string: "https://rfk.io/support.htm")!)
                } label: {
                    Text("account.support")
                }
            }
            
            Section("account.server") {
                Group {
                    Text(JellyfinClient.shared.serverUrl.absoluteString)
                    Text(JellyfinClient.shared.token)
                        .privacySensitive()
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            
            #if !ENABLE_ALL_FEATURES
            // quite ironic that this code is bad
            Section {
                HStack {
                    Spacer()
                    Text("developedBy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            #endif
        }
        .task {
            do {
                (username, _, _, _) = try await JellyfinClient.shared.getUserData()
            } catch {}
        }
    }
}

#Preview {
    Text(verbatim: ":)")
        .sheet(isPresented: .constant(true)) {
            AccountSheet()
        }
}
