//
//  Process.swift
//  script_parser
//
//  Created by Jean Dumont on 27/05/2024.
//

import Foundation
import CoreXLSX
//import SwiftXLSX
//import xlsxwriter


func processScript1(scriptPath: URL, outputPath: URL, scriptName: String, encoding: String.Encoding?) -> (Bool,[BreakdownItem1],[String:[BreakdownItem1]],[DialogueOrderTableRow],[CharacterTableRow]){
    print("  > -----------------------------------")
    print("  > SCRIPT PARSER version 1.3")
    print("  > Script path       : \(scriptPath)")
    print("  > Output folder     : \(outputPath)")
    print("  > Script name       : \(scriptName)")
    print("  > Forced encoding   : \(encoding  )")
//    print("  > Counting method   : \(countingMethod)")

    
    var currentBreakdown:[BreakdownItem1]=[]
    var currentBreakdownPerCharacter:[String:[BreakdownItem1]]=[:]
    var dialogueOrderData: [DialogueOrderTableRow] = []
    var dialogueCharacterNamesData:[String] = []
    var characterData:[CharacterTableRow]=[];
    
    var empty=(false,currentBreakdown,currentBreakdownPerCharacter,dialogueOrderData,characterData)
    
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: outputPath.path) {
        try? fileManager.createDirectory(atPath: outputPath.path, withIntermediateDirectories: true, attributes: nil)
    }

    let fileName = (scriptPath.absoluteString as NSString).lastPathComponent
    let name = (fileName as NSString).deletingPathExtension
    let fileExtension = (fileName as NSString).pathExtension
    print("  > File name         : \(fileName)")
    print("  > Extension         : \(fileExtension)")

    if !isSupportedExtension(ext: fileExtension) {
        print("  > File type \(fileExtension) not supported.")
        return empty
    }

    if fileExtension.lowercased() == "docx" {
        guard let convertedFilePath = convertWordToTxt(filePath: scriptPath) else {
            print("  > Conversion failed")
            return empty
     }
        processScript1(scriptPath: convertedFilePath, outputPath: outputPath, scriptName: scriptName,  encoding: encoding)
        return  empty
    }

    if fileExtension.lowercased() == "pdf" {
        guard let (convertedFilePath, encoding) = convertPdfToTxt(filePath: scriptPath) else {
            print("  > Conversion failed")
            return empty
    }
        processScript1(scriptPath: convertedFilePath, outputPath: outputPath, scriptName: scriptName,encoding: encoding)
        return  empty
    }

    var breakdown = [BreakdownItem1]()
    var sceneCharactersMap = [String: Set<String>]()
    var characterLineCountMap = [String: Int]()
    var characterOrderMap = [String: Int]()
    var characterTextLengthMap = [String: Int]()
    var characterSceneMap = [String: Set<String>]()
    var characterCount = 1
    var currentSceneCount = 1
    var currentSceneId = "Scene 1"

    var isEmptyLine=false
    let detected:String.Encoding = detectFileEncoding(filePath: scriptPath);
    var encodingUsed:String.Encoding = detected
    if encoding != nil{
        encodingUsed=encoding!
    }
    
    print("  > Encoding used     : \(encodingName(for:  encodingUsed ))")

    guard let sceneSeparator = getSceneSeparator(scriptPath: scriptPath, encoding: encodingUsed) else {
        print("  > Scene separator not found")
        return empty
   }
    print("  > Scene separator   : \(sceneSeparator)")

    let characterMode = getCharacterSeparator(scriptPath: scriptPath, encoding: encodingUsed) //else {
