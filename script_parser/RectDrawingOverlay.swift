import SwiftUI
struct RectangleDrawingOverlay: View {
    @Binding var startPoint: CGPoint?
    @Binding var currentRect: CGRect
  
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Semi-transparent red overlay with a hole for the selected rectangle
                    Path { path in
                        path.addRect(geometry.frame(in: .local))
                        path.addRect(currentRect)
                    }
                    .fill(Color.red.opacity(0.3), style: FillStyle(eoFill: true))

                    Color.clear
                        .contentShape(Rectangle()) // Make the entire view tappable
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if startPoint == nil {
                                                                       startPoint = value.startLocation
                                                                   }
                                                                   if let startPoint = startPoint {
                                                                       let width = value.location.x - startPoint.x
                                                                       let height = value.location.y - startPoint.y
                                                                       currentRect = CGRect(x: min(startPoint.x, value.location.x),
                                                                                            y: min(startPoint.y, value.location.y),
                                                                                            width: abs(width),
                                                                                            height: abs(height))
                                                                   }
                                }
                                .onEnded { _ in
                                    startPoint = nil
                                }
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: currentRect.width, height: currentRect.height)
                                .position(x: currentRect.midX, y: currentRect.midY)
                        )
                        .overlay(
                            Group {
                                handle(at: CGPoint(x: currentRect.minX, y: currentRect.minY),  dragHandler: { newLocation in
                                                               let width = currentRect.maxX - newLocation.x
                                                               let height = currentRect.maxY - newLocation.y
                                                               currentRect = CGRect(x: newLocation.x, y: newLocation.y, width: width, height: height)
                                                           })
                                                           handle(at: CGPoint(x: currentRect.maxX, y: currentRect.minY),  dragHandler: { newLocation in
                                                               let width = newLocation.x - currentRect.minX
                                                               let height = currentRect.maxY - newLocation.y
                                                               currentRect = CGRect(x: currentRect.minX, y: newLocation.y, width: width, height: height)
                                                           })
                                                           handle(at: CGPoint(x: currentRect.minX, y: currentRect.maxY), dragHandler: { newLocation in
                                                               let width = currentRect.maxX - newLocation.x
                                                               let height = newLocation.y - currentRect.minY
                                                               currentRect = CGRect(x: newLocation.x, y: currentRect.minY, width: width, height: height)
                                                           })
                                                           handle(at: CGPoint(x: currentRect.maxX, y: currentRect.maxY),  dragHandler: { newLocation in
                                                               let width = newLocation.x - currentRect.minX
                                                               let height = newLocation.y - currentRect.minY
                                                               currentRect = CGRect(x: currentRect.minX, y: currentRect.minY, width: width, height: height)
                                                           })
                            }
                        )
                }
            }
        }
    
    private func handle(at point: CGPoint, dragHandler: @escaping (CGPoint) -> Void) -> some View {
          ResizeHandle()
              .position(point)
              .gesture(
                  DragGesture(minimumDistance: 0)
                      .onChanged { value in
                          dragHandler(value.location)
                      }
              )
      }
}
