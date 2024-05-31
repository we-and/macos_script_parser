//
//  Comptage.swift
//  script_parser
//
//  Created by Jean Dumont on 27/05/2024.
//
import Foundation
import SwiftUI

struct Comptage {
    var idx:Int
    var character: String?
    
    var characters: Double
    var repliques: Double
}

//typealias BreakdownItem = [String: Any]
struct BreakdownItem1 {
    var character: String?
    var character_raw: String?
    var speech: String?
    var speech_raw: String?
    
    var sceneId: String
    var text: String?
    var lineIdx: Int
    var type: String
}

//typealias BreakdownItem = [String: Any]

typealias ReplaceList = [String: String]

// Data model for the table
struct TableRow: Identifiable {
    var id = UUID()
    var personnage: String
    var status: String
    var character: String
    var repliques: String
}
struct RightTableRow: Identifiable {
    var id = UUID()
    var ligne: Int
    var characteres: Double
    var repliques: Double
}
