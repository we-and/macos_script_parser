import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate,ObservableObject {
    var window: NSWindow!
    var appViewModel = AppViewModel()
    
  //  @Published  var blockSize: Int = 50
  
    @StateObject private var  globalSettingsViewModel = GlobalSettingsViewModel()
 
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the main SwiftUI view
        let contentView = ContentView(appViewModel: appViewModel).environmentObject(appViewModel)
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.delegate = self  // Set delegate to handle window close
        
        copyResourceFiles();
        // Set up the menu bar
        ///      setUpMenuBar()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setUpMenuBar()
        }
    }

    func setUpMenuBar() {
        let mainMenu = NSMenu()

        // App menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // File menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)
        let fileMenu = NSMenu(title: "Fichier")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "Ouvrir un dossier de travail...", action: #selector(openWorkFolder), keyEquivalent: "n")
        fileMenu.addItem(withTitle: "Ouvrir un fichier de script...", action: #selector(openScript), keyEquivalent: "n")

        // Settings menu
        let settingsMenuItem = NSMenuItem()
        mainMenu.addItem(settingsMenuItem)
        let settingsMenu = NSMenu(title: "Paramètres")
        settingsMenuItem.submenu = settingsMenu
        settingsMenu.addItem(withTitle: "Préferences", action: #selector(openPanelWindow), keyEquivalent: ",")

        NSApp.mainMenu = mainMenu
    }
    
    @objc func openWorkFolder() {
        appViewModel.shouldOpenFolder = true
       }

    
    // Method to open file picker
    @objc    func openScript() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a .txt file"
        openPanel.allowedFileTypes = ["txt","pdf","rtf","docx","xlsx","doc"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        openPanel.begin { (result) in
            if result == .OK, let url = openPanel.url {
                
                self.appViewModel.processFile(url)
                
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
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    
    func copyResourceFiles() {
        guard let destinationDirectory = createExamplesDestinationDirectory() else { return }
        
        let fileNames = ["3SECONDS.txt", "EBDEF10.txt","YOU CAN'T RUN FOREVER_SCRIPT_VO.txt"] // Add your resource file names here
        
        for fileName in fileNames {
            if let resourceURL = Bundle.main.url(forResource: fileName, withExtension: nil) {
                let destinationURL = destinationDirectory.appendingPathComponent(fileName)
                
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        // Remove the file if it already exists
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: resourceURL, to: destinationURL)
                    print("Successfully copied \(fileName) to \(destinationURL.path)")
                } catch {
                    print("Failed to copy \(fileName): \(error)")
                }
            } else {
                print("Resource file \(fileName) not found in bundle")
            }
        }
    }
    func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    func createExamplesDestinationDirectory() -> URL? {
        guard let documentsDirectory = getDocumentsDirectory() else { return nil }
        let destinationDirectory = documentsDirectory.appendingPathComponent("scripti/examples")
        
        do {
            try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create destination directory: \(error)")
            return nil
        }
        
        return destinationDirectory
    }

}

// Extension to handle window close event
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Terminate the app when the main window is closed
        NSApp.terminate(nil)
    }
}
