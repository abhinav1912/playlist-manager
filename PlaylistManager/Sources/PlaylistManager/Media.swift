//
//  Media.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 12/04/26.
//

import Foundation

/// media items contained within the playlist
public struct Media: Sendable {
    let title: String
    let artist: String
    let path: URL
}

// MARK: Protocol conformances
extension Media: Hashable {}
