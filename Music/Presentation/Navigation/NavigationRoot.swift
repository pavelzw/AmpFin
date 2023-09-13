//
//  NavigationRoot.swift
//  Music
//
//  Created by Rasmus Krämer on 06.09.23.
//

import SwiftUI

struct NavigationRoot: View {
    #if os(macOS)
    @State var currentTab: Tab = .tracks
    #endif
    
    var body: some View {
        #if !os(macOS)
        TabView {
            LibraryTab()
            DownloadsTab()
            SearchTab()
        }
        #else
        NavigationSplitView {
            List(Tab.allCases, id: \.hashValue, selection: $currentTab) {
                Text(String($0.hashValue))
            }
        } detail: {
            switch currentTab {
            case .tracks:
                TracksView()
            case .albums:
                AlbumsView()
            }
        }
        #endif
    }
}

// MARK: MacOS tabs
#if os(macOS)
extension NavigationRoot {
    enum Tab: CaseIterable {
        case tracks
        case albums
    }
}
#endif

#Preview {
    NavigationRoot()
}
