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
        showPDFWithRectangleDrawing(pdfPath:url.path)
    }
    func doCrop(pdfPath:String,left: Double, right: Double, top: Double, bottom: Double){
        let        outputPath=pdfPath.replacingOccurrences(of: ".pdf", with: ".cropped.pdf")
        cropPDF(pdfPath: pdfPath,outputPath: outputPath , left: left, right: right, top: top, bottom: bottom)
    }
    func processCroppedPdfFile(url:URL){
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
    func showPDFWithRectangleDrawing(pdfPath: String) {
        let pageNumber=10
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("PDF Window")
            window.contentView = NSHostingView(rootView: RectangleDrawingView(pdfPath: pdfPath, pageNumber: pageNumber ,onOk: { rect in
                // Convert rect to appropriate coordinates for cropping
                self.doCrop1(pdfPath: pdfPath, cropRect: rect)
                window.close()
            },
            onCancel: {
                window.close()
            },model:self))
            window.makeKeyAndOrderFront(nil)
        }
    
    func doCrop1(pdfPath:String, cropRect:CGRect){
        guard let document = PDFDocument(url: URL(fileURLWithPath: pdfPath)) else {
                print("Failed to open PDF document.")
                return
            }

            guard let page = document.page(at: 0) else { // Assuming single page for simplicity
                print("Failed to get PDF page.")
                return
            }

        // Calculate crop box in PDF coordinates
         let mediaBox = page.bounds(for: .mediaBox)
         let viewWidth = UIScreen.main.bounds.width // Assuming you use the screen width for the view size
         let viewHeight = UIScreen.main.bounds.height // Assuming you use the screen height for the view size
         
         // Calculate scale factors based on the actual size of the displayed PDF page in the view
         let scaleX = mediaBox.width / viewWidth
         let scaleY = mediaBox.height / viewHeight
         
         let left = cropRect.minX * scaleX
         let bottom = mediaBox.height - (cropRect.maxY * scaleY)
         let width = cropRect.width * scaleX
         let height = cropRect.height * scaleY
        
        let right=left+width
        let top = bottom-height
        print("Crop")
        
        print("Height \(height)")
        print("Width \(width)")
        print("Left \(left)")
        print("Bottom \(bottom)")
        print("Right \(right)")
        print("Top \(top)")
        print("Right \(right)")

        doCrop(pdfPath: pdfPath, left: left, right:left+width, top: bottom-height, bottom: bottom)
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
