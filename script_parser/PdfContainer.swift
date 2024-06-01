//
//  PdfContainer.swift
//  script_parser
//
//  Created by Jean Dumont on 01/06/2024.
//

import Foundation
import PDFKit
import SwiftUI
struct PDFViewContainer: NSViewRepresentable {
    let pdfPath: String
    let pageNumber: Int

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        if let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)) {
            pdfView.document = document
            pdfView.displayMode = .singlePage
            pdfView.autoScales = true
            if pageNumber > 0 && pageNumber <= document.pageCount {
                pdfView.go(to: PDFDestination(page: document.page(at: pageNumber - 1)!, at: CGPoint.zero))
            }
        }
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        // Update the view if needed
    }
}
