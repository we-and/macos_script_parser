//
//  ParserUtils.swift
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

import Foundation
import SwiftUI

func getOutputFolder(fileName:String) -> URL?{
    guard let documentsDirectory = getDocumentsDirectory() else { return nil; }
       return appendPathComponent(baseURL: documentsDirectory, path: "/scripti/" + fileName + "/")

}
func countConsecutiveEmptyLines(filePath: URL, n: Int, encoding: String.Encoding) -> Int {
    var countEmpty = 0
    var occurrences = 0
    var previousEmpty = false
    var lineIndex = 1

    do {
        let fileContents = try String(contentsOf: filePath, encoding: encoding)
        let lines = fileContents.split(separator: "\n", omittingEmptySubsequences: false)

        for line in lines {
            // Check if the current line is empty or contains only whitespace
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                countEmpty += 1
                previousEmpty = true
            } else {
                if previousEmpty && countEmpty >= n {
                    occurrences += 1
                }
                countEmpty = 0
                previousEmpty = false
            }
            lineIndex += 1
        }

        // Check at the end of the file if the last lines were empty
        if countEmpty >= n {
            occurrences += 1
        }
    } catch {
        print("Error reading file: \(error)")
    }

    return occurrences
}


func findCharacterSeparator(scriptPath: URL, encoding: String.Encoding) -> String {
    print("    findCharacterSeparator")
    var best = "?"
    var bestVal = 0.0
    var nLines = 0
    
    do {
        let fileContents = try String(contentsOf: scriptPath, encoding: encoding)
        let lines = fileContents.split(separator: "\n", omittingEmptySubsequences: false)
       
        //try one line speech separators
        for sep in characterSeparators {
            if sep.contains("SINGLELINE"){
                nLines = 0
                var nMatches = 0
                
                if  sep.contains( "SINGLELINE"){
                    
                    for line in lines {
                        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedLine.isEmpty {
                            nLines += 1
                            
                            var isMatch = false
                            if sep == "CHARACTER_SINGLELINE_SEMICOL_TAB" {
                                isMatch = matchesCharactername_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(text: String(trimmedLine))
                            } else if sep == "CHARACTER_SINGLELINE_SPACES" {
                                isMatch = matchesCharactername_NAME_ATLEAST8SPACES_TEXT(text: String(trimmedLine))
                            } else if sep == "CHARACTER_SINGLELINE_TAB" {
                                isMatch = matchesCharactername_NAME_ATLEAST1TAB_TEXT(text: String(trimmedLine))
                            }
                            
                            if isMatch {
                                nMatches += 1
                            }
                        }
                    }
                    
                    let pc = round(100 * Double(nMatches) / Double(nLines))
                    print("  > Test character sep: \(sep) \(nMatches)/\(nLines) \(pc)")
                    if pc > 0.1{
                        if pc > bestVal {
                            bestVal = pc
                            best = sep
                            print("Set best \(best)")
                            
                        }
                    }
                    
                }
            }
        }
                if best=="?"{
                    print("    Try multiline")
                    let result = countUppercaseAndNonUppercaseLines(in:fileContents )
                    let totalLines = nLines
                    let uppercasePercentage = totalLines > 0 ? (Double(result.uppercaseLines) / Double(totalLines))  : 0
                       let nonUppercasePercentage = totalLines > 0 ? (Double(result.nonUppercaseLines) / Double(totalLines))  : 0
                                       print("    Lines \(nLines) Uppercase \(result.uppercaseLines) \(uppercasePercentage) NonUppercase \(result.nonUppercaseLines) \(nonUppercasePercentage)")
                    if uppercasePercentage > 0.1 && nonUppercasePercentage>0.1{
                        best="CHARACTER_MULTILINE"
                        print("    Set best \(best)")
                    }
                }
          
        
    } catch {
        print("Error reading file: \(error)")
    }
    
    return best
}
func countUppercaseAndNonUppercaseLines(in text: String) -> (uppercaseLines: Int, nonUppercaseLines: Int) {
    let lines = text.components(separatedBy: "\n")
    
    var uppercaseCount = 0
    var nonUppercaseCount = 0
    
    for line in lines {
        if line == line.uppercased() {
            uppercaseCount += 1
        } else {
            nonUppercaseCount += 1
        }
    }
    
    return (uppercaseCount, nonUppercaseCount)
}
func matchesFormatParenthesisNameTimecode(line: String) -> Bool {
    let pattern = "\\([^)]+-\\s*\\d{2}:\\d{2}:\\d{2}:\\d{2}\\)$"
    return matchesPattern(line: line, pattern: pattern)
}

