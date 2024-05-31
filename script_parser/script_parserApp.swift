//
//  script_parserApp.swift
//  script_parser
//
//  Created by Jean Dumont on 25/05/2024.
//

import SwiftUI

class GlobalSettingsViewModel: ObservableObject {
    @Published var blockSize: Int = 50
}
@main
struct script_parserApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
    var body: some Scene {
        Settings{
            
        }
    }
}
