//
//  ViewModel.swift
//  script_parser
//
//  Created by Jean Dumont on 26/05/2024.
//

import Foundation
import Foundation
import Combine

class AppViewModel: ObservableObject {
    @Published var shouldOpenFolder: Bool = false

    @Published  var currentResultFolder:URL?
     var currentBreakdown:[BreakdownItem1]=[]
     var currentBreakdownPerCharacter:[String:[BreakdownItem1]]=[:]
    
    @Published   var selectedFileContent: String = "Choisissez un fichier de la liste"
    @Published   var title: String = " "

    
     var dialogueOrderViewModel = DialogueOrderViewModel()
     var characterViewModel = CharacterViewModel()
     var dialogueCharacterNamesViewModel = DialogueCharacterNamesViewModel()
     var dialogueCharacterDialogViewModel =  DialogueCharacterDialogViewModel()
    
    func openFolder() {
        // Implement the function to handle folder opening logic
        print("openFolder function called in ContentView.")
    }
    
    
 func clearTables(){
     
     dialogueOrderViewModel.resetTable() ;
     characterViewModel.resetTable();
     dialogueCharacterNamesViewModel.resetTable()   ;
     dialogueCharacterDialogViewModel.resetTable()   ;
 }
    
    
    func processFile(_ url: URL) {
        guard isSupportedExtension(ext: url.pathExtension) else {
            selectedFileContent = "Selected file is not supported file"
            return
        }
        let (fileName, fileExtension) = getFileNameAndExtension(from: url)
       
        createFolderInDocuments(folderName: "scripti")
        let outputFolder = getOutputFolder(fileName: fileName )
        createFolderInDocuments(folderName: "scripti/\(fileName)")
        
        if url.pathExtension=="txt"{
            processTxtFile(url:url)
        }else if url.pathExtension=="docx"{
            processDocxFile(url: url)
        }else if url.pathExtension=="rtf"{
            processRtfFile(url: url)
        }else if url.pathExtension=="doc"{
            processDocxFile(url: url)
        }else if url.pathExtension=="pdf"{
            processPdfFile(url: url)
        }else if url.pathExtension=="xlsx"{
            processXlsxFile(url: url)
        }
    }
    func processPdfFile(url:URL){
        print("processPdfFile ")
        let text=extractTextFromPDF(url: url)
        guard let text=text else{
            print("TextExtraction failed")
            return
        }
        let (fileName, fileExtension) = getFileNameAndExtension(from: url)
        let outputFolder = getOutputFolder(fileName: fileName )
        guard let outputFolder=outputFolder else{
            print("Cannot get outputFolder")
            return
        }
        let newfilename="\(fileName).txt"
        let newurl=createFileURL(folder:outputFolder,filename:newfilename)
        saveStringToFile(text,to:newurl)
        print("url \(newurl.path)")
        processTxtFile(url: newurl)
    }
    func processDocxFile(url:URL){
        readDocxFile(atPath: url.path)
    }
    
    func processXlsxFile(url:URL){
        
    }
    
    func processDocFile(url:URL){
        
    }
    
    func processRtfFile(url:URL){
        
    }
    func processTxtFile( url: URL) {
    
        clearTables()
        let content=readTextFile(at: url)
        if content != nil{
            self.selectedFileContent  = content!.0
            let encoding=content!.1
            // name, extension = os.path.splitext(file_name)
            let (fileName, fileExtension) = getFileNameAndExtension(from: url)
            title=fileName
            
            
           
            
            let folder = getOutputFolder(fileName: fileName )
            guard let folder = folder else{
                return
            }
                let (success,breakdown,breakdownPerCharacter,dialogueOrderData,characterData)=processScript1(scriptPath: url, outputPath: folder, scriptName: fileName, encoding: encoding)
                if success{
                    currentBreakdown=breakdown
                    currentBreakdownPerCharacter=breakdownPerCharacter
                    dialogueOrderViewModel.data=dialogueOrderData
                    characterViewModel.data=characterData
                    currentResultFolder=folder
                    for k in characterData{
                        dialogueCharacterNamesViewModel.addRow(personnage: k.personnage)

                    }
                
                }
            
        }
    }
}
