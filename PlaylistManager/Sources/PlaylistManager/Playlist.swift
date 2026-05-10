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

    // TODO: Remove the default title, and add title parsing from file path
    init(path: URL, mediaItems: [Media], title: String = "Untitled", customDescription: String? = nil) {
        self.path = path
        self.mediaItems = mediaItems
        self.title = title
        self.customDescription = customDescription
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
