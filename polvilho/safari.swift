//
//  safari.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 01.10.2023.
//

import Foundation

// sources:
// https://community.spiceworks.com/topic/2454811-understanding-the-safari-cookies-binarycookies-file-format
// https://stackoverflow.com/questions/7545885/safari-5-1-cookie-format-specs
// https://github.com/icodeforlove/BinaryCookies.swift/blob/master/Cookies/BinaryCookies.swift

// path to Safari cookies
let safariCookiesDB = NSString("~/Library/Cookies/Cookies.binarycookies")
    .expandingTildeInPath

func numSafariCookies(binPath: String) -> UInt32? {
    guard let data = FileManager.default.contents(atPath: binPath) else {
        print("Failed to open Safari cookies.")
        return nil
    }
    
    guard data.count >= 8 else {
        print("Cookies.binarycookies file is too small.")
        return nil
    }
    
    guard String(data: data.subdata(in: 0..<4), encoding: .ascii) == "cook" else {
        print("Cookies.binarycookies seems to be corrupted.")
        return nil
    }
    
    let NumCookies: UInt32 = data.subdata(in: 4..<8).withUnsafeBytes({
        $0.load(as: UInt32.self)
    })
    
    return NumCookies
}

public func manageSafariCookies() {
    // TO-DO:
    // 1) actually be able to read the cookies, not just find the file
    
    print(numSafariCookies(binPath: safariCookiesDB) ?? "") // it doesn't seem like the number is right...
}
