//
//  Constants.swift
//  script_parser
//
//  Created by Jean Dumont on 27/05/2024.
//

import Foundation
enum ComputeMethod: String {
    case all = "ALL"
    case lineCount = "LINE_COUNT"
    case allNoSpace = "ALL_NOSPACE"
    case allNoPunc = "ALL_NOPUNC"
    case allNoSpaceNoPunc = "ALL_NOSPACE_NOPUNC"
    case allNoApos = "ALL_NOAPOS"
    case wordCount = "WORD_COUNT"
    case blocks50 = "BLOCKS_50"
    case blocks40 = "BLOCKS_40"
    case unknown = "UNKNOWN"
}


let actionVerbs = ["says", "asks", "whispers", "shouts", "murmurs", "exclaims"]
let splitables=[" TALK TO "," TO "];

let characterSeparators = [
    "CHARACTER_SINGLELINE_SEMICOL_TAB",
    "CHARACTER_SINGLELINE_TAB",
    "CHARACTER_SINGLELINE_SPACES",
    "CHARACTER_MULTILINE"
]

let countMethods = [
    "ALL",
    "ALL_NOSPACE",
    "ALL_NOPUNC",
    "ALL_NOSPACE_NOPUNC",
    "ALL_NOAPOS"
]