func matchesNumberParenthesisTimecode(line: String) -> Bool {
    let pattern = "^\\d+\\s+\\(\\d{2}:\\d{2}:\\d{2}:\\d{2}\\)$"
    return matchesPattern(line: line, pattern: pattern)
}
func matchesCharactername_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(text: String) -> Bool {
    let pattern = "^[\\w\\s]+:\\s*\\t.+$"
    return matchesPattern(line: text, pattern: pattern)
}

func matchesCharactername_NAME_UPPERCASE(text: String) -> Bool {
    return text==text.uppercased()
}

func matchesCharactername_NAME_ATLEAST8SPACES_TEXT(text: String) -> Bool {
    let pattern = "^(.+?)\\s{8,}(.+)$"
    return matchesPattern(line: text, pattern: pattern)
}

func matchesCharactername_NAME_ATLEAST1TAB_TEXT(text: String) -> Bool {
    let pattern = "^(.+)\\t+(.+)$"
    return matchesPattern(line: text, pattern: pattern)
}
func extractSpeech_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(line: String, characterName: String) -> String {
    var right = line.replacingOccurrences(of: characterName, with: "")
    if right.hasPrefix(":") {
        right.removeFirst()
        return right.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return right
}

func extractCharactername_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(line: String) -> String? {
    let pattern = "^([\\w\\s]+):\\s*\\t.+$"
    return extractFirstMatchGroup(line: line, pattern: pattern)
}

func extractCharactername_NAME_ATLEAST8SPACES_TEXT(line: String) -> String? {
    let pattern = "^([A-Z ]+)\\s{8,}.*$"
    return extractFirstMatchGroup(line: line, pattern: pattern)
}

func extractCharactername_NAME_ATLEAST1TAB_TEXT(line: String) -> String? {
    let parts = line.split(separator: "\t", maxSplits: 1, omittingEmptySubsequences: true)
    if parts.count > 1 {
        return parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return nil
}
func extractFirstMatchGroup(line: String, pattern: String) -> String? {
    // Create the regular expression
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return nil
    }
    
    // Define the range of the string to be searched
    let range = NSRange(location: 0, length: line.utf16.count)
    
    // Perform the match
    guard let match = regex.firstMatch(in: line, options: [], range: range) else {
        return nil
    }
 //   let results = regex.matches(in: line,range: NSRange(line.startIndex..., in: line))
//    let map = results.map {
//        String(line[Range($0.range, in: line)])
//    }
//    return map[0]
    
    // Extract the first capturing group
    let nsRange:NSRange = match.range(at: 1)
    let startIndex = nsRange.location
    let endIndex = nsRange.location + nsRange.length - 1
    
    
    // Convert start index
    let startStringIndex = line.index(line.startIndex, offsetBy: nsRange.location, limitedBy: line.endIndex) ?? line.endIndex

    // Convert end index
    let endStringIndex = line.index(line.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: line.endIndex) ?? line.endIndex

    if startStringIndex < endStringIndex {
        let stringRange = startStringIndex..<endStringIndex
        let substring = line[stringRange]  // "World"
        print("Extracted substring: '\(substring)'")
        return String(substring)
    } else {
        print("Invalid range for string extraction.")
    }
    
//    if let matchRange = Range(nsRange, in: line) {
  //      return String(line[matchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    //}
    
    return nil
}
/*
func extractFirstMatchGroup(line: String, pattern: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: line.utf16.count)
    if let match = regex?.firstMatch(in: line, options: [], range: range) {
        let nsRange = match.range(at: 1)
        if let matchRange = Range(nsRange, in: line) {
            return String(line[matchRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    return nil
}*
extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard nsRange.location != NSNotFound else { return nil }
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
        else { return nil }
        return from ..< to
    }
}*/
func matchesPattern(line: String, pattern: String) -> Bool {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: line.utf16.count)
    if let match = regex?.firstMatch(in: line, options: [], range: range) {
        return match.range.location != NSNotFound
    }
    return false
}

