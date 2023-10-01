//
//  chrome.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 05.09.23.
//

import Foundation


// https://stackoverflow.com/questions/43518199/cookies-expiration-time-format#43520042
let COOKIE_TIMESTAMP_ADJ:Double = 11644473600


public func manageChromeCookies(delete: Bool) {
    // TO-DO:
    // 1) search all existing profile folders
    
    
    // path to Chrome cookies
    let chromeCookiesDB = NSString("~/Library/Application Support/Google/Chrome/Default/Cookies")
        .expandingTildeInPath
    
    ManageCookies(cookiesDB: chromeCookiesDB, name: "Chrome", delete: delete)
}
