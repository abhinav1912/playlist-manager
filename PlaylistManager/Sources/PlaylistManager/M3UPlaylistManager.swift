//
//  M3UPlaylistManager.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 14/04/26.
//

import Foundation

actor M3UPlaylistManager: PlaylistManager {
    
    enum M3UError: Error {
        case invalidFormat
        case invalidHeader
        case fileReadError
    }
    
    func parse(path: URL) async throws -> Playlist {
        // Read the file contents
        let data: Data
        do {
            data = try Data(contentsOf: path)
        } catch {
            throw M3UError.fileReadError
        }
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw M3UError.invalidFormat
        }
        
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Validate M3U header
        guard let firstLine = lines.first, firstLine == "#EXTM3U" else {
            throw M3UError.invalidHeader
        }
        
        var mediaItems: [Media] = []
        var currentExtInf: String?
        
        for line in lines.dropFirst() {
            if line.hasPrefix("#EXTINF:") {
                // Store the EXTINF line for the next media file
                currentExtInf = line
            } else if !line.hasPrefix("#") {
                // This is a file path
                let mediaPath = resolveMediaPath(line, relativeTo: path)
                
                // Parse title and artist from EXTINF if available
                let (title, artist) = parseExtInf(currentExtInf)
                
                // Read metadata (placeholder for now)
                _ = readMetadata(for: mediaPath)
                
                let media = Media(
                    title: title ?? mediaPath.lastPathComponent,
                    artist: artist ?? "Unknown Artist",
                    path: mediaPath
                )
                
                mediaItems.append(media)
                currentExtInf = nil
            }
        }
        
        return Playlist(path: path, mediaItems: mediaItems)
    }
    
    /// Placeholder method for reading metadata from media files
    /// Returns nil for now, will be implemented later
    private func readMetadata(for path: URL) -> Media? {
        return nil
    }
    
    /// Parse EXTINF line to extract title and artist
    /// Format: #EXTINF:duration,Artist - Title
    private func parseExtInf(_ extInf: String?) -> (title: String?, artist: String?) {
        guard let extInf = extInf else {
            return (nil, nil)
        }
        
        // Remove "#EXTINF:" prefix and duration
        let withoutPrefix = extInf.replacingOccurrences(of: "#EXTINF:", with: "")
        
        // Split by comma to separate duration from title/artist
        let components = withoutPrefix.components(separatedBy: ",")
        guard components.count >= 2 else {
            return (nil, nil)
        }
        
        let titleArtist = components[1...].joined(separator: ",").trimmingCharacters(in: .whitespaces)
        
        // Try to split by " - " to get artist and title
        if let separatorRange = titleArtist.range(of: " - ") {
            let artist = String(titleArtist[..<separatorRange.lowerBound])
            let title = String(titleArtist[separatorRange.upperBound...])
            return (title, artist)
        }
        
        // If no separator, treat the whole thing as title
        return (titleArtist, nil)
    }
    
    /// Resolve media path relative to the playlist file
    private func resolveMediaPath(_ pathString: String, relativeTo playlistURL: URL) -> URL {
        // If it's an absolute path or URL, use it directly
        if pathString.hasPrefix("/") || pathString.hasPrefix("http://") || pathString.hasPrefix("https://") {
            return URL(fileURLWithPath: pathString)
        }
        
        // Otherwise, resolve relative to the playlist directory
        let playlistDirectory = playlistURL.deletingLastPathComponent()
        return playlistDirectory.appendingPathComponent(pathString)
    }
}
