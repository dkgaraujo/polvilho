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
    
    func run() throws {
        print("To understand the good and bad aspects of cookies, a good general intro is:")
        print("https://youtu.be/rdVPflECed8?feature=shared")
        
        // Chrome
        manageChromeCookies(delete: deleteCookies)
        
        // ElectronJS apps
        let matchingFolders = findElectronJSCookies()

        for folder in matchingFolders {
            print("Found matching folder: \(folder.path)")
        }
        
        }
}

