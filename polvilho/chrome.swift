//
//  chrome.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 05.09.23.
//

import Foundation

public func manageChromeCookies(delete: Bool) {
    // Get the path to the Chrome profiles directory
    let chromeProfilesPath = NSString("~/Library/Application Support/Google/Chrome")
        .expandingTildeInPath
    
    // List all profile folders
    let fileManager = FileManager.default
    do {
        let profiles = try fileManager.contentsOfDirectory(atPath: chromeProfilesPath)
            .filter { $0.hasPrefix("Profile") || $0 == "Default" }
        
        for profile in profiles {
            let cookiesDB = (chromeProfilesPath as NSString).appendingPathComponent("\(profile)/Cookies")
            ManageCookies(cookiesDB: cookiesDB, name: "Chrome (profile: \(profile))", delete: delete)
        }
    } catch {
        print("Error accessing Chrome profiles: \(error.localizedDescription)")
    }
}
