import Foundation

protocol PlaylistManager {
    func parse(path: URL) async throws -> Playlist
}

class PlaylistManagerWrapper: PlaylistManager {
    let fileManager: FileManager
    let m3uManager: PlaylistManager
    let m3u8Manager: PlaylistManager

    init(
        m3uManager: PlaylistManager,
        m3u8Manager: PlaylistManager,
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.m3uManager = m3uManager
        self.m3u8Manager = m3u8Manager
    }

    func parse(path: URL) async throws -> Playlist {
        try checkPathValidityAndPermissions(for: path)

        guard let format = SupportedFormats(rawValue: path.pathExtension) else {
            throw ParsingError.unsupportedPlaylistFormat
        }

        let playlist: Playlist
        switch format {
        case .m3u:
            playlist = try await m3uManager.parse(path: path)
        case .m3u8:
            playlist = try await m3u8Manager.parse(path: path)
        }

        return playlist
    }

    enum ParsingError: Error {
        case invalidPath
        case insufficientPermissions
        case unsupportedPlaylistFormat
    }

    enum SupportedFormats: String, CaseIterable {
        case m3u
        case m3u8
    }

    private func checkPathValidityAndPermissions(for path: URL) throws {
        guard fileManager.fileExists(atPath: path.path) else {
            throw ParsingError.invalidPath
        }

        guard fileManager.isReadableFile(atPath: path.path) else {
            throw ParsingError.insufficientPermissions
        }
    }
}
