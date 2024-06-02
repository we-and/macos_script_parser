import SwiftUI
import PDFKit

struct LeftBottomWidthHeight{
    let left:Double
    let bottom:Double
    let width:Double
    let height:Double
   // let right:Double
    //let top:Double
    
    
    
    static let zero = LeftBottomWidthHeight(left: 0, bottom: 0, width: 0, height: 0)//,right:0,top:0)

}
struct RectangleDrawingView: View {
    @State private var startPoint: CGPoint? = nil
    @State private var currentRect: CGRect = .zero
    let pdfPath: String
    let pageNumber: Int
    let onOk: (LeftBottomWidthHeight) -> Void
    let onCancel: () -> Void
    let model:AppViewModel
    
    @State private var pdfViewSize: CGSize = .zero
    var body: some View {
        VStack {
            // Top Text
//            Text("Select an area on the PDF")
  //              .font(.headline)
    //            .padding()
            
            // PDF and Rectangle Drawing
            GeometryReader { geometry in
                ZStack {
                    PDFViewContainer(pdfPath: pdfPath, pageNumber: pageNumber)
                        .background(Color.white)
                        .onAppear {
                            pdfViewSize = geometry.size
                            if let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)),
                                                          let page = document.page(at: pageNumber - 1) {
                                                           let mediaBox = page.bounds(for: .mediaBox)
                                pdfViewSize = CGSize(width: mediaBox.width, height: mediaBox.height)
                            }
                            
                        }   .frame(width: geometry.size.width, height: geometry.size.height) // Ensure it fills the container
                    
                    RectangleDrawingOverlay(startPoint: $startPoint, currentRect: $currentRect)



                    // Bottom Buttons
                    VStack{
                        HStack {
                            Button("Cancel") {
                                onCancel()
                            }
                            .padding()
                            .cornerRadius(8)
                            
                            Button("OK") {
                                
                                let rel=convertToPDFRect(screenRect: currentRect, screenViewerSize: pdfViewSize)
                                
                                print("REl = \(rel)")
                                
                                //                      let pdfViewSize = geometry.size
                                onOk(rel)
                                
                                //                      onOk(currentRect)
                            }
                            .padding()
                            .cornerRadius(8)
                        }
                        .background(Color.white)
                        
                        Spacer()
                    }
                    .padding()

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
        }
    }
    private func convertToPDFRect(screenRect: CGRect, screenViewerSize: CGSize) -> LeftBottomWidthHeight {
        guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)),
              let page = document.page(at: pageNumber - 1) else {
            return .zero
        }
        
        let mediaBox = page.bounds(for: .mediaBox)
        let pdfPageWidth = mediaBox.width
        let pdfPageHeight = mediaBox.height
        
        
        print("PdfViewerSize width=\(screenViewerSize.width)")
        print("PdfViewerSize height=\(screenViewerSize.height)")
        print(" ")
        
        print("pdfPageWidth=\(pdfPageWidth)")
        print("pdfPageHeight=\(pdfPageHeight)")
        print(" ")
        
        // Calculate scale factors
        let scaleX = pdfPageWidth / screenViewerSize.width
        let scaleY = pdfPageHeight / screenViewerSize.height
        let scale = min(scaleX, scaleY)
        print("scale=\(scaleX) \(scaleX)")
        print(" ")
        
        // Calculate the content size within the view
        let screenPageWidth = pdfPageWidth * scale
        let screenPageHeight = pdfPageHeight * scale
        print("screenPageWidth=\(screenPageWidth) \(screenPageHeight)")
        print(" ")
        // Calculate the offset due to centering
        let screenOffsetX = max((screenViewerSize.width - screenPageWidth) / 2, 0)
        let screenOffsetY = max((screenViewerSize.height - screenPageHeight) / 2, 0)
        print("screenOffset=\(screenOffsetX) , \(screenOffsetY)")
        print(" ")
        
        // Convert the rectangle coordinates
        let pdfBoxLeft = (screenRect.minX - screenOffsetX) / scale
        let pdfBoxBottom = (screenViewerSize.height - screenRect.maxY - screenOffsetY) / scale
        let pdfBoxWidth = screenRect.width / scale
        let pdfBoxHeight = screenRect.height / scale
        print("pdfBoxLeft=\(pdfBoxLeft)")
        print("pdfBoxBottom=\(pdfBoxBottom)")
        print("pdfBoxWidth=\(pdfBoxWidth)")
        print("pdfBoxHeight=\(pdfBoxHeight)")
        print(" ")  
        return LeftBottomWidthHeight(left: pdfBoxLeft, bottom: pdfBoxBottom, width: pdfBoxWidth, height: pdfBoxHeight)
    }
    private func convertToPDFRectOld(screenRect: CGRect, screenViewerSize: CGSize) -> LeftBottomWidthHeight {
        guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)),
              let page = document.page(at: pageNumber - 1) else {
            return .zero
        }
        
        let mediaBox = page.bounds(for: .mediaBox)
        
        
        print("PdfViewerSize width=\(screenViewerSize.width)")
        print("PdfViewerSize height=\(screenViewerSize.height)")
        print(" ")
        
        let pdfPageWidth = mediaBox.width
        let pdfPageHeight = mediaBox.height
        
        print("pdfPageWidth=\(mediaBox.width)")
        print("pdfPageHeight=\(mediaBox.height)")
        print(" ")
        
        print("screenRect minX=\(screenRect.minX)")
        print("screenRect maxX=\(screenRect.maxX)")
        print("screenRect minY=\(screenRect.minY)")
        print("screenRect maxY=\(screenRect.maxY)")
        print("screenRect width=\(screenRect.width)")
        print("screenRect height=\(screenRect.height)")
        
        // Calculate scale factors
        let scaleX = pdfPageWidth / screenViewerSize.width
        let scaleY = pdfPageHeight / screenViewerSize.height
        let scale = min(scaleX, scaleY)
        print("scale=\(scaleX) \(scaleX)")
        print(" ")
        
        // Calculate the content size within the view
        let screenPageWidth = pdfPageWidth * scale
        let screenPageHeight = pdfPageHeight * scale
        print("screenPageWidth=\(screenPageWidth) \(screenPageHeight)")
        print(" ")
        
        let pdfSelectionWidth = screenRect.width/scale
        let pdfSelectionHeight = screenRect.height/scale
        print("pdfSelectionSize=\(pdfSelectionWidth) \(pdfSelectionHeight)")
        print(" ")
        
        // Calculate the offset due to centering
        let screenOffsetX = max((screenViewerSize.width - screenPageWidth) / 2,0)
        let screenOffsetY = max((screenViewerSize.height - screenPageHeight) / 2,0)
        
        print("pdfPageSize=\(pdfPageWidth) x \(pdfPageHeight)")
        print(" ")
        
        print("screenOffset=\(screenOffsetX) , \(screenOffsetY)")
        print(" ")
        // Convert the rectangle coordinates
        let pdfBoxLeft = (screenRect.minX - screenOffsetX) / scale
        let pdfBoxBottom = (screenViewerSize.height - screenRect.maxY - screenOffsetY) / scale
        let pdfBoxWidth = screenRect.width / scale
        let pdfBoxHeight = screenRect.height / scale
   //     let pdfBoxRight=pdfPageWidth-pdfLeft-pdfBoxWidth
     //   let pdfBoxTop=pdfPageHeight-pdfBottom-pdfBoxHeight
        
        //   let right = (currentRect.minX - offsetX) * scaleX
        print(" ")
        print("pdfBoxLeft=\(pdfBoxLeft)")
        print("pdfBoxBottom=\(pdfBoxBottom)")
        print("pdfBoxWidth=\(pdfBoxWidth)")
        print("pdfBoxHeight=\(pdfBoxHeight)")
    //    print("pdfBoxRight=\(pdfBoxRight)")
      //  print("pdfBoxTop=\(pdfBoxTop)")
        print(" ")
        return LeftBottomWidthHeight(left: pdfBoxLeft, bottom: pdfBoxBottom, width: pdfBoxWidth, height: pdfBoxHeight)//,right:pdfRight,top:pdfTop)
        //           return CGRect(x: left, y: bottom, width: width, height: height)pdfT       }
        
    }
}
