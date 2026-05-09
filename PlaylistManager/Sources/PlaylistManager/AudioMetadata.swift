//
//  AudioMetadata.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 09/05/26.
//
import Foundation

public struct AudioMetadata: Sendable, Hashable {
    /// figure out which fields to make public
    var title: String?
    var album: String?
    var artist: [String] = []
    var duration: TimeInterval = .zero
    var genre: String?
    var year: Int?
    var trackNumber: Int?
    var discNumber: Int?
    var bitRate: Int?
    var sampleRate: Int?
    var channels: Int?
    var codec: String?
}
