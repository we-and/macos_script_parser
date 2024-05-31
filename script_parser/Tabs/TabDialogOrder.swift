//
//  TabDialogOrder.swift
//  script_parser
//
//  Created by Jean Dumont on 26/05/2024.
//

import Foundation
import SwiftUI


struct DialogueOrderTableRow: Identifiable {
    var id = UUID()
    var ligne: Int
    var personnage: String
    var dialog: String
    var dialog_raw: String
 var caracteres: Double
    var repliques: Double
}

class DialogueOrderViewModel: ObservableObject {
    @Published var data: [DialogueOrderTableRow] = []

    func resetTable() {
        data.removeAll()
    }

    func addRow(ligne: Int, personnage: String,  dialog: String, dialog_raw: String, caracteres: Double, repliques: Double) {
        let newDialogue = DialogueOrderTableRow(ligne: ligne, personnage: personnage,dialog: dialog,dialog_raw: dialog, caracteres: caracteres, repliques: repliques)
        data.append(newDialogue)
    }
}



struct DialogOrderTableHeader: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("Ligne").frame(width:geometry.size.width * 0.1, alignment: .leading)
                Text("Personnage").frame(width:geometry.size.width * 0.35, alignment: .leading)
                Text("Dialogue").frame(width:geometry.size.width * 0.35, alignment: .leading)
                Text("Caractères").frame(width:geometry.size.width * 0.1, alignment: .leading)
                Text("Répliques").frame(width:geometry.size.width * 0.1,alignment: .leading)
            }
            .font(.headline)
            .frame(maxWidth: .infinity,maxHeight: 40)
        } .frame(height: 20).padding()
        
    }
}
struct DialogOrderTableView: View {
    @ObservedObject var dialogueOrderViewModel: DialogueOrderViewModel

    var body: some View {
        VStack {
            DialogOrderTableHeader()
            GeometryReader { geometry in
                List {
                    ForEach($dialogueOrderViewModel.data, id: \.id) { $dialogue in
                        HStack {
                            Text("\(dialogue.ligne)")
                                .frame(width: geometry.size.width * 0.1, alignment: .leading)
                            Text(dialogue.personnage)
                                .frame(width: geometry.size.width * 0.35,alignment: .leading)
                            Text(dialogue.dialog_raw)
                                .frame(width: geometry.size.width * 0.35, alignment: .leading)
                            Text("\(Int(dialogue.caracteres.rounded()))")
                                .frame(width: geometry.size.width * 0.1, alignment: .leading)
                            Text(String(format: "%.1f", dialogue.repliques))
                                .frame(width: geometry.size.width * 0.1, alignment: .leading)
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
        }
    }
}
