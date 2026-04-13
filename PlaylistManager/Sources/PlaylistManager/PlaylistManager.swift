import Foundation

class PlaylistManager {
    let fileManager: FileManager = .default

    func parse(path: URL) async throws -> Playlist {
        try checkPathValidityAndPermissions(for: path)

        guard let format = SupportedFormats(rawValue: path.pathExtension) else {
            throw ParsingError.unsupportedPlaylistFormat
        }

        // TODO: Implement parsing
        throw ParsingError.unsupportedPlaylistFormat
    }

    enum ParsingError: Error {
        case invalidPath
        case insufficientPermissions
        case unsupportedPlaylistFormat
    }

    enum SupportedFormats: String, CaseIterable {
        case m3u
    }

    private func checkPathValidityAndPermissions(for path: URL) throws {
        guard fileManager.fileExists(atPath: path.absoluteString) else {
            throw ParsingError.invalidPath
        }

        guard fileManager.isReadableFile(atPath: path.absoluteString) else {
            throw ParsingError.insufficientPermissions
        }
    }
}
