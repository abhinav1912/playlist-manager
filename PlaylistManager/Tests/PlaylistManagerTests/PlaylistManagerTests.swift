import Testing
import Foundation
@testable import PlaylistManager

@Suite("PlaylistManager Tests")
struct PlaylistManagerTests {

    // MARK: - Mock Objects

    actor MockPlaylistManager: PlaylistManager {
        var parseCallCount = 0
        var lastParsedPath: URL?
        var playlistToReturn: Playlist?
        var errorToThrow: Error?

        func configure(playlistToReturn: Playlist? = nil, errorToThrow: Error? = nil) {
            self.playlistToReturn = playlistToReturn
            self.errorToThrow = errorToThrow
        }

        func parse(path: URL) async throws -> Playlist {
            parseCallCount += 1
            lastParsedPath = path

            if let error = errorToThrow {
                throw error
            }

            guard let playlist = playlistToReturn else {
                fatalError("Mock not configured with a playlist to return")
            }

            return playlist
        }
    }

    struct MockPlaylist: Playlist {
        var path: URL
        var mediaItems: [Media]
    }

    class MockFileManager: FileManager {
        var existingFiles: Set<String> = []
        var readableFiles: Set<String> = []

        override func fileExists(atPath path: String) -> Bool {
            return existingFiles.contains(path)
        }

        override func isReadableFile(atPath path: String) -> Bool {
            return readableFiles.contains(path)
        }
    }

    // MARK: - Test Cases

    @Test("Parse valid M3U file")
    func parseValidM3UFile() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/playlist.m3u")
        mockFileManager.existingFiles.insert(testURL.path)
        mockFileManager.readableFiles.insert(testURL.path)

        let expectedPlaylist = MockPlaylist(
            path: testURL,
            mediaItems: [Media(title: "Song", artist: "Artist", path: testURL)]
        )
        await mockM3UManager.configure(playlistToReturn: expectedPlaylist)

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When
        let result = try await manager.parse(path: testURL)

        // Then
        #expect(result.path == testURL)
        #expect(await mockM3UManager.parseCallCount == 1)
        #expect(await mockM3U8Manager.parseCallCount == 0)
        #expect(await mockM3UManager.lastParsedPath == testURL)
    }

    @Test("Parse valid M3U8 file")
    func parseValidM3U8File() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/playlist.m3u8")
        mockFileManager.existingFiles.insert(testURL.path)
        mockFileManager.readableFiles.insert(testURL.path)

        let expectedPlaylist = MockPlaylist(
            path: testURL,
            mediaItems: [Media(title: "Song", artist: "Artist", path: testURL)]
        )
        await mockM3U8Manager.configure(playlistToReturn: expectedPlaylist)

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When
        let result = try await manager.parse(path: testURL)

        // Then
        #expect(result.path == testURL)
        #expect(await mockM3UManager.parseCallCount == 0)
        #expect(await mockM3U8Manager.parseCallCount == 1)
        #expect(await mockM3U8Manager.lastParsedPath == testURL)
    }

    @Test("Throw error for non-existent file")
    func throwErrorForNonExistentFile() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/nonexistent.m3u")
        // Don't add to existingFiles

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When/Then
        await #expect(throws: PlaylistManagerWrapper.ParsingError.invalidPath) {
            try await manager.parse(path: testURL)
        }

        #expect(await mockM3UManager.parseCallCount == 0)
        #expect(await mockM3U8Manager.parseCallCount == 0)
    }

    @Test("Throw error for unreadable file")
    func throwErrorForUnreadableFile() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/unreadable.m3u")
        mockFileManager.existingFiles.insert(testURL.path)
        // Don't add to readableFiles

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When/Then
        await #expect(throws: PlaylistManagerWrapper.ParsingError.insufficientPermissions) {
            try await manager.parse(path: testURL)
        }

        #expect(await mockM3UManager.parseCallCount == 0)
        #expect(await mockM3U8Manager.parseCallCount == 0)
    }

    @Test("Throw error for unsupported format")
    func throwErrorForUnsupportedFormat() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/playlist.pls")
        mockFileManager.existingFiles.insert(testURL.path)
        mockFileManager.readableFiles.insert(testURL.path)

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When/Then
        await #expect(throws: PlaylistManagerWrapper.ParsingError.unsupportedPlaylistFormat) {
            try await manager.parse(path: testURL)
        }

        #expect(await mockM3UManager.parseCallCount == 0)
        #expect(await mockM3U8Manager.parseCallCount == 0)
    }

    @Test("Handle file URL with special characters")
    func handleFileURLWithSpecialCharacters() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/My Playlist (2024).m3u")
        mockFileManager.existingFiles.insert(testURL.path)
        mockFileManager.readableFiles.insert(testURL.path)

        let expectedPlaylist = MockPlaylist(
            path: testURL,
            mediaItems: []
        )
        await mockM3UManager.configure(playlistToReturn: expectedPlaylist)

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When
        let result = try await manager.parse(path: testURL)

        // Then
        #expect(result.path == testURL)
        #expect(await mockM3UManager.parseCallCount == 1)
    }

    @Test("Verify path property is used correctly", .tags(.pathHandling))
    func verifyPathPropertyUsage() async throws {
        // Given
        let mockFileManager = MockFileManager()
        let mockM3UManager = MockPlaylistManager()
        let mockM3U8Manager = MockPlaylistManager()

        let testURL = URL(fileURLWithPath: "/Users/test/playlist.m3u")

        // This test verifies that we're using .path, not .absoluteString
        // .path returns: "/Users/test/playlist.m3u"
        // .absoluteString returns: "file:///Users/test/playlist.m3u"
        mockFileManager.existingFiles.insert(testURL.path)
        mockFileManager.readableFiles.insert(testURL.path)

        let expectedPlaylist = MockPlaylist(path: testURL, mediaItems: [])
        await mockM3UManager.configure(playlistToReturn: expectedPlaylist)

        let manager = PlaylistManagerWrapper(
            m3uManager: mockM3UManager,
            m3u8Manager: mockM3U8Manager,
            fileManager: mockFileManager
        )

        // When
        let result = try await manager.parse(path: testURL)

        // Then - should succeed because we're using .path correctly
        #expect(result.path == testURL)
    }

    @Test("Verify all supported formats")
    func verifyAllSupportedFormats() {
        let formats = PlaylistManagerWrapper.SupportedFormats.allCases

        #expect(formats.count == 2)
        #expect(formats.contains(.m3u))
        #expect(formats.contains(.m3u8))

        #expect(PlaylistManagerWrapper.SupportedFormats(rawValue: "m3u") == .m3u)
        #expect(PlaylistManagerWrapper.SupportedFormats(rawValue: "m3u8") == .m3u8)
        #expect(PlaylistManagerWrapper.SupportedFormats(rawValue: "pls") == nil)
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var pathHandling: Self
}
