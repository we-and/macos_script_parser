import SwiftUI
struct RectangleDrawingView: View {
    @State private var startPoint: CGPoint? = nil
    @State private var currentRect: CGRect = .zero
    let pdfPath: String
    let pageNumber: Int
    let onOk: (CGRect) -> Void
    let onCancel: () -> Void
    let model:AppViewModel
    var body: some View {
          VStack {
              // Top Text
              Text("Select an area on the PDF")
                  .font(.headline)
                  .padding()

              // PDF and Rectangle Drawing
              ZStack {
                  PDFViewContainer(pdfPath: pdfPath, pageNumber: pageNumber)
                      .background(Color.white)

                  RectangleDrawingOverlay(startPoint: $startPoint, currentRect: $currentRect)
              }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              
              // Bottom Buttons
              HStack {
                  Button("Cancel") {
                      onCancel()
                  }
                  .padding()
                  .cornerRadius(8)
                  
                  Button("OK") {
                      onOk(currentRect)
                  }
                  .padding()
                  .cornerRadius(8)
              }
              .padding()
          }
      }
  
}
