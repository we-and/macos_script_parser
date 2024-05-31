//
//  Docx.swift
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

import Foundation

// Define a callback function to handle text content
func handleText(content: UnsafePointer<CChar>?) {
    print("handleText")
    if let content = content {
        let string = String(cString: content)
        print(string)
    }
}

// Define the function prototype
@_silgen_name("read_docx")
func read_docx(_ filename: UnsafePointer<CChar>, _ callback: @escaping @convention(c) (UnsafePointer<CChar>?) -> Void)

// Use the C function in Swift
func readDocxFile(atPath path: String) {
    print("readDocxFile \(path)")
    path.withCString { cString in
        print("readDocxFile \(cString)")
        read_docx(cString, handleText)
    }
}