//            print("  > Character mode    : \(characterMode)")
      //  return
    //}

    if sceneSeparator == "EMPTYLINES_SCENE_SEPARATOR" {
        currentSceneId = "Scene 1"
    }

    do {
        let fileContents = try String(contentsOf: scriptPath, encoding: encodingUsed )
        let lines = fileContents.split(separator: "\n", omittingEmptySubsequences: false)
        var lineIdx = 1
        var wasEmptyLine = false
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let isNewEmptyLine = trimmedLine.isEmpty
            
            if sceneSeparator == "EMPTYLINES_SCENE_SEPARATOR" && !isNewEmptyLine && wasEmptyLine && trimmedLine.isEmpty {
                currentSceneCount += 1
                currentSceneId = extractSceneName(from: String(line), sceneSeparator: sceneSeparator, currentSceneCount: currentSceneCount)
                // print("  > Scene Line: \(currentSceneId)")
            }
            
            if !trimmedLine.isEmpty {
                if isSceneLine(line: String(line)) || (isEmptyLine && wasEmptyLine) {
                    currentSceneCount += 1
                    currentSceneId = extractSceneName(from: String(line), sceneSeparator: sceneSeparator, currentSceneCount: currentSceneCount)
                    
                    
                    let breakdownItem:BreakdownItem1=BreakdownItem1( sceneId: currentSceneId,
                                                                     
                                                                     lineIdx: lineIdx,
                                                                     
                                                                     type: "SCENE_SEP"
                                                                     
                    )
                    
                    breakdown.append(breakdownItem)
                    //  print("  > Scene Line: \(currentSceneId)")
                } else {
                    let isSpeaking = isCharacterSpeaking(line: trimmedLine, characterMode: characterMode)
                    if isSpeaking {
                        var characterName = extractCharacterName(line: trimmedLine, characterMode: characterMode)
                        if  characterName != nil{
                            
                            characterName = filterCharacterName( characterName!)
                            if isCharacterNameValid( characterName) {
                                let spokenText = extractSpeech(line: trimmedLine,characterMode: characterMode, characterName: characterName!)
                                let filtered_spokenText=filterSpeech(spokenText)
                                // let breakdownItem:BreakdownItem=["scene_id": currentSceneId, "character_raw": characterName, "line_idx": lineIdx, "speech": spokenText, "type": "SPEECH", "character": characterName]
                                let breakdownItem:BreakdownItem1=BreakdownItem1( character: characterName!,
                                                                                 
                                                                                 character_raw: characterName!,
                                                                                 speech: filtered_spokenText,
                                                                                 speech_raw: spokenText,
                                                                                
                                                                                 sceneId: currentSceneId,
                                                                                 
                                                                                 lineIdx: lineIdx,
                                                                                 
                                                                                 type: "SPEECH"
                                                                                 
                                )
                                breakdown.append(breakdownItem)
                                
                                    let caracteres=computeLength(by: ComputeMethod.all, for: filtered_spokenText)
                                    let repliques=computeLength(by: ComputeMethod.blocks50, for: filtered_spokenText)
                                    dialogueOrderData.append(DialogueOrderTableRow( ligne:lineIdx, personnage:characterName!, dialog:filtered_spokenText, dialog_raw: spokenText, caracteres:caracteres , repliques:repliques))
                                    print("  > Add \(characterName!) \(spokenText)")
                                    
                                    if currentBreakdownPerCharacter.keys.contains(characterName!) {
                                        currentBreakdownPerCharacter[characterName!]?.append(breakdownItem)
                                    }else{
                                        currentBreakdownPerCharacter[characterName!]=[
                                            breakdownItem
                                        ]
                                    }
                                    
                                    
                            }
                        }
                    } else {
                        
                        let breakdownItem:BreakdownItem1=BreakdownItem1(
                            //  sceneId: currentSceneId,
                            sceneId: currentSceneId,   text:trimmedLine,
                            lineIdx: lineIdx,
                            
                            type: "NONSPEECH"
                            
                        )
                        
                        breakdown.append(breakdownItem)
                    }
                }
            }
            wasEmptyLine = trimmedLine.isEmpty
            lineIdx += 1
        }
        
        let allCharacters = getAllCharacters(from: breakdown)
        let mergeres = mergeBreakdownCharacterTalkingTo(breakdown: breakdown, allCharacters: allCharacters)
        breakdown=mergeres.0
        let replaceMap = mapSemiDuplicates(names: allCharacters)
        breakdown = mergeBreakdownCharacterByReplaceList(breakdown: breakdown, replaceList: replaceMap)
        
        
        var comptage:[Comptage]=[]
        var idx=1
        for k in allCharacters{
            
            dialogueCharacterNamesData.append(k)
            
            var totalchar=0.0
            var totalrep=0.0
            if currentBreakdownPerCharacter.keys.contains(k){
                for j in currentBreakdownPerCharacter[k]!{
                    if j.speech != nil{
                        let s:String=j.speech!
                        totalrep=totalrep+computeLength(by:ComputeMethod.blocks50, for: s)
                        totalchar=totalchar+computeLength(by:ComputeMethod.all, for: s)
                    }
                }
                characterData.append(CharacterTableRow( personnage:k,status:"VISIBLE", caracteres: totalchar,repliques: totalrep))
                
                comptage.append(Comptage(
                    idx:idx,   character: k, characters:totalchar, repliques: totalrep
                ))
                
                idx=idx+1
            }
            
        }
        
        
        currentBreakdown=breakdown
        
        
        //currentResultFolder=outputPath
        print("Current result folder \(outputPath)")
        exportDialogToCSV(items: breakdown,to:outputPath, filename:  "dialog.csv")
        exportComptageToCSV(items: comptage,to:outputPath, filename: "comptage.csv")
        
        
        
        /*
        //EXPORTS
        for item in breakdown {
            if item.type == "SPEECH" {
                let characterName = item.character as! String
                if characterOrderMap[characterName] == nil {
                    characterOrderMap[characterName] = characterCount
                    characterCount += 1
                }
                
                characterLineCountMap[characterName, default: 0] += 1
                let spokenText = item.speech as! String
                let length = computeLength(line: spokenText, method: countingMethod)
                characterTextLengthMap[characterName, default: 0] += length
                
                let sceneId = item.sceneId as! String
                sceneCharactersMap[characterName, default: Set()].insert(sceneId)
                characterSceneMap[sceneId, default: Set()].insert(characterName)
            }
        }
        
        //            writeCharacterMapToFile(characterMap: characterSceneMap, filePath: outputPath + "character_by_scenes.txt")
        //writeCharacterMapToFile(characterMap: sceneCharactersMap, filePath: outputPath + "scenes_by_character.txt")
        //writeCharacterMapToFile(characterMap: characterLineCountMap, filePath: outputPath + "character_linecount.txt")
        // writeCharacterMapToFile(characterMap: characterOrderMap, filePath: outputPath + "character_order.txt")
        // writeCharacterMapToFile(characterMap: characterTextLengthMap, filePath: outputPath + "character_textlength.txt")
        */
        
        let csvFilePath = outputPath.path + scriptName + "-recap-detailed.csv"
        var data: [[String]] = []
        for (key, order) in characterOrderMap {
            let lineCount = characterLineCountMap[key] ?? 0
            let textLength = characterTextLengthMap[key] ?? 0
            let speechCount = String(textLength / 40)
            data.append([String(order) + " - " + key, String(lineCount), String(textLength), speechCount])
        }
        
        writeCSV(filePath: csvFilePath, data: data)
        //  convertCsvToXlsx(csvFilePath: csvFilePath, xlsxFilePath: outputPath + scriptName + "-recap-detailed.xlsx", sheetName: scriptName, encoding: encodingUsed)
        
        print("  > Parsing done.")
    
        return (true,currentBreakdown,currentBreakdownPerCharacter,dialogueOrderData,characterData)
    } catch {
        print("Error reading file: \(error)")
    }
    return empty
}
func writeCSV(filePath: String,data:[[String]]) {
    
}
func convertCsvToXlsx(filePath: String) {
    
}
func convertWordToTxt(filePath: URL) ->URL? {
    return nil
}
func appendPathComponent(baseURL: URL, path: String) -> URL {
    let components = path.split(separator: "/")
    var updatedURL = baseURL
    for component in components {
        updatedURL.appendPathComponent(String(component))
    }
    return updatedURL
}
func convertPdfToTxt(filePath: URL) -> (URL,String.Encoding)? {
return nil
}

