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
    @Flag(name: .shortAndLong, help: "Delete all cookies found.")
    var deleteCookies: Bool = false
    
    // @Flag(name: .shortAndLong, help: "Searches cookies of chromium-based apps.")
    var apps: Bool = false
    
    func run() throws {
        print("To understand the good and bad aspects of cookies, a good general intro is:")
        print("https://youtu.be/rdVPflECed8?feature=shared")
        
        // Chrome
        manageChromeCookies(delete: deleteCookies)
        
        // Safari
        // manageSafariCookies()
        
        if apps {
            // ElectronJS apps
            let matchingFolders = findElectronJSCookies()

            print("\(matchingFolders.count) electronJS apps found.")
            
            for folder in matchingFolders {
                print("Found matching folder: \(folder.path)")
            }
        }
    }
}