func isMatchingCharacterSpeaking(line: String, characterMode: String) -> Bool {
    switch characterMode {
    case "CHARACTER_SINGLELINE_TAB":
        return matchesCharactername_NAME_ATLEAST1TAB_TEXT(text: line)
    case "CHARACTER_SINGLELINE_SPACES":
        return matchesCharactername_NAME_ATLEAST8SPACES_TEXT(text: line)
    case "CHARACTER_SINGLELINE_SEMICOL_TAB":
        return matchesCharactername_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(text: line)
    default:
        print("ERROR 1 wrong mode=\(characterMode)")
        return false
    }
}

func getSceneSeparator(scriptPath: URL, encoding: String.Encoding) -> String? {
    var mode = "?"
    
    do {
        let fileContents = try String(contentsOf: scriptPath, encoding: encoding)
        let lines = fileContents.split(separator: "\n", omittingEmptySubsequences: false)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if matchesFormatParenthesisNameTimecode(line: String(trimmedLine)) {
                print("PARENTHESIS_NAME_TIMECODE")
                return "PARENTHESIS_NAME_TIMECODE"
            } else if matchesNumberParenthesisTimecode(line: String(trimmedLine)) {
                print("NAME_PARENTHESIS_TIMECODE")
                return "NAME_PARENTHESIS_TIMECODE"
            }
        }
        
        let nSetsOfEmptyLines = countConsecutiveEmptyLines(filePath: scriptPath, n: 2, encoding: encoding)
        if nSetsOfEmptyLines > 1 {
            print("Found EMPTYLINES_SCENE_SEPARATOR")
            return "EMPTYLINES_SCENE_SEPARATOR"
        }
    } catch {
        print("Error reading file: \(error)")
    }
    
    return "NONE"
}
func removeFirstCharacterIfPeriod(from string: String) -> String {
    // Check if the first character is a period
    if string.first == "." {
        // Remove the first character and return the result
        return String(string.dropFirst())
    }
    // Return the original string if the first character is not a period
    return string
}
func isSupportedExtension(ext: String) -> Bool {
    var lowercasedExt = ext.lowercased()
    lowercasedExt=removeFirstCharacterIfPeriod(from: lowercasedExt)
    return lowercasedExt == "txt" || lowercasedExt == "docx" || lowercasedExt == "doc" || lowercasedExt == "rtf" || lowercasedExt == "pdf" || lowercasedExt == "xlsx"
}
func detectFileEncoding(filePath: URL) -> String.Encoding {
    let encodings: [String.Encoding] = [.utf8, .ascii, .isoLatin1, .windowsCP1252, .utf16, .utf16LittleEndian, .utf16BigEndian]
    
    for encoding in encodings {
        do {
            _ = try String(contentsOf: filePath, encoding: encoding)
            return encoding
        } catch {
            // Continue trying other encodings
        }
    }
    return .utf8
//        return nil
}

func encodingName(for encoding: String.Encoding?) -> String {
    guard let encoding=encoding else{
        return "?"
    }
    switch encoding {
    case .utf8: return "utf-8"
    case .ascii: return "ascii"
    case .isoLatin1: return "iso-8859-1"
    case .windowsCP1252: return "windows-1252"
    case .utf16: return "utf-16"
    case .utf16LittleEndian: return "utf-16le"
    case .utf16BigEndian: return "utf-16be"
    default: return "unknown"
    }
}



