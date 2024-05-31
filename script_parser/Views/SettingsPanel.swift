import SwiftUI

struct PanelView: View {
    @Binding var blockSize: Int
       @State private var textInput: String = ""
    
    @State private var resultFolder: String = ""

    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Taille des répliques")
                TextField("Enter size", text:  Binding(
                    get: { String(blockSize) },
                    set: {
                        if let value = Int($0) {
                            blockSize = value
                        }
                    }))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .onChange(of: textInput) { newValue in
                                       if let value = Int(newValue) {
                                           blockSize = value
                                       }
                                   }
            }
            .padding()


            HStack {
                Button(action: onSave) {
                    Text("Enregister")
                }
                .padding()

                Button(action: onCancel) {
                    Text("Annuler")
                }
                .padding()
            }
        }
        .padding()
    }
}
