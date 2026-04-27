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

    @Test("Parse real M3U sample playlist with relative paths")
    func parseRealM3USamplePlaylist() async throws {
        // Given
        let samplePlaylistPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Samples")
            .appendingPathComponent("Playlists")
            .appendingPathComponent("Sample.m3u")

        let m3uManager = M3UPlaylistManager()

        // When
        let playlist = try await m3uManager.parse(path: samplePlaylistPath)

        // Then
        #expect(playlist.path == samplePlaylistPath)
        #expect(playlist.mediaItems.count == 4)

        // Verify first media item
        let firstItem = playlist.mediaItems[0]
        #expect(firstItem.title == "Song One")
        #expect(firstItem.artist == "Artist One")
        #expect(firstItem.path.lastPathComponent == "song1.mp3")

        // Verify second media item
        let secondItem = playlist.mediaItems[1]
        #expect(secondItem.title == "Song Two")
        #expect(secondItem.artist == "Artist Two")
        #expect(secondItem.path.lastPathComponent == "song2.mp3")

        // Verify third media item
        let thirdItem = playlist.mediaItems[2]
        #expect(thirdItem.title == "Song Three")
        #expect(thirdItem.artist == "Artist Three")
        #expect(thirdItem.path.lastPathComponent == "song3.mp3")

        // Verify fourth media item
        let fourthItem = playlist.mediaItems[3]
        #expect(fourthItem.title == "Song Four")
        #expect(fourthItem.artist == "Artist One")
        #expect(fourthItem.path.lastPathComponent == "song4.mp3")

        // Verify that paths are resolved correctly (relative to playlist)
        let expectedFilesDirectory = samplePlaylistPath
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Files")

        for item in playlist.mediaItems {
            #expect(item.path.deletingLastPathComponent() == expectedFilesDirectory)
        }
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var pathHandling: Self
}
