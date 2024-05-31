//
//  FileNodeView.swift
//  script_parser
//
//  Created by Jean Dumont on 31/05/2024.
//

import Foundation
import SwiftUI
struct NodeListView: View {
    let node: FileNode
    @Binding var expandedNodes: Set<URL>
    let model:AppViewModel
    
    
    var body: some View {
        NodeView(node: node, isSelected: expandedNodes.contains(node.url),model:model) {
            toggleExpand(node)
        }
        if expandedNodes.contains(node.url), let children = node.children {
            ForEach(children, id: \.id) { child in
                NodeListView(node: child, expandedNodes: $expandedNodes,model: model)
                    .padding(.leading, 20)
            }
        }
    }

        
        
    private func toggleExpand(_ node: FileNode) {
        print("toggle \(expandedNodes)")
        if expandedNodes.contains(node.url) {
            expandedNodes.remove(node.url)
        } else {
            expandedNodes.insert(node.url)
        }
    }
}
