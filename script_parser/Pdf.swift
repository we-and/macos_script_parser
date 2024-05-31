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
