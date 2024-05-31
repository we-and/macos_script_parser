//
//  FileNode.swift
//  script_parser
//
//  Created by Jean Dumont on 26/05/2024.
//

import Foundation

struct FileNode: Identifiable {
    var id: URL
    var url: URL
    var isDirectory: Bool
    var children: [FileNode]?
    
    init(url: URL) {
            self.url = url
            self.id = url
            var isDir: ObjCBool = false
            FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
            self.isDirectory = isDir.boolValue
            if isDir.boolValue {
                let directoryContents = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles))?.map(FileNode.init)
                self.children = directoryContents?.sorted { $0.isDirectory && !$1.isDirectory }
            }
        }
}