func getDocumentsDirectory() -> URL? {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}
func createFolderInDocuments(folderName: String) -> URL? {
    guard let documentsDirectory = getDocumentsDirectory() else { return nil }
    
    let folderURL = documentsDirectory.appendingPathComponent(folderName)
    
    do {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        return folderURL
    } catch {
        print("Failed to create folder: \(error)")
        return nil
    }
}
func exportComptageToCSV(items: [Comptage],to folderURL: URL, filename: String) {
    let fileURL = folderURL.appendingPathComponent(filename)
     
    // Create the CSV header
    var csvText = "Personnage,Répliques\n"

    // Append each item as a new line in the CSV
    for item in items {
        let line = "\(item.idx) - \(item.character ?? ""),\(Int(item.repliques))\n"
        csvText.append(line)
    }

    // Write the CSV text to a file
    do {
//            let fileURL = try FileManager.default
//              .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            .appendingPathComponent(filename)

        try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
        print("CSV file successfully written to \(fileURL.path)")
     
//        exportComptageToXLSX(items: items, to: folderURL, filename:filename.replacingOccurrences(of: ".csv", with: ".xlsx"))
        if let csvData = readCSV(from: fileURL) {
            print("read CSV data OK")
            let xlsxURL =    folderURL.appendingPathComponent(filename.replacingOccurrences(of: ".csv", with: ".xlsx"))
            writeXLSX(from: csvData, to: xlsxURL,fileName: filename.replacingOccurrences(of: ".csv", with: ".xlsx"))
        } else {
            print("Failed to read CSV data.")
        }

    } catch {
        print("Failed to write CSV file: \(error)")
    }
}
func exportDialogToCSV(items: [BreakdownItem1], to folderURL: URL,filename: String) {
    let fileURL = folderURL.appendingPathComponent(filename)
   
    // Filter items where type is "SPEECH"
    let filteredItems = items.filter { $0.type == "SPEECH" }

    // Create the CSV header
    var csvText = "Ligne,Personnage,Dialogue\n"

    // Append each filtered item as a new line in the CSV
    for item in filteredItems {
        let line = "\(item.lineIdx),\(item.character ?? ""),\(item.speech ?? "")\n"
        csvText.append(line)
    }

    // Write the CSV text to a file
    do {
      
        try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
        print("CSV file successfully written to \(fileURL.path)")
    
        if let csvData = readCSV(from: fileURL) {
            print("read CSV data OK")
            let xlsxURL =    folderURL.appendingPathComponent(filename.replacingOccurrences(of: ".csv", with: ".xlsx"))
            writeXLSX(from: csvData, to: xlsxURL,fileName: filename.replacingOccurrences(of: ".csv", with: ".xlsx"))
        } else {
            print("Failed to read CSV data.")
        }
    } catch {
        print("Failed to write CSV file: \(error)")
    }
}
// Function to read CSV file
func readCSV(from url: URL) -> [[String]]? {
    do {
        let content = try String(contentsOf: url, encoding: .utf8)
        let rows = content.components(separatedBy: "\n")
        let csvData = rows.map { $0.components(separatedBy: ",") }
        return csvData
    } catch {
        print("Error reading CSV file: \(error)")
        return nil
    }
}

