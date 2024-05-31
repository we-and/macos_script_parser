//
//  ContentView.swift
//  python_script_parser
//
//  Created by Jean Dumont on 24/05/2024.
//

import SwiftUI
import AppKit



struct ContentView: View {

    @EnvironmentObject var appDelegate: AppDelegate

    @State private var rootNode: FileNode = FileNode(url: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
    @State private var expandedNodes: Set<URL> = [URL(fileURLWithPath: FileManager.default.currentDirectoryPath)]
    @State private var tableRows: [TableRow] = []
    
    @ObservedObject var appViewModel: AppViewModel
    
   // @State var currentResultFolder:URL?
   // @State var currentBreakdown:[BreakdownItem1]=[]
   //['P)_" @State var currentBreakdownPerCharacter:[String:[BreakdownItem1]]=[:]
    
    var body: some View {
        NavigationView {
            // Left Panel: Folder Tree View
            List {
                           OutlineGroup(rootNode, children: \.children) { node in
                               HStack {
                                   Image(systemName: node.isDirectory ? "folder" : "doc")
                                                         .foregroundColor(node.isDirectory ? .brown : (node.url.pathExtension == "txt" ? .blue : .primary))
                                    Text(node.url.lastPathComponent)
                                       .foregroundColor(node.isDirectory ? .brown : (node.url.pathExtension == "txt" ? .blue : .primary))
                                                         .fontWeight(expandedNodes.contains(node.url) ? .bold : .regular)
                                               
                               } .contextMenu {
                                   Button("Open") {
                                       openNode(node)
                                   }
                               }  .onTapGesture {
                                       selectFile(node)
                                   
                               }
                           }
                       }
                       .listStyle(DefaultListStyle())
                       .frame(minWidth: 200)
                       .onAppear {
                                       expandedNodes.insert(rootNode.url)
                                   }
            
            // Right Panel: Tab View with 5 Tabs
            VStack {
                // Title Header
                HStack {
                    Text(appViewModel.title)
                        .font(.title)
                        .padding(.leading, 10) // Adjust the leading padding
                                  .padding(.top, 10) // Adjust the top padding
                                  .padding(.bottom, 5)
                    Spacer()
                }
                
                TabView {
                    TextEditor(text: $appViewModel.selectedFileContent)
                        .font(.system(.body, design: .monospaced))
                        .tabItem {
                            Label("Texte", systemImage: "1.circle")
                        }
                    CharacterTableView(characterViewModel:appViewModel.characterViewModel)
                        .tabItem {
                            Label("Personnages", systemImage: "3.circle")
                        }
                    
                    DialogOrderTableView(dialogueOrderViewModel: appViewModel.dialogueOrderViewModel)
                        .tabItem {
                            Label("Dialogue dans l'ordre", systemImage: "3.circle")
                        }
                    // Custom view for Tab 4
                    DialogPerCharacterTabView(dialogueCharacterNamesViewModel:appViewModel.dialogueCharacterNamesViewModel,
                                              dialogueCharacterDialogViewModel:appViewModel.dialogueCharacterDialogViewModel,
                                              onItemTapped:handleDialogByCharacterItemTapped)
                    .tabItem {
                        Label("Dialogue par personnage", systemImage: "4.circle")
                    }
                    
                    VStack {
                        
                        Button("Ouvrir le dossier de resultats") {
                            // Action for "Ouvrir dossier de resultats"
                            openDossierResultats()
                        }
                        .padding()
                        
                        Button("Ouvrir comptage xlsx") {
                            // Action for "Ouvrir comptage xlsx"
                            openComptageXlsx()
                        }
                        .padding()
                        
                        
                        Button("Ouvrir le détail du dialogue") {
                            // Action for "Ouvrir detail dialogue"
                            openDetailDialogue()
                        }
                        .padding()
                        
                        Button("Test") {
                            // Action for "Ouvrir detail dialogue"
                            test()
                        }
                        .padding()
                    }
                    .tabItem {
                        Label("Export", systemImage: "5.circle")
                    }
                }
                .frame(minWidth: 300)
                .onChange(of: appViewModel.shouldOpenFolder) { newValue in
                    if newValue {
                        openFolder();
                        //                               viewModel.openFolder()
                        appViewModel.shouldOpenFolder = false // Reset the flag
                    }
                }
            }
        }
    }
    // Recursive function to expand a node and its children
      private func expandNode(node: FileNode) {
          expandedNodes.insert(node.url)
         // if let children = node.children {
           //   for child in children {
             //     expandNode(node: child)
             // }
          //}
      }
    
    func test(){
        expandNode(node: rootNode)
        print("\(expandedNodes)")
    }
    // Function to handle item tapped in ContentView
       func handleDialogByCharacterItemTapped(_ item: String) {
           print("Handle item tapped in ContentView: \(item)")
           // Your custom logic here
           
           if appViewModel.currentBreakdownPerCharacter.keys.contains(item)
           {
               appViewModel.dialogueCharacterDialogViewModel.resetTable()
               let list=appViewModel.currentBreakdownPerCharacter[item]!
               for k in list{
                   if k.type=="SPEECH"{
                       if k.speech != nil && k.speech_raw != nil{
                           let len_rep=computeLength(by: ComputeMethod.blocks50, for: k.speech!)
                           let len_all=computeLength(by: ComputeMethod.all, for: k.speech!)
                           appViewModel.dialogueCharacterDialogViewModel.addRow(lineIdx: k.lineIdx, dialog: k.speech!,dialog_raw: k.speech_raw!,   caracteres:len_all, repliques:len_rep)
                       }
                   }
               }
           }
           
       }
    func openDetailDialogue() {
        let currentDirectory = FileManager.default.currentDirectoryPath
        print("Open folder \(appViewModel.currentResultFolder)")
        guard let currentResultFolder=appViewModel.currentResultFolder else{
            return
        }
        let folderPath = appendPathComponent(baseURL: currentResultFolder, path: "dialogue.csv")

        if folderPath != nil{
            print("path")
            if FileManager.default.fileExists(atPath: folderPath.path) {
                print("Open folder \(currentDirectory) exists")
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folderPath.path)
            } else {
                print("The folder does not exist at path: \(folderPath)")
            }
        }else{
            print("No path")
        
        }
    }
    func openDossierResultats() {
        print("openDossierResultats folder=\(appViewModel.currentResultFolder)")
        let folderPath = appViewModel.currentResultFolder
        
        if folderPath != nil{
            print("path")
            if FileManager.default.fileExists(atPath: folderPath!.path) {
                print("Open folder \(folderPath) exists")
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folderPath!.path)
            } else {
                print("The folder does not exist at path: \(folderPath!)")
            }
        }else{
            print("No path")
        
        }
    }
    func openComptageXlsx() {
        print("Open folder \(appViewModel.currentResultFolder)")
        guard let currentResultFolder=appViewModel.currentResultFolder else{
            return
        }
        let folderPath = appendPathComponent(baseURL: currentResultFolder, path: "comptage.csv")

        if folderPath != nil{
            print("path")
            if FileManager.default.fileExists(atPath: folderPath.path) {
                print("Open folder \(folderPath) exists")
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folderPath.path)
            } else {
                print("The folder does not exist at path: \(folderPath)")
            }
        }else{
            print("No path")
        
        }
    }
    
    
    // Table functions
       func addTableRow() {
           let newRow = TableRow(personnage: "New Personnage", status: "New Status", character: "New Character", repliques: "New Répliques")
           tableRows.append(newRow)
       }
       
    // Select and Read File Content
    func selectFile(_ node: FileNode) {
        appViewModel.processFile(node.url)
    }
 
    func openPreferences() {
        print("Open Preferences action")
    }
    
    func openAccountSettings() {
        print("Open Account Settings action")
    }
    
       // Action for Opening Node
       func openNode(_ node: FileNode) {
           if node.isDirectory {
               // Open directory in Finder
               NSWorkspace.shared.open(node.url)
           } else {
               // Open file with default application
               NSWorkspace.shared.open(node.url)
           }
       }
    
    
    // Open Folder and Set as Root Node
      func openFolder() {
          let panel = NSOpenPanel()
          panel.canChooseDirectories = true
          panel.canChooseFiles = false
          panel.allowsMultipleSelection = false
          panel.begin { response in
              if response == .OK {
                  if let url = panel.url {
                      rootNode = FileNode(url: url)
                      expandedNodes.removeAll()
                  }
              }
          }
      }
   
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appViewModel: AppViewModel()).environmentObject(AppDelegate())
    }
}


