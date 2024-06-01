//
//  Pdf.swift
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

import Foundation
import PDFKit
func extractTextFromPDF(url: URL) -> String? {
    // Load the PDF document
    guard let pdfDocument = PDFDocument(url: url) else {
        print("Failed to load PDF document")
        return nil
    }
    
    // Initialize an empty string to hold the extracted text
    var extractedText = ""
    
    // Iterate through each page of the PDF
    for pageIndex in 0..<pdfDocument.pageCount {
        // Get the current page
        guard let page = pdfDocument.page(at: pageIndex) else { continue }
        
        // Extract the text from the page
        if let pageText = page.string {
            extractedText += pageText
        }
    }
    
    return extractedText
}

func cropPDF(pdfPath: String, outputPath: String, left: Double, right: Double, top: Double, bottom: Double) {
    guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else {
        print("Failed to open PDF document.")
        return
    }

    let pageCount = document.pageCount

    for pageIndex in 0..<pageCount {
        guard let page = document.page(at: pageIndex) else {
            continue
        }
        
        var cropBox = page.bounds(for: .cropBox)
        cropBox.origin.x += CGFloat(left)
        cropBox.origin.y += CGFloat(bottom)
        cropBox.size.width -= CGFloat(left + right)
        cropBox.size.height -= CGFloat(top + bottom)
        
        page.setBounds(cropBox, for: .cropBox)
    }

    if document.write(to: URL(fileURLWithPath: outputPath)) {
        print("Cropped PDF saved successfully.")
    } else {
        print("Failed to save cropped PDF.")
    }
}

