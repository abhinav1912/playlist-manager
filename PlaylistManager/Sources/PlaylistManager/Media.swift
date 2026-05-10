//
//  Media.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 12/04/26.
//

import Foundation

/// media items contained within the playlist
public struct Media: Sendable {
    public let title: String
    public let artist: String
    public let metadata: AudioMetadata
    let path: URL
}

// MARK: Protocol conformances
extension Media: Equatable {
    public static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.path == rhs.path
    }
}

extension Media: Hashable {}