func testEncoding(scriptPath: String) -> String {
    let encodings = ["windows-1252", "iso-8859-1", "utf-16", "ascii", "utf-8"]
    for enc in encodings {
        do {
            let fileContents = try String(contentsOfFile: scriptPath, encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(enc as CFString))))
            print("  > Testing encoding  : \(enc)")
            for line in fileContents.split(separator: "\n") {
                _ = line.trimmingCharacters(in: .whitespacesAndNewlines)  // Remove any leading/trailing whitespace
            }
            return enc
        } catch {
            print("  > Failed decoding with \(enc)")
        }
    }
    return "?"
}
func extractSpeech(line: String, characterMode: String, characterName: String) -> String {
    switch characterMode {
    case "CHARACTER_SINGLELINE_TAB", "CHARACTER_SINGLELINE_SPACES":
        return line.replacingOccurrences(of: characterName, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    case "CHARACTER_SINGLELINE_SEMICOL_TAB":
        return extractSpeech_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(line: line, characterName: characterName)
    default:
        print("ERROR 2  wrong mode=\(characterMode)")
        exit(1)
        return ""
    }
}
func extractCharacterName(line: String, characterMode: String) -> String? {
    switch characterMode {
    case "CHARACTER_SINGLELINE_TAB":
        return extractCharactername_NAME_ATLEAST1TAB_TEXT(line: line)
    case "CHARACTER_SINGLELINE_SPACES":
        return extractCharactername_NAME_ATLEAST8SPACES_TEXT(line: line)
    case "CHARACTER_SINGLELINE_SEMICOL_TAB":
        return extractCharactername_NAME_SEMICOLON_OPTSPACES_TAB_TEXT(line: line)
    case "CHARACTER_MULTILINE":
        if line==line.uppercased(){
            return line
        }           else{ return nil}
    default:
        print("ERROR 3 wrong mode=\(characterMode)")
        exit(1)
    }
}
func isCharacterSpeaking(line: String, characterMode: String) -> Bool {
    let isMatch = isMatchingCharacterSpeaking(line: line, characterMode: characterMode)
    if isMatch {
        if let name = extractCharacterName(line: line, characterMode: characterMode) {
            return !isDidascalie(name) && !isAmbiance(name)
        }
    }
    return false
}

func isDidascalie(_ name: String) -> Bool {
    return name == "DIDASCALIES"
}

func isAmbiance(_ name: String) -> Bool {
    return name == "AMBIANCE"
}

func filterCharacterName(_ line: String) -> String {
    var filteredLine = line

    if filteredLine.contains("(O.S)") {
        filteredLine = filteredLine.replacingOccurrences(of: "(O.S)", with: "")
    }
    if filteredLine.contains("(OS)") {
        filteredLine = filteredLine.replacingOccurrences(of: "(OS)", with: "")
    }
    if filteredLine.contains("(OS") {
        filteredLine = filteredLine.replacingOccurrences(of: "(OS", with: "")
    }
    if filteredLine.contains("(O.S.)") {
        filteredLine = filteredLine.replacingOccurrences(of: "(O.S.)", with: "")
    }
    if filteredLine.contains("(CONT'D)") {
        filteredLine = filteredLine.replacingOccurrences(of: "(CONT'D)", with: "")
    }
    if filteredLine.hasSuffix(":") {
        filteredLine.removeLast()
    }
    if filteredLine.hasSuffix(")") {
        filteredLine.removeLast()
    }
    return filteredLine
}
/*func filterText(_ s: String) -> String {
    var res = s.replacingOccurrences(of: "♪", with: "")
    res = res.replacingOccurrences(of: "Â§", with: "")
    res = res.replacingOccurrences(of: "§", with: "")
    // filter songs
    return res
}
*/
// Function to get text without parentheses
func getTextWithoutParentheses(_ inputString: String) -> String {
    let pattern = "\\([^()]*\\)"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: inputString.utf16.count)
    let resultString = regex.stringByReplacingMatches(in: inputString, options: [], range: range, withTemplate: "")
    return resultString
}

// Function to remove text in brackets
func removeTextInBrackets(_ text: String) -> String {
    let pattern = "\\[.*?\\]"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: text.utf16.count)
    let cleanedText = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
    return cleanedText
}

// Function to filter speech
func filterSpeech(_ input: String) -> String {
    var s = getTextWithoutParentheses(input)
    s=s.trimmingCharacters(in: [" "])
    s = removeTextInBrackets(s)
    s = s.replacingOccurrences(of: "â€™", with: "'")
    s = s.replacingOccurrences(of: "â€¦ ", with: ".")
    return s
}

// Function to filter speech but keep brackets
func filterSpeechKeepBrackets(_ input: String) -> String {
    var s = getTextWithoutParentheses(input)
    s = s.replacingOccurrences(of: "â€™", with: "'")
    s = s.replacingOccurrences(of: "â€¦ ", with: ".")
    return s
}

