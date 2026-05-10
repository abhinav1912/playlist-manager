//
//  ContentView.swift
//  PlaylistSampleApp
//
//  Created by Abhinav Mathur on 13/04/26.
//

import SwiftUI
import SwiftData
import PlaylistManager
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var loadedPlaylist: Playlist?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    openPlaylistButton
                }
            }
        } detail: {
            if isLoading {
                VStack {
                    ProgressView("Loading playlist...")
                }
            } else if let playlist = loadedPlaylist {
                PlaylistDetailView(playlist: playlist)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                    Text("Error")
                        .font(.title)
                    Text(error)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                openPlaylistButton
            }
        }
    }

    private var openPlaylistButton: some View {
        Button(action: openPlaylist) {
            Label("Open Playlist", systemImage: "music.note.list")
        }
        .disabled(isLoading)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func openPlaylist() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.m3uPlaylist]
        panel.message = "Select a playlist file to open"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            Task {
                await loadPlaylist(from: url)
            }
        }
    }
    
    private func loadPlaylist(from url: URL) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let playlist = try await PlaylistManagerService.shared.parse(path: url)
            await MainActor.run {
                self.loadedPlaylist = playlist
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.loadedPlaylist = nil
                self.isLoading = false
            }
        }
    }
}

struct PlaylistDetailView: View {
    let playlist: Playlist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(playlist.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let description = playlist.customDescription {
                    Text(description)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("\(playlist.mediaItems.count) tracks", systemImage: "music.note")
                        .foregroundStyle(.secondary)
                    
//                    Spacer()
//                    
//                    Text(playlist.path.lastPathComponent)
//                        .foregroundStyle(.tertiary)
//                        .font(.caption)
                }
            }
            .padding()
            
            Divider()
            
            // Media items list
            if playlist.mediaItems.isEmpty {
                ContentUnavailableView(
                    "No Tracks",
                    systemImage: "music.note.slash",
                    description: Text("This playlist doesn't contain any media items")
                )
            } else {
                List {
                    ForEach(Array(playlist.mediaItems.enumerated()), id: \.element) { index, media in
                        MediaItemRow(index: index + 1, media: media)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct MediaItemRow: View {
    let index: Int
    let media: Media
    
    var body: some View {
        HStack(spacing: 12) {
            // Track number
            Text("\(index)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(media.title)
                    .font(.body)
                
                Text(media.artist)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(formatDuration(media.metadata.duration))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()            
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

enum Sheet: Hashable, Identifiable {
    var id: String {
        switch self {
        case .newPlaylist:
            return "newPlaylist"
        case .editPlaylist(let item):
            return item.id
        }
    }

    case newPlaylist
    case editPlaylist(item: Playlist)
}

enum SidebarTab: Hashable {
    case library
    case playlist(item: Playlist)
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
