//
//  TabDialogPerPersonnage.swift
//  script_parser
//
//  Created by Jean Dumont on 26/05/2024.
//

import Foundation
import SwiftUI

struct DialogueOrderDialogTableRow: Identifiable {
    var id = UUID()
    var lineIdx: Int
    var dialogue: String
    var dialogue_raw: String
    var caracteres: Double
    var repliques: Double
}

struct DialogueCharacterTableHeaderRight: View {
    var body: some View {
        HStack {
            Text("Ligne").frame(maxWidth: .infinity, alignment: .leading)
            Text("Dialogue").frame(maxWidth: .infinity, alignment: .leading)
        Text("Characteres").frame(maxWidth: .infinity, alignment: .leading)
            Text("Repliques").frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.headline)
    }
}


class DialogueCharacterNamesViewModel: ObservableObject {
    @Published var data: [String] = []

    var onItemTapped: ((String) -> Void)?
    
    func resetTable() {
        data.removeAll()
    }

    func addRow( personnage: String) {
        data.append(personnage)
    }
    func itemTapped(_ item: String) {
        
        
          print("Item tapped: \(item)")
          // Add your custom logic here
        onItemTapped?(item)
      }
}


class DialogueCharacterDialogViewModel: ObservableObject {
    @Published var data: [DialogueOrderDialogTableRow] = []

    func resetTable() {
        data.removeAll()
    }

    func addRow( lineIdx:Int,dialog:String, dialog_raw:String, caracteres: Double, repliques: Double) {
        let newDialogue = DialogueOrderDialogTableRow( lineIdx:lineIdx, dialogue:dialog,dialogue_raw: dialog_raw, caracteres: caracteres, repliques: repliques)
        data.append(newDialogue)
    }
}


struct DialogPerCharacterTabView: View {
    @ObservedObject var dialogueCharacterNamesViewModel: DialogueCharacterNamesViewModel
    @ObservedObject var dialogueCharacterDialogViewModel: DialogueCharacterDialogViewModel

   var onItemTapped: (String) -> Void // Closure to handle item tapped

    var body: some View {
        HStack {
            // Left: List of items
            List(dialogueCharacterNamesViewModel.data, id: \.self) { item in
                Text(item)
                    .onTapGesture {
                        dialogueCharacterNamesViewModel.itemTapped(item)
                    }
            }
            .frame(minWidth: 230,maxWidth: 230)
            
            // Right: Table with columns "Ligne", "Characteres", and "Repliques"
            VStack {
                DialogueCharacterTableHeaderRight()
                List {
                    ForEach($dialogueCharacterDialogViewModel.data, id: \.id) { $dialogue in
                        
                        HStack {
                            Text("\(dialogue.lineIdx)").frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(dialogue.dialogue_raw)").frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(Int(dialogue.caracteres))").frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(format: "%.1f", dialogue.repliques)).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .frame(minWidth: 300)
            }
        
        } .onAppear {
            // Set the closure to call the function in this view
            dialogueCharacterNamesViewModel.onItemTapped = { item in
               self.handleItemTapped(item)
           }
        }
    }
    // Function to handle item tap
       func handleItemTapped(_ item: String) {
           // Add custom logic for handling item taps here
           print("Handle item tapped in DialogPerCharacterTabView: \(item)")
           
           // Example logic to add a row to the right table
        //   let newRow = RightTableRow(ligne: selectedTableRows.count + 1, characteres: Double(item.count), repliques: Double.random(in: 1...10))
          // selectedTableRows.append(newRow)
           onItemTapped(item)
       }

}

