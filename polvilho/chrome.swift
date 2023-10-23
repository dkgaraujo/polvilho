//
//  chrome.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 05.09.23.
//

import Foundation

public func manageChromeCookies(delete: Bool) {
    // TO-DO:
    // 1) search all existing profile folders
    
    
    // path to Chrome cookies
    let chromeCookiesDB = NSString("~/Library/Application Support/Google/Chrome/Default/Cookies")
        .expandingTildeInPath
    
    ManageCookies(cookiesDB: chromeCookiesDB, name: "Chrome", delete: delete)
}