func hasSplitable(character: String) -> String {
    for i in splitables {
        if character.contains(i) {
            return i
        }
    }
    return ""
}
func mergeBreakdownCharacterTalkingTo(breakdown: [BreakdownItem1], allCharacters: [String]) -> ([BreakdownItem1], ReplaceList) {
    print("mergeBreakdownCharacterTalkingTo")
    var replaceList: ReplaceList = [:]
    let checkIfAlreadyNamed = false
    var updatedBreakdown = breakdown

    for i in 0..<updatedBreakdown.count {
        if var item = updatedBreakdown[i] as? BreakdownItem1, let itemType = item.type as? String, itemType == "SPEECH" {
            if var character = item.character  {
                if character != character.trimmingCharacters(in: .whitespacesAndNewlines) {
                    character = character.trimmingCharacters(in: .whitespacesAndNewlines)
                }

                let splitable = hasSplitable(character:character)
                if !splitable.isEmpty {
                    let characters = character.components(separatedBy:  (splitable))
                    if checkIfAlreadyNamed {
                        var arePartsCharacterNames = true
                        for k in characters {
                            if !allCharacters.contains(String(k)) {
                                arePartsCharacterNames = false
                                break
                            }
                        }
                        if arePartsCharacterNames {
                            let firstChar = characters[0]
                            replaceList[character] = firstChar
                            item.character = firstChar
                            updatedBreakdown[i] = item
                        }
                    } else {
                        let firstChar = characters[0]
                        replaceList[character] = firstChar
                        item.character = firstChar
                        updatedBreakdown[i] = item
                    }
                }
            }
        }
    }

    return (updatedBreakdown, replaceList)
}
func extractSceneName(from line: String, sceneSeparator: String, currentSceneCount: Int) -> String {
    if sceneSeparator == "NAME_PARENTHESIS_TIMECODE" {
        if matchesNumberParenthesisTimecode(line: line) {
            return extractSceneName2(from: line) ?? "?"
        }
    } else if sceneSeparator == "PARENTHESIS_NAME_TIMECODE" {
        if matchesFormatParenthesisNameTimecode(line: line) {
            return extractSceneName1(from: line) ?? "?"
        }
    } else if sceneSeparator == "EMPTYLINES_SCENE_SEPARATOR" {
        return "Scene \(currentSceneCount)"
    }
    return "?"
}
func extractSceneName1(from line: String) -> String? {
    let pattern = "\\(([^-]*)"
    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
       let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)){
    
        let nsRange:NSRange = match.range(at: 1)
        let startIndex = nsRange.location
        let endIndex = nsRange.location + nsRange.length - 1
        
        
        // Convert start index
        let startStringIndex = line.index(line.startIndex, offsetBy: nsRange.location, limitedBy: line.endIndex) ?? line.endIndex

        // Convert end index
        let endStringIndex = line.index(line.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: line.endIndex) ?? line.endIndex

        if startStringIndex < endStringIndex {
            let stringRange = startStringIndex..<endStringIndex
            let substring = line[stringRange]  // "World"
            print("Extracted substring: '\(substring)'")
            return String(substring)
        } else {
            print("Invalid range for string extraction.")
        }
        
    
    //,
   //    let range = Range(match.range(at: 1), in: line) {
     //   return String(line[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return nil
}

