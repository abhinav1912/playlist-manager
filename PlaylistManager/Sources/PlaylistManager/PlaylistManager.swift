import Foundation

class PlaylistManager {
    func parse(path: URL) async throws -> Playlist {
        guard checkSupport(for: path.pathExtension) else {
            throw ParsingError.unsupportedPlaylistFormat
        }
        throw ParsingError.unsupportedPlaylistFormat
    }

    func checkSupport(for format: String) -> Bool {
        SupportedFormats(rawValue: format) != nil
    }

    enum ParsingError: Error {
        case invalidPath
        case unsupportedPlaylistFormat
    }

    enum SupportedFormats: String, CaseIterable {
        case m3u
    }
}
