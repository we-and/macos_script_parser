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
            extractedText += pageText+"\n"
        }
    }
    
    return extractedText
}

func cropPDF(pdfPath: URL, outputPath: URL, rel:LeftBottomWidthHeight) {
    
    guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath.path)) else {
        print("Failed to open PDF document.")
        return
    }

    let pageCount = document.pageCount

    for pageIndex in 0..<pageCount {
        guard let page = document.page(at: pageIndex) else {
            continue
        }
        
        var cropBox = page.bounds(for: .cropBox)
        if pageIndex<1{
            print("---")
            print("cropbox or  origin x \(cropBox.origin.x)")
            print("cropbox or origin y \(cropBox.origin.y)")
            print("cropbox or size x \(cropBox.size.width)")
            print("cropbox or size y \(cropBox.size.height)")
            
            print("remove width \(rel.left)")
         //   print("remove width \(rel.right)")
           // print("remove height \(rel.top)")
            print("remove height \(rel.bottom)")
        }  
        //cropBox.origin.x += CGFloat(rel.left)
       // cropBox.origin.y += CGFloat(rel.bottom)
       // cropBox.size.width -= CGFloat(rel.width)
       // cropBox.size.height -= CGFloat(rel.height)
        
        
//        cropBox.origin.x += CGFloat(rel.left)
  //            cropBox.origin.y += CGFloat(rel.bottom)
    //          cropBox.size.width = CGFloat(rel.width)
      //        cropBox.size.height = CGFloat(rel.height)

        
        cropBox.origin.x = CGFloat(rel.left)
              cropBox.origin.y = CGFloat(rel.bottom)
              cropBox.size.width = CGFloat(rel.width)
              cropBox.size.height = CGFloat(rel.height)
        
        if pageIndex<1{
            print("croppage \(pageIndex)")
            print("cropbox origin x \(cropBox.origin.x)")
            print("cropbox origin y \(cropBox.origin.y)")
            print("cropbox size x \(cropBox.size.width)")
            print("cropbox size y \(cropBox.size.height)")
        }
        page.setBounds(cropBox, for: .cropBox)
    }

    print("Try write at \(outputPath.path).")
    if document.write(to: URL(fileURLWithPath: outputPath.path)) {
        print("Cropped PDF saved successfully.")
    } else {
        print("Failed to save cropped PDF.")
    }
}

