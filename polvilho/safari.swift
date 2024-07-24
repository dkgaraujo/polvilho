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
let safariCookiesDB = NSURL(fileURLWithPath: NSString("~/Library/Cookies/Cookies.binarycookies")
    .expandingTildeInPath)

func numSafariCookies(binPath: String) -> UInt32? {
    guard let data = FileManager.default.contents(atPath: binPath) else {
        print("Failed to open Safari cookies.")
        return nil
    }
    
    guard data.count >= 8 else {
        print("Safari's Cookies.binarycookies file is too small.")
        return nil
    }
    
    guard String(data: data.subdata(in: 0..<4), encoding: .ascii) == "cook" else {
        print("Safari's Cookies.binarycookies file seems to be corrupted.")
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
//    var data = NSData(base64Encoded: "Y29vawAAAAsAAAAMAAABkgAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAQAAAAAAAAAAAAAAAQAEAAAAHAAAAHkAAADcAAAANwEAAAAAAABdAAAAAAAAAAQAAAAAAAAAOAAAAEwAAABVAAAAVwAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20AaHR0cE9ubHkALwB2YWx1ZQBjAAAAAAAAAAUAAAAAAAAAOAAAAEwAAABbAAAAXQAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20AaHR0cE9ubHlTZWN1cmUALwB2YWx1ZQBbAAAAAAAAAAAAAAAAAAAAOAAAAEwAAABTAAAAVQAAAAAAAAAAAAAAAAAAZ3SDu0EAAADnIoK7QXVybGVjaG8uYXBwc3BvdC5jb20Abm9ybWFsAC8AdmFsdWUAWwAAAAAAAAABAAAAAAAAADgAAABMAAAAUwAAAFUAAAAAAAAAAAAAAAAAAGd0g7tBAAAA5yKCu0F1cmxlY2hvLmFwcHNwb3QuY29tAHNlY3VyZQAvAHZhbHVlAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAFjMHFyAFAAAAS2JwbGlzdDAw0QECXxAYTlNIVFRQQ29va2llQWNjZXB0UG9saWN5EAIICyYAAAAAAAABAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAKA==", options: NSData.Base64DecodingOptions(rawValue: 0));
//    print("WEIRD SAFARI DATA: \(String(describing: data))")
    
    BinaryCookies.parse(cookieURL: safariCookiesDB, callback: {
        (error:BinaryCookiesError?, cookies) in

        if let cookies = cookies {
            print(cookies);
        } else {
            print(error ?? "Unknown error in Safari");
        }
    })
    print(numSafariCookies(binPath: safariCookiesDB.path!) ?? "") // it doesn't seem like the number is right...
}
