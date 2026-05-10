//
//  AudioCodec.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 09/05/26.
//

import AVFoundation

enum AudioCodec: String {
    case pcm = "PCM"
    case aac = "AAC"
    case mp3 = "MP3"
    case alac = "ALAC"
    case flac = "FLAC"
    case opus = "Opus"
    case unknown = "Unknown"

    init(formatID: AudioFormatID) {
        switch formatID {
        case kAudioFormatLinearPCM:
            self = .pcm
        case kAudioFormatMPEG4AAC:
            self = .aac
        case kAudioFormatMPEGLayer3:
            self = .mp3
        case kAudioFormatAppleLossless:
            self = .alac
        case kAudioFormatFLAC:
            self = .flac
        case kAudioFormatOpus:
            self = .opus
        default:
            // Try to extract FourCC as string
            let bytes: [UInt8] = [
                UInt8((formatID >> 24) & 0xFF),
                UInt8((formatID >> 16) & 0xFF),
                UInt8((formatID >> 8) & 0xFF),
                UInt8(formatID & 0xFF)
            ]
            if let fourCC = String(bytes: bytes, encoding: .ascii), !fourCC.isEmpty {
                self = .unknown
            } else {
                self = .unknown
            }
        }
    }

    var displayName: String {
        return self.rawValue
    }
}

