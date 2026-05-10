//
//  MetadataReader.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 09/05/26.
//

import Foundation
import AVFoundation

protocol MetadataReader {
    func readMetadata(for path: URL) async -> AudioMetadata?
}

protocol MetadataWriter {
    // TODO: implement updation logic
}

protocol MetadataService: MetadataReader, MetadataWriter, Sendable {}

final class MetadataServiceImpl: MetadataService {
    func readMetadata(for path: URL) async -> AudioMetadata? {
        let asset = AVURLAsset(url: path)
        
        var metadata = AudioMetadata()
        
        do {
            // Load common metadata asynchronously
            let commonMetadata = try await asset.load(.commonMetadata)
            
            // Parse common metadata items
            await parseCommonMetadata(from: commonMetadata, into: &metadata)

            // Parse format-specific metadata for additional fields
            await parseFormatSpecificMetadata(from: asset, into: &metadata)
            
            // Duration
            let duration = try await asset.load(.duration)
            if duration.isValid && !duration.isIndefinite {
                metadata.duration = CMTimeGetSeconds(duration)
            }
            
            // Extract technical properties from audio tracks
            let tracks = try await asset.load(.tracks)
            for track in tracks {
                // mediaType is a synchronous property on AVAssetTrack
                if track.mediaType == .audio {
                    await extractTechnicalProperties(from: track, into: &metadata)
                    break
                }
            }
            
            return metadata
        } catch {
            // Failed to load asset properties
            return nil
        }
    }

    private func parseCommonMetadata(from commonMetadata: [AVMetadataItem], into metadata: inout AudioMetadata) async {
        for item in commonMetadata {
            switch item.commonKey {
            case .commonKeyTitle:
                metadata.title = try? await item.load(.stringValue)
            case .commonKeyArtist:
                if let artistName = try? await item.load(.stringValue) {
                    metadata.artist = [artistName]
                }
            case .commonKeyAlbumName:
                metadata.album = try? await item.load(.stringValue)
            case .commonKeyType:
                metadata.genre = try? await item.load(.stringValue)
            case .commonKeyCreationDate:
                if let yearString = try? await item.load(.stringValue) {
                    // Extract year from strings like "2024" or "2024-05-09"
                    let yearDigits = yearString.prefix(4)
                    metadata.year = Int(yearDigits)
                } else if let dateValue = try? await item.load(.dateValue) {
                    let calendar = Calendar.current
                    metadata.year = calendar.component(.year, from: dateValue)
                }
            default:
                break
            }
        }
    }

    private func parseFormatSpecificMetadata(from asset: AVAsset, into metadata: inout AudioMetadata) async {
        do {
            // Get all available metadata formats
            let formats = try await asset.load(.availableMetadataFormats)
            
            for format in formats {
                let formatMetadata = try await asset.loadMetadata(for: format)
                
                for item in formatMetadata {
                    // Try to get the key
                    guard let key = item.key as? String ?? item.identifier?.rawValue else {
                        continue
                    }
                    
                    // Parse based on key
                    switch key {
                    // Genre (various formats)
                    case "gnre", "©gen", "TCON":
                        if metadata.genre == nil {
                            if let genreNumber = try? await item.load(.numberValue)?.intValue {
                                // ID3v1 genre number
                                metadata.genre = genreName(for: genreNumber)
                            } else {
                                metadata.genre = try? await item.load(.stringValue)
                            }
                        }
                        
                    // Track number
                    case "trkn", "TRCK":
                        if metadata.trackNumber == nil {
                            if let trackData = try? await item.load(.dataValue) {
                                // iTunes track number format (binary data)
                                metadata.trackNumber = parseTrackNumber(from: trackData)
                            } else if let trackString = try? await item.load(.stringValue) {
                                // ID3 format "3/12"
                                let components = trackString.split(separator: "/")
                                metadata.trackNumber = Int(components.first ?? "")
                            } else if let trackNum = try? await item.load(.numberValue)?.intValue {
                                metadata.trackNumber = trackNum
                            }
                        }
                        
                    // Disc number
                    case "disk", "TPOS":
                        if metadata.discNumber == nil {
                            if let discData = try? await item.load(.dataValue) {
                                // iTunes disc number format (binary data)
                                metadata.discNumber = parseDiscNumber(from: discData)
                            } else if let discString = try? await item.load(.stringValue) {
                                // ID3 format "1/2"
                                let components = discString.split(separator: "/")
                                metadata.discNumber = Int(components.first ?? "")
                            } else if let discNum = try? await item.load(.numberValue)?.intValue {
                                metadata.discNumber = discNum
                            }
                        }
                        
                    // Year/Date
                    case "©day", "TDRC", "TYER":
                        if metadata.year == nil {
                            if let yearString = try? await item.load(.stringValue) {
                                let yearDigits = yearString.prefix(4)
                                metadata.year = Int(yearDigits)
                            }
                        }
                        
                    default:
                        break
                    }
                }
            }
        } catch {
            // Failed to load metadata formats
        }
    }
    
    private func extractTechnicalProperties(from track: AVAssetTrack, into metadata: inout AudioMetadata) async {
        do {
            // Estimated data rate (bitrate)
            let estimatedDataRate = try await track.load(.estimatedDataRate)
            if estimatedDataRate > 0 {
                metadata.bitRate = Int(estimatedDataRate)
            }
            
            // Format descriptions for sample rate and channels
            let formatDescriptions = try await track.load(.formatDescriptions)
            if let formatDescription = formatDescriptions.first {
                let audioFormatDescription = formatDescription as! CMAudioFormatDescription
                let basicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormatDescription)
                
                if let basicDesc = basicDescription?.pointee {
                    // Sample rate
                    if basicDesc.mSampleRate > 0 {
                        metadata.sampleRate = Int(basicDesc.mSampleRate)
                    }
                    
                    // Number of channels
                    if basicDesc.mChannelsPerFrame > 0 {
                        metadata.channels = Int(basicDesc.mChannelsPerFrame)
                    }
                    
                    // Codec information
                    let formatID = basicDesc.mFormatID
                    metadata.codec = codecName(for: formatID)
                }
            }
        } catch {
            // Failed to load track properties
        }
    }
    
    private func parseTrackNumber(from data: Data) -> Int? {
        // iTunes track number is stored as binary: [empty, empty, track, total tracks]
        guard data.count >= 4 else { return nil }
        let trackNumber = Int(data[2])
        return trackNumber > 0 ? trackNumber : nil
    }
    
    private func parseDiscNumber(from data: Data) -> Int? {
        // iTunes disc number is stored as binary: [empty, empty, disc, total discs]
        guard data.count >= 4 else { return nil }
        let discNumber = Int(data[2])
        return discNumber > 0 ? discNumber : nil
    }
    
    private func codecName(for formatID: AudioFormatID) -> String {
        return AudioCodec(formatID: formatID).displayName
    }
    
    private func genreName(for genreNumber: Int) -> String? {
        return ID3v1Genre(rawValue: genreNumber)?.displayName
    }
}