func extractSceneName2(from line: String) -> String? {
    // Split the line at the first occurrence of ' ('
    let parts = line.components(separatedBy: " (")
    if !parts.isEmpty {
        return parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return nil
}
func mergeBreakdownCharacterByReplaceList(breakdown: [BreakdownItem1], replaceList: ReplaceList) -> [BreakdownItem1] {
    print("mergeBreakdownCharacterByReplaceList")

    var updatedBreakdown = breakdown

    for i in 0..<updatedBreakdown.count {
        if var item = updatedBreakdown[i] as? BreakdownItem1, let itemType = item.type as? String, itemType == "SPEECH" {
            if let character = item.character as? String, let firstChar = replaceList[character] {
                item.character = firstChar
                updatedBreakdown[i] = item
            }
        }
    }

    return updatedBreakdown
}
func getAllCharacters(from breakdown: [BreakdownItem1]) -> [String] {
    var allCharacters: [String] = []
    
    for item in breakdown {
        if let itemType = item.type as? String, itemType == "SPEECH" {
            if let character = item.character as? String {
                if !allCharacters.contains(character) {
                    allCharacters.append(character)
                }
            } else {
                print("ERR")
                exit(1)
            }
        }
    }
    
    return allCharacters
}
func mapSemiDuplicates(names: [String]) -> [String: String] {
    var normalizedMap: [String: String] = [:]  // Maps normalized names to their first occurrence
    var duplicates: [String: String] = [:]  // Stores mappings of semi-duplicate entries

    for name in names {
        let normalized = name.replacingOccurrences(of: " ", with: "")  // Remove spaces to normalize
        if let firstOccurrence = normalizedMap[normalized] {
            // Map current name to the first occurrence of this normalized form
            duplicates[name] = firstOccurrence
        } else {
            // Store the first occurrence of this normalized form
            normalizedMap[normalized] = name
        }
    }

    return duplicates
}

func computeLength(by method: ComputeMethod, for line: String) -> Double {
    switch method {
    case .all:
        return Double(line.count)
    case .lineCount:
        return 1
    case .allNoSpace:
        return Double(line.replacingOccurrences(of: " ", with: "").count)
    case .allNoPunc:
        return Double(line.replacingOccurrences(of: ",", with: "")
                          .replacingOccurrences(of: "?", with: "")
                          .replacingOccurrences(of: ".", with: "")
                          .replacingOccurrences(of: "!", with: "").count)
    case .allNoSpaceNoPunc:
        return Double(line.replacingOccurrences(of: " ", with: "")
                          .replacingOccurrences(of: ",", with: "")
                          .replacingOccurrences(of: "?", with: "")
                          .replacingOccurrences(of: ".", with: "")
                          .replacingOccurrences(of: "!", with: "").count)
    case .allNoApos:
        return Double(line.replacingOccurrences(of: "'", with: "").count)
    case .wordCount:
        return Double(line.split(separator: " ").count)
    case .blocks50:
        return Double(line.count) / 50.0
    case .blocks40:
        return Double(line.count) / 40.0
    case .unknown:
        return -1
    }
}
func writeCharacterMapToFile(characterMap: [String: Set<String>], filePath: String) {
    print(" > Write map to \(filePath)")
    var content = ""
    
    for (character, scenes) in characterMap {
        let scenesList = scenes.joined(separator: ", ")
        content += "\(character): \(scenesList)\n"
    }
    
    do {
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    } catch {
        print("Failed to write to file: \(error)")
    }
}
func isSceneLine(line: String) -> Bool {
    let isSceneLine = matchesFormatParenthesisNameTimecode(line: line) || matchesNumberParenthesisTimecode(line: line)
    //print("IsScene    \(isSceneLine) \(line)")
    return isSceneLine
}

func isCharacterNameValid(_ char: String?) -> Bool {
    guard let char = char else{
        return false
    }
    let isNote = char.contains("NOTE D'AUTEUR")
    let isEnd = char.contains("END CREDITS")
    let isNar = char.contains("NARRATIVE TITLE")
    let isOST = char.contains("ON-SCREEN TEXT")
    let isMain = char.contains("MAIN TITLE")
    let isOpen = char.contains("OPENING CREDITS")
    
    return !isNote && !isEnd && !isNar && !isOST && !isMain && !isOpen
}

func getFileNameAndExtension(from url: URL) -> (fileName: String, fileExtension: String) {
    let fileNameWithoutExtension = url.deletingPathExtension().lastPathComponent
    let fileExtension = url.pathExtension
    return (fileNameWithoutExtension, fileExtension)
}
func readTextFile(at url: URL) -> (String,String.Encoding)? {
    // Read the file data
    guard let fileData = try? Data(contentsOf: url) else {
        print("Failed to read file data.")
        return nil
    }
    
    // List of possible encodings to try
    let encodings: [String.Encoding] = [
        .utf8,
        .ascii,
        .isoLatin1, // ISO-8859-1
        .windowsCP1251, // Cyrillic
        .windowsCP1252 // Western
    ]
    
    for encoding in encodings {
        if let content = String(data: fileData, encoding: encoding) {
            return (content,encoding)
        }
    }
    
    print("Failed to decode file content with known encodings.")
    return nil
}

