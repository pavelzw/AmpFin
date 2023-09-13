//
//  NowPlayingSheet+Queue.swift
//  Music
//
//  Created by Rasmus Krämer on 08.09.23.
//

import SwiftUI

// MARK: Container

#if !os(macOS)
extension NowPlayingSheet {
    struct Queue: View {
        @State var histroy = AudioPlayer.shared.history
        @State var queue = AudioPlayer.shared.queue
        @State var shuffled = AudioPlayer.shared.shuffled
        
        @State var showHistory = false
        
        var body: some View {
            HStack {
                Text(showHistory ? "History" : "Queue")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        AudioPlayer.shared.shuffle(!shuffled)
                    }
                } label: {
                    Image(systemName: "shuffle")
                }
                .buttonStyle(SymbolButtonStyle(active: $shuffled))
                .padding(.horizontal, 4)
                
                Button {
                    withAnimation {
                        showHistory.toggle()
                    }
                } label: {
                    Image(systemName: "calendar.day.timeline.leading")
                }
                .buttonStyle(SymbolButtonStyle(active: $showHistory))
            }
            .padding(.top, 10)
            .padding(.bottom, -10)
            .padding(.horizontal, 30)
            
            List {
                if showHistory {
                    ForEach(Array(histroy.enumerated()), id: \.offset) { index, track in
                        QueueTrackRow(track: track, draggable: false)
                            .onTapGesture {
                                AudioPlayer.shared.restoreHistory(index: index)
                            }
                            .padding(.top, index == 0 ? 15 : 0)
                            .padding(.bottom, (index == histroy.count - 1) ? 15 : 0)
                    }
                    .defaultScrollAnchor(.bottom)
                } else {
                    ForEach(Array(queue.enumerated()), id: \.offset) { index, track in
                        QueueTrackRow(track: track, draggable: true)
                            .onTapGesture {
                                AudioPlayer.shared.skip(to: index)
                            }
                            .padding(.top, index == 0 ? 15 : 0)
                            .padding(.bottom, (index == queue.count - 1) ? 15 : 0)
                    }
                    .onMove { from, to in
                        Task.detached {
                            from.forEach {
                                AudioPlayer.shared.moveTrack(from: $0, to: to)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach {
                            let _ = AudioPlayer.shared.removeItem(index: $0)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            // this is required because swiftui sucks ass
            .mask(
                VStack(spacing: 0) {
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 40)
                    
                    Rectangle().fill(Color.black)
                    
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 40)
                }
            )
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.QueueUpdated), perform: { _ in
                histroy = AudioPlayer.shared.history
                queue = AudioPlayer.shared.queue
                
                withAnimation {
                    shuffled = AudioPlayer.shared.shuffled
                }
            })
        }
    }
}

// MARK: Item

extension NowPlayingSheet {
    struct QueueTrackRow: View {
        let track: Track
        let draggable: Bool
        
        var body: some View {
            HStack {
                ItemImage(cover: track.cover)
                    .frame(width: 45)
                
                VStack(alignment: .leading) {
                    Text(track.name)
                        .lineLimit(1)
                        .font(.headline)
                    
                    Text(track.artists.map { $0.name }.joined(separator: ", "))
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                if draggable {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 5, leading: 30, bottom: 5, trailing: 30))
        }
    }
}
#endif