// Function to move a file from a string path to a URL
func moveFile(from sourcePath: String, to destinationURL: URL) throws {
    let fileManager = FileManager.default
    
    // Create a URL from the source string path
    let sourceURL = URL(fileURLWithPath: sourcePath)
    
    // Check if the source file exists
    guard fileManager.fileExists(atPath: sourceURL.path) else {
        throw NSError(domain: "FileMover", code: 1, userInfo: [NSLocalizedDescriptionKey: "Source file does not exist"])
    }
    
    do {
        // Move the file to the destination URL
        try fileManager.moveItem(at: sourceURL, to: destinationURL)
        print("File moved successfully from \(sourcePath) to \(destinationURL.path)")
    } catch {
        // Handle the error if the file move fails
        throw NSError(domain: "FileMover", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to move file: \(error.localizedDescription)"])
    }
}
func exportComptageToXLSX(items: [Comptage],to folderURL: URL, filename: String) {
    let fileURL = folderURL.appendingPathComponent(filename)
    
    
    /*
    // Create a new workbook and add a worksheet.
    var wb = Workbook(name: "demo.xlsx")
    defer { wb.close() }
    let ws = wb.addWorksheet()
    
    // Append each item as a new line in the CSV
    var rowIdx=3
    for item in items {
        let line = "\(item.idx),\(item.character ?? ""),\(Int(item.characters)),\(Int(item.repliques))\n"
        // Write some simple text.
        ws.write(.string("\(item.idx)"), [rowIdx, 0])
        ws.write(.string(item.character ?? "?"), [rowIdx, 1])
        ws.write(.string("\(Int(item.characters))"), [rowIdx, 1])
        ws.write(.string("\(Int(item.repliques))"), [rowIdx, 1])

        rowIdx=rowIdx+1
    }*/
    
}
// Function to write XLSX file
func writeXLSX(from csvData: [[String]], to url: URL, fileName:String) {
//    let file = XLSXFile(filepath:url.path)
//    let workbook = file.workbook
    print("Write XLSX to \(url.path)")
    let book = XWorkBook()
    var sheet = book.NewSheet("Comptage")
    
    
    for (rowIndex, row) in csvData.enumerated() {
        for (colIndex, cellval) in row.enumerated() {
            let column = colIndex + 1
            let row = rowIndex + 1

            var cell = sheet.AddCell(XCoords(row: row, col: column))
             // cell.Cols(txt: .white, bg: .systemOrange)
            if colIndex==0{
                cell.value = .text(cellval)

            }else{
                cell.value = .integer(Int(cellval) ?? -1)

            }
            //  cell.Font = XFont(.TrebuchetMS, 16,true)
              //cell.alignmentHorizontal = .center
        }
    }
    let fileid = book.save(fileName)
    print("Write XLSX a saved id=\(fileid)")
    print("id=\(fileid)")
    print("move")

    do{  try  moveFile(from:fileid,to: url)
   }catch{
       
   }
    //print("replace")

  //  do{  try replaceXLSX(at:url)
  // }catch{
       
   //}
}
/*
func replaceXLSX(at url: URL){
    let style = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" name="Sheets"><a:themeElements><a:clrScheme name="Sheets"><a:dk1><a:srgbClr val="000000"/></a:dk1><a:lt1><a:srgbClr val="FFFFFF"/></a:lt1><a:dk2><a:srgbClr val="000000"/></a:dk2><a:lt2><a:srgbClr val="FFFFFF"/></a:lt2><a:accent1><a:srgbClr val="4285F4"/></a:accent1><a:accent2><a:srgbClr val="EA4335"/></a:accent2><a:accent3><a:srgbClr val="FBBC04"/></a:accent3><a:accent4><a:srgbClr val="34A853"/></a:accent4><a:accent5><a:srgbClr val="FF6D01"/></a:accent5><a:accent6><a:srgbClr val="46BDC6"/></a:accent6><a:hlink><a:srgbClr val="1155CC"/></a:hlink><a:folHlink><a:srgbClr val="1155CC"/></a:folHlink></a:clrScheme><a:fontScheme name="Sheets"><a:majorFont><a:latin typeface="Arial"/><a:ea typeface="Arial"/><a:cs typeface="Arial"/></a:majorFont><a:minorFont><a:latin typeface="Arial"/><a:ea typeface="Arial"/><a:cs typeface="Arial"/></a:minorFont></a:fontScheme><a:fmtScheme name="Office"><a:fillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:lumMod val="110000"/><a:satMod val="105000"/><a:tint val="67000"/></a:schemeClr></a:gs><a:gs pos="50000"><a:schemeClr val="phClr"><a:lumMod val="105000"/><a:satMod val="103000"/><a:tint val="73000"/></a:schemeClr></a:gs><a:gs pos="100000"><a:schemeClr val="phClr"><a:lumMod val="105000"/><a:satMod val="109000"/><a:tint val="81000"/></a:schemeClr></a:gs></a:gsLst><a:lin ang="5400000" scaled="0"/></a:gradFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:satMod val="103000"/><a:lumMod val="102000"/><a:tint val="94000"/></a:schemeClr></a:gs><a:gs pos="50000"><a:schemeClr val="phClr"><a:satMod val="110000"/><a:lumMod val="100000"/><a:shade val="100000"/></a:schemeClr></a:gs><a:gs pos="100000"><a:schemeClr val="phClr"><a:lumMod val="99000"/><a:satMod val="120000"/><a:shade val="78000"/></a:schemeClr></a:gs></a:gsLst><a:lin ang="5400000" scaled="0"/></a:gradFill></a:fillStyleLst><a:lnStyleLst><a:ln w="6350" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/><a:miter lim="800000"/></a:ln><a:ln w="12700" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/><a:miter lim="800000"/></a:ln><a:ln w="19050" cap="flat" cmpd="sng" algn="ctr"><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:prstDash val="solid"/><a:miter lim="800000"/></a:ln></a:lnStyleLst><a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst><a:outerShdw blurRad="57150" dist="19050" dir="5400000" algn="ctr" rotWithShape="0"><a:srgbClr val="000000"><a:alpha val="63000"/></a:srgbClr></a:outerShdw></a:effectLst></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst><a:solidFill><a:schemeClr val="phClr"/></a:solidFill><a:solidFill><a:schemeClr val="phClr"><a:tint val="95000"/><a:satMod val="170000"/></a:schemeClr></a:solidFill><a:gradFill rotWithShape="1"><a:gsLst><a:gs pos="0"><a:schemeClr val="phClr"><a:tint val="93000"/><a:satMod val="150000"/><a:shade val="98000"/><a:lumMod val="102000"/></a:schemeClr></a:gs><a:gs pos="50000"><a:schemeClr val="phClr"><a:tint val="98000"/><a:satMod val="130000"/><a:shade val="90000"/><a:lumMod val="103000"/></a:schemeClr></a:gs><a:gs pos="100000"><a:schemeClr val="phClr"><a:shade val="63000"/><a:satMod val="120000"/></a:schemeClr></a:gs></a:gsLst><a:lin ang="5400000" scaled="0"/></a:gradFill></a:bgFillStyleLst></a:fmtScheme></a:themeElements></a:theme>
"""
    
    let stylefixed = """
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<a:theme xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="Office Theme">    <a:themeElements>        <a:clrScheme name="Office">            <a:dk1>                <a:sysClr val="windowText" lastClr="000000"/>            </a:dk1>            <a:lt1>                <a:sysClr val="window" lastClr="FFFFFF"/>            </a:lt1>            <a:dk2>                <a:srgbClr val="1F497D"/>            </a:dk2>            <a:lt2>                <a:srgbClr val="EEECE1"/>            </a:lt2>            <a:accent1>                <a:srgbClr val="4F81BD"/>            </a:accent1>            <a:accent2>                <a:srgbClr val="C0504D"/>            </a:accent2>            <a:accent3>                <a:srgbClr val="9BBB59"/>            </a:accent3>            <a:accent4>                <a:srgbClr val="8064A2"/>            </a:accent4>            <a:accent5>                <a:srgbClr val="4BACC6"/>            </a:accent5>            <a:accent6>                <a:srgbClr val="F79646"/>            </a:accent6>            <a:hlink>                <a:srgbClr val="0000FF"/>            </a:hlink>            <a:folHlink>                <a:srgbClr val="800080"/>            </a:folHlink>        </a:clrScheme>        <a:fontScheme name="Office">            <a:majorFont>                <a:latin typeface="Cambria"/>                <a:ea typeface=""/>                <a:cs typeface=""/>                <a:font script="Jpan" typeface="ＭＳ Ｐゴシック"/>                <a:font script="Hang" typeface="맑은 고딕"/>                <a:font script="Hans" typeface="宋体"/>                <a:font script="Hant" typeface="新細明體"/>                <a:font script="Arab" typeface="Times New Roman"/>                <a:font script="Hebr" typeface="Times New Roman"/>                <a:font script="Thai" typeface="Tahoma"/>                <a:font script="Ethi" typeface="Nyala"/>                <a:font script="Beng" typeface="Vrinda"/>                <a:font script="Gujr" typeface="Shruti"/>                <a:font script="Khmr" typeface="MoolBoran"/>                <a:font script="Knda" typeface="Tunga"/>                <a:font script="Guru" typeface="Raavi"/>                <a:font script="Cans" typeface="Euphemia"/>                <a:font script="Cher" typeface="Plantagenet Cherokee"/>                <a:font script="Yiii" typeface="Microsoft Yi Baiti"/>                <a:font script="Tibt" typeface="Microsoft Himalaya"/>                <a:font script="Thaa" typeface="MV Boli"/>                <a:font script="Deva" typeface="Mangal"/>                <a:font script="Telu" typeface="Gautami"/>                <a:font script="Taml" typeface="Latha"/>                <a:font script="Syrc" typeface="Estrangelo Edessa"/>                <a:font script="Orya" typeface="Kalinga"/>                <a:font script="Mlym" typeface="Kartika"/>                <a:font script="Laoo" typeface="DokChampa"/>                <a:font script="Sinh" typeface="Iskoola Pota"/>                <a:font script="Mong" typeface="Mongolian Baiti"/>                <a:font script="Viet" typeface="Times New Roman"/>                <a:font script="Uigh" typeface="Microsoft Uighur"/>                <a:font script="Geor" typeface="Sylfaen"/>            </a:majorFont>            <a:minorFont>                <a:latin typeface="Calibri"/>                <a:ea typeface=""/>                <a:cs typeface=""/>                <a:font script="Jpan" typeface="ＭＳ Ｐゴシック"/>                <a:font script="Hang" typeface="맑은 고딕"/>                <a:font script="Hans" typeface="宋体"/>                <a:font script="Hant" typeface="新細明體"/>                <a:font script="Arab" typeface="Arial"/>                <a:font script="Hebr" typeface="Arial"/>                <a:font script="Thai" typeface="Tahoma"/>                <a:font script="Ethi" typeface="Nyala"/>                <a:font script="Beng" typeface="Vrinda"/>                <a:font script="Gujr" typeface="Shruti"/>                <a:font script="Khmr" typeface="DaunPenh"/>                <a:font script="Knda" typeface="Tunga"/>                <a:font script="Guru" typeface="Raavi"/>                <a:font script="Cans" typeface="Euphemia"/>                <a:font script="Cher" typeface="Plantagenet Cherokee"/>                <a:font script="Yiii" typeface="Microsoft Yi Baiti"/>                <a:font script="Tibt" typeface="Microsoft Himalaya"/>                <a:font script="Thaa" typeface="MV Boli"/>                <a:font script="Deva" typeface="Mangal"/>                <a:font script="Telu" typeface="Gautami"/>                <a:font script="Taml" typeface="Latha"/>                <a:font script="Syrc" typeface="Estrangelo Edessa"/>                <a:font script="Orya" typeface="Kalinga"/>                <a:font script="Mlym" typeface="Kartika"/>                <a:font script="Laoo" typeface="DokChampa"/>                <a:font script="Sinh" typeface="Iskoola Pota"/>                <a:font script="Mong" typeface="Mongolian Baiti"/>                <a:font script="Viet" typeface="Arial"/>                <a:font script="Uigh" typeface="Microsoft Uighur"/>                <a:font script="Geor" typeface="Sylfaen"/>            </a:minorFont>        </a:fontScheme>        <a:fmtScheme name="Office">            <a:fillStyleLst>                <a:solidFill>                    <a:schemeClr val="phClr"/>                </a:solidFill>                <a:gradFill rotWithShape="1">                    <a:gsLst>                        <a:gs pos="0">                            <a:schemeClr val="phClr">                                <a:tint val="50000"/>                                <a:satMod val="300000"/>                            </a:schemeClr>                        </a:gs>                        <a:gs pos="35000">                            <a:schemeClr val="phClr">                                <a:tint val="37000"/>                                <a:satMod val="300000"/>                            </a:schemeClr>                        </a:gs>                        <a:gs pos="100000">                            <a:schemeClr val="phClr">                                <a:tint val="15000"/>                                <a:satMod val="350000"/>                            </a:schemeClr>                        </a:gs>                    </a:gsLst>                    <a:lin ang="16200000" scaled="1"/>                </a:gradFill>                <a:gradFill rotWithShape="1">                    <a:gsLst>                        <a:gs pos="0">                            <a:schemeClr val="phClr">                                <a:tint val="100000"/>                                <a:shade val="100000"/>                                <a:satMod val="130000"/>                            </a:schemeClr>                        </a:gs>                        <a:gs pos="100000">                            <a:schemeClr val="phClr">                                <a:tint val="50000"/>                                <a:shade val="100000"/>                                <a:satMod val="350000"/>                            </a:schemeClr>                        </a:gs>                    </a:gsLst>                    <a:lin ang="16200000" scaled="0"/>                </a:gradFill>            </a:fillStyleLst>            <a:lnStyleLst>                <a:ln w="9525" cap="flat" cmpd="sng" algn="ctr">                    <a:solidFill>                        <a:schemeClr val="phClr">                            <a:shade val="95000"/>                            <a:satMod val="105000"/>                        </a:schemeClr>                    </a:solidFill>                    <a:prstDash val="solid"/>                </a:ln>                <a:ln w="25400" cap="flat" cmpd="sng" algn="ctr">                    <a:solidFill>                        <a:schemeClr val="phClr"/>                    </a:solidFill>                    <a:prstDash val="solid"/>                </a:ln>                <a:ln w="38100" cap="flat" cmpd="sng" algn="ctr">                    <a:solidFill>                        <a:schemeClr val="phClr"/>                    </a:solidFill>                    <a:prstDash val="solid"/>                </a:ln>            </a:lnStyleLst>            <a:effectStyleLst>                <a:effectStyle>                    <a:effectLst>                        <a:outerShdw blurRad="40000" dist="20000" dir="5400000" rotWithShape="0">                            <a:srgbClr val="000000">                                <a:alpha val="38000"/>                            </a:srgbClr>                        </a:outerShdw>                    </a:effectLst>                </a:effectStyle>                <a:effectStyle>                    <a:effectLst>                        <a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">                            <a:srgbClr val="000000">                                <a:alpha val="35000"/>                            </a:srgbClr>                        </a:outerShdw>                    </a:effectLst>                </a:effectStyle>                <a:effectStyle>                    <a:effectLst>                        <a:outerShdw blurRad="40000" dist="23000" dir="5400000" rotWithShape="0">                            <a:srgbClr val="000000">                                <a:alpha val="35000"/>                            </a:srgbClr>                        </a:outerShdw>                    </a:effectLst>                    <a:scene3d>                        <a:camera prst="orthographicFront">                            <a:rot lat="0" lon="0" rev="0"/>                        </a:camera>                        <a:lightRig rig="threePt" dir="t">                            <a:rot lat="0" lon="0" rev="1200000"/>                        </a:lightRig>                    </a:scene3d>                    <a:sp3d>                        <a:bevelT w="63500" h="25400"/>                    </a:sp3d>                </a:effectStyle>            </a:effectStyleLst>            <a:bgFillStyleLst>                <a:solidFill>                    <a:schemeClr val="phClr"/>                </a:solidFill>                <a:gradFill rotWithShape="1">                    <a:gsLst>                        <a:gs pos="0">                            <a:schemeClr val="phClr">                                <a:tint val="40000"/>                                <a:satMod val="350000"/>                            </a:schemeClr>                        </a:gs>                        <a:gs pos="40000">                            <a:schemeClr val="phClr">                                <a:tint val="45000"/>                                <a:shade val="99000"/>                                <a:satMod val="350000"/>                            </a:schemeClr>                        </a:gs>                        <a:gs pos="100000">                            <a:schemeClr val="phClr">                                <a:shade val="20000"/>                                <a:satMod val="255000"/>                            </a:schemeClr>                        </a:gs>                    </a:gsLst>                    <a:path path="circle">                        <a:fillToRect l="50000" t="-80000" r="50000" b="180000"/>                    </a:path>                </a:gradFill>                <a:gradFill rotWithShape="1">                    <a:gsLst>                        <a:gs pos="0">                            <a:schemeClr val="phClr">                                <a:tint val="80000"/>                                <a:satMod val="300000"/>                            </a:schemeClr>                        </a:gs>                        <a:gs pos="100000">                            <a:schemeClr val="phClr">                                <a:shade val="30000"/>                                <a:satMod val="200000"/>                            </a:schemeClr>                        </a:gs>                    </a:gsLst>                    <a:path path="circle">                        <a:fillToRect l="50000" t="50000" r="50000" b="50000"/>                    </a:path>                </a:gradFill>            </a:bgFillStyleLst>        </a:fmtScheme>    </a:themeElements>    <a:objectDefaults>        <a:spDef>            <a:spPr/>            <a:bodyPr/>            <a:lstStyle/>            <a:style>                <a:lnRef idx="1">                    <a:schemeClr val="accent1"/>                </a:lnRef>                <a:fillRef idx="3">                    <a:schemeClr val="accent1"/>                </a:fillRef>                <a:effectRef idx="2">                    <a:schemeClr val="accent1"/>                </a:effectRef>                <a:fontRef idx="minor">                    <a:schemeClr val="lt1"/>                </a:fontRef>            </a:style>        </a:spDef>        <a:lnDef>            <a:spPr/>            <a:bodyPr/>            <a:lstStyle/>            <a:style>                <a:lnRef idx="2">                    <a:schemeClr val="accent1"/>                </a:lnRef>                <a:fillRef idx="0">                    <a:schemeClr val="accent1"/>                </a:fillRef>                <a:effectRef idx="1">                    <a:schemeClr val="accent1"/>                </a:effectRef>                <a:fontRef idx="minor">                    <a:schemeClr val="tx1"/>                </a:fontRef>            </a:style>        </a:lnDef>    </a:objectDefaults>    <a:extraClrSchemeLst/></a:theme>
"""
    
    do {
        print("replaceXLSX")
        try    replaceContentInFile(at:url, replacing : style, with : stylefixed)
    }catch{
        print("replaceXLSX failed")

    }
    }



// Function to replace a portion of a file's content
func replaceContentInFile(at url: URL, replacing target: String, with replacement: String) throws {
    let fileManager = FileManager.default
    
    // Check if the file exists
    guard fileManager.fileExists(atPath: url.path) else {
        throw NSError(domain: "FileReplacer", code: 1, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])
    }
    print("replaceContentInFile fileexists")
    // Read the content of the file
    let content: String
    do {
        print("replaceContentInFile read")
        content = try String(contentsOf: url, encoding: .utf8)
    } catch {
        print("replaceContentInFile read fail \(error.localizedDescription)")
        throw NSError(domain: "FileReplacer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to read file: \(error.localizedDescription)"])
    }
    print("replaceContentInFile rep")

    // Replace the specified portion of the content
    let newContent = content.replacingOccurrences(of: target, with: replacement)
    print("replaceContentInFile replace")

    // Write the modified content back to the file
    do {
        print("replaceContentInFile write")

        try newContent.write(to: url, atomically: true, encoding: .utf8)
        print("File content replaced successfully")
    } catch {
        print("File content replacement failed")
        throw NSError(domain: "FileReplacer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to write file: \(error.localizedDescription)"])
    }
}
    
    
    

*/
