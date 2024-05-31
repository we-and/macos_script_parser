//
//  Txt.swift
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

import Foundation
func saveStringToFile(_ string: String, to url: URL) {
    do {
        // Write the string to the specified URL
        try string.write(to: url, atomically: true, encoding: .utf8)
        print("String saved successfully to \(url.path)")
    } catch {
        // Handle any errors that occur during writing
        print("Failed to save string to file: \(error)")
    }
}
