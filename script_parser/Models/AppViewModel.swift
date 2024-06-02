//
//  ViewModel.swift
//  script_parser
//
//  Created by Jean Dumont on 26/05/2024.
//

import Foundation
import Foundation
import Combine
import SwiftUI
import PDFKit
class AppViewModel: ObservableObject {
  
    @StateObject private var  globalSettingsViewModel = GlobalSettingsViewModel()

    
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
    
    
    // Method to open file picker
    @objc    func openScript() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a .txt file"
        openPanel.allowedFileTypes = ["txt","pdf","rtf","docx","xlsx","doc"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.url {
                
                self.processFile(url)
                
//                let folder=getOutputFolder(
  //              processScript1(scriptPath: url, outputPath: <#T##URL#>, scriptName: <#T##String#>, encoding: <#T##String.Encoding?#>)
//                self.handleSelectedFile(url: url)
            }
        }
            
    }
  

    

    @objc  func openPanelWindow() {
        let panelWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false)
        panelWindow.center()
        panelWindow.setFrameAutosaveName("Panel Window")
       
        panelWindow.contentView = NSHostingView(rootView: PanelView(
            blockSize:$globalSettingsViewModel.blockSize,
            onSave: {
                // Handle save action
                print("Save action triggered")
                panelWindow.close()
            },
            onCancel: {
                // Handle cancel action
                print("Cancel action triggered")
                panelWindow.close()
            }
        ))
        panelWindow.makeKeyAndOrderFront(nil)
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
        showPDFWithRectangleDrawing(pdfPath:url)
    }
    func doCrop(pdfPath:URL,rel:LeftBottomWidthHeight)->URL?{

        let (fileName, fileExtension) = getFileNameAndExtension(from: pdfPath)
     

        let outputFolder = getOutputFolder(fileName: fileName )
        guard let outputFolder = outputFolder else{
            return nil
        }
            let newfilename="cropped.pdf"
        let newurl=createFileURL(folder:outputFolder,filename:newfilename)
        
        
        
        cropPDF(pdfPath: pdfPath,outputPath: newurl , rel:rel)
return newurl
        }
    func processCroppedPdfFile(originalPdfUrl:URL,croppedPdfUrl:URL){
        print("processPdfFile ")
        let text=extractTextFromPDF(url: croppedPdfUrl)
        guard let text=text else{
            print("TextExtraction failed")
            return
        }
        let (fileName, fileExtension) = getFileNameAndExtension(from: originalPdfUrl)
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
    func showPDFWithRectangleDrawing(pdfPath: URL) {
        let pageNumber=10
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("PDF Window")
        window.contentView = NSHostingView(rootView: RectangleDrawingView(pdfPath: pdfPath.path, pageNumber: pageNumber ,onOk: { rect in
                // Convert rect to appropriate coordinates for cropping
                self.doCrop1(pdfPath: pdfPath, cropRect: rect)
                window.close()
            },
            onCancel: {
                window.close()
            },model:self))
            window.makeKeyAndOrderFront(nil)
        }
    
    func doCrop1(pdfPath:URL, cropRect:LeftBottomWidthHeight){
        guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath.path)) else {
                print("Failed to open PDF document.")
                return
            }

            guard let page = document.page(at: 0) else { // Assuming single page for simplicity
                print("Failed to get PDF page.")
                return
            }
        
        print("crop left=\(cropRect.left)")
        print("crop bottom=\(cropRect.bottom)")
     //   print("crop right=\(cropRect.right)")
       // print("crop top=\(cropRect.top)")
       let croppedUrl = doCrop(pdfPath: pdfPath, rel:cropRect)
        guard let croppedUrl=croppedUrl else{
            return
        }
        processCroppedPdfFile(originalPdfUrl: pdfPath,croppedPdfUrl:croppedUrl)
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                   // Now you can access properties or methods of the AppDelegate
                   appDelegate.setUpMenuBar()
               } else {
                   print("Failed to access AppDelegate")
               }
//        let extractedText=extractTextFromPDF(url:croppedUrl)
  //      print("Extracted text")
        
        
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
