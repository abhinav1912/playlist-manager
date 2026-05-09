//
//  MetadataReader.swift
//  PlaylistManager
//
//  Created by Abhinav Mathur on 09/05/26.
//

import Foundation

protocol MetadataReader {
    func readMetadata(for path: URL) -> AudioMetadata?
}

protocol MetadataWriter {
    // TODO: implement updation logic
}

protocol MetadataService: MetadataReader, MetadataWriter {}

class MetadataServiceImpl: MetadataService {
    func readMetadata(for path: URL) -> AudioMetadata? {
        // TODO: implement metadata parsing
        nil
    }
}
