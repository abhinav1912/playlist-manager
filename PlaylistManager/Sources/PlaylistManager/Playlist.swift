//
//  Playlist.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 12/04/26.
//

import Foundation

/// basic interface for playlist
/// all subtypes (M3U, M3U8, etc) will conform to this
public struct Playlist: Sendable {
    let path: URL
    public let mediaItems: [Media]
    public let title: String
    public let customDescription: String?

    init(path: URL, mediaItems: [Media], customDescription: String? = nil) {
        self.path = path
        self.mediaItems = mediaItems
        self.customDescription = customDescription
        self.title = Self.generateTitle(from: path)
    }
    
    /// Generates a human-readable title from a file path
    /// Removes the file extension and formats the filename
    private static func generateTitle(from url: URL) -> String {
        let filename = url.deletingPathExtension().lastPathComponent
        
        // Replace common separators with spaces
        var title = filename
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: ".", with: " ")
        
        // Trim extra whitespace
        title = title.trimmingCharacters(in: .whitespaces)
        
        // If the title is empty after processing, return a default
        return title.isEmpty ? "Untitled" : title
    }
}

// MARK: Protocol conformances

extension Playlist: Identifiable {
    public var id: String {
        path.absoluteString
    }
}

extension Playlist: Equatable {
    public static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Playlist: Hashable {}
