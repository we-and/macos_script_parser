//
//  TabPersonnages.swift
//  script_parser
//
//  Created by Jean Dumont on 26/05/2024.
//

import Foundation
import SwiftUI


struct CharacterTableRow: Identifiable {
    var id = UUID()
    var personnage: String
    var status: String
    var caracteres: Double
    var repliques: Double
}


class CharacterViewModel: ObservableObject {
    @Published var data: [CharacterTableRow] = []

    func resetTable() {
        data.removeAll()
    }

    func addRow( personnage: String, caracteres: Double, repliques: Double) {
        let newDialogue = CharacterTableRow( personnage: personnage,status: "VISIBLE", caracteres: caracteres, repliques: repliques)
        data.append(newDialogue)
    }

}
struct CharactersTableHeader: View {
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack {
                Text("Personnage").frame(width:geometry.size.width * 0.4,alignment: .leading)
                Text("Statut").frame(width:geometry.size.width * 0.4, alignment: .leading)
                Text("Caractères").frame(width:geometry.size.width * 0.1, alignment: .leading)
                Text("Répliques").frame(width:geometry.size.width * 0.1,alignment: .leading)
            }
            .font(.headline)
            .frame(maxWidth: .infinity,maxHeight: 40)
        } .frame(height: 20).padding()
    }
}

struct CharacterTableView: View {
    @ObservedObject var characterViewModel: CharacterViewModel

    var body: some View {
        VStack {
            CharactersTableHeader()
            GeometryReader { geometry in
                List {
                    ForEach(characterViewModel.data, id: \.id) { dialogue in
                        HStack {
                            Text(dialogue.personnage)
                                .frame(width: geometry.size.width * 0.4, alignment: .leading)
                            Text(dialogue.status)
                                .frame(width: geometry.size.width * 0.4, alignment: .leading)
                            Text("\(Int(dialogue.caracteres.rounded()))")
                                .frame(width: geometry.size.width * 0.1, alignment: .leading)
                            Text("\(Int(dialogue.repliques.rounded()))")
                                .frame(width: geometry.size.width * 0.1, alignment: .leading)
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
        }.frame(maxWidth: .infinity)
    }
}
