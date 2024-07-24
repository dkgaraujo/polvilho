//
//  main.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 05.09.23.
//

import ArgumentParser
import Foundation

@main
struct Polvilho: ParsableCommand {
    @Flag(name: .shortAndLong, help: "Searches cookies in Chrome.")
    var chrome: Bool = false
    
    @Flag(name: .shortAndLong, help: "Searches cookies in Safari.")
    var safari: Bool = false
    
    @Flag(name: .shortAndLong, help: "Searches cookies in chromium-based apps.")
    var apps: Bool = false
    
    @Flag(name: .shortAndLong, help: "Delete all cookies found.")
    var deleteCookies: Bool = false
        
    func run() throws {
        print("To understand the good and bad aspects of cookies, a good general intro is:")
        print("https://youtu.be/rdVPflECed8?feature=shared")
        
        print("\n")
        print("Searching for cookies in the following browsers:")
        print("Chrome: \(chrome)")
        print("Safari: \(safari)")
        print("Electron (Chromium-based apps): \(apps)")
        print("- - -")
        print("Will the cookies be deleted? \(deleteCookies)")
        print("= = =")
        
        // Chrome
        if chrome {
            print("\n")
            print("= = =")
            print("CHROME")
            print("- - -")
            manageChromeCookies(delete: deleteCookies)
            print("= = =")
        }
        
        // Safari
        if safari {
            print("\n")
            print("= = =")
            print("SAFARI")
            print("- - -")
            //manageSafariCookies(delete: deleteCookies)
            print("= = =")
        }
        
        if apps {
            // ElectronJS apps
            print("\n")
            print("= = =")
            print("ELECTRON")
            print("- - -")
            let matchingFolders = findElectronJSCookies()

            print("\(matchingFolders.count) electronJS apps found.")
            
            for folder in matchingFolders {
                print("Found matching folder: \(folder.path)")
            }
            print("= = =")
        }
    }
}

