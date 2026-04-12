//
//  Playlist.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 12/04/26.
//

import Foundation

/// basic interface for playlist
/// all subtypes (M3U, M3U8, etc) will conform to this
protocol Playlist {
    var path: URL { get }
    var mediaItems: [Media] { get }
}
