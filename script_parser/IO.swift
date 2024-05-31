//
//  IO.swift
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

import Foundation
func createFileURL(folder: URL, filename: String) -> URL {
    return folder.appendingPathComponent(filename)
}
