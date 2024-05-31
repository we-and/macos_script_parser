//
//  NodeView.swift
//  script_parser
//
//  Created by Jean Dumont on 31/05/2024.
//

import Foundation
import SwiftUI
struct NodeView: View {
    @State private var isExpanded: Bool = false
    let node: FileNode
    let isSelected: Bool
    let model:AppViewModel
    let toggleExpand: () -> Void

    var body: some View {
        Button(action: {
          //  isExpanded.toggle()
            if node.isDirectory {
                toggleExpand()
            }else{
                selectFile(node)
            }
        }) {
            HStack {
                if node.isDirectory {
                    Image(systemName:isSelected ? "folder" : "folder")
                     //   .resizable()
                        .foregroundColor( .brown)
                       //z                      .frame(width: 12, height: 12)//Image(systemName: isExpanded ? "folder" : "folder.fill")
                    //        }
                } else {
                    Image(systemName: "doc")
                        .foregroundColor(node.isDirectory ? .brown : (isSupportedExtension(ext: node.url.pathExtension) ? .blue :Color(red:0.5,green: 0.5,blue: 0.5)))

                }
                
                Text(node.url.lastPathComponent )
                    .foregroundColor(node.isDirectory ? .brown : (isSupportedExtension(ext: node.url.pathExtension) ? .blue :Color(red:0.5,green: 0.5,blue: 0.5)))
                    .fontWeight(node.isDirectory ? .bold : .regular)
                Spacer()
            } .contextMenu {
                Button("Open") {
                    
                    
                    if node.isDirectory {
                        // Open directory in Finder
                        NSWorkspace.shared.open(node.url)
                    } else {
                        // Open file with default application
                        NSWorkspace.shared.open(node.url)
                    }
                    
                }
                
            }
        }   .buttonStyle(PlainButtonStyle())
    }
        
    func selectFile(_ node: FileNode) {
        model.processFile(node.url)
    }
}
