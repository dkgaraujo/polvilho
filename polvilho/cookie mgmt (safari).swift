//
//  cookie mgmt (safari).swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 24.07.2024.
//

import Foundation

// Placeholder function to format cookie dates for consistency with SQLite format
func formatSafariCookieDate(_ timestamp: Int64) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: date)
}

func manageSafariCookies(cookiesDB: String, delete: Bool) {
    let cookieURL = URL(fileURLWithPath: cookiesDB)
    
    // Check if cookies exist
    guard FileManager.default.fileExists(atPath: cookieURL.path) else {
        print("No Safari cookies found at: \(cookiesDB)")
        return
    }
    
    // Parse cookies using the BinaryCookies class
    BinaryCookies.parse(cookiePath: cookiesDB) { error, cookies in
        if let error = error {
            print("Failed to parse Safari cookies: \(error)")
        } else if let cookies = cookies {
            print("Found \(cookies.count) Safari cookies.")
            
            // Output some details for each cookie
            if cookies.count > 0 {
                if let oldestCookie = cookies.min(by: { $0.creation < $1.creation }) {
                    let date = formatSafariCookieDate(oldestCookie.creation)
                    print("The oldest cookie is from \(date)")
                }
                
                if let newestCookie = cookies.max(by: { $0.creation < $1.creation }) {
                    let date = formatSafariCookieDate(newestCookie.creation)
                    print("The newest cookie is from \(date)")
                }
            }
            
            if delete {
                do {
                    try FileManager.default.removeItem(at: cookieURL)
                    print("Deleted Safari cookies at: \(cookiesDB)")
                } catch {
                    print("Failed to delete Safari cookies at: \(cookiesDB). Error: \(error.localizedDescription)")
                }
            }
        } else {
            print("Unknown error occurred while processing Safari cookies.")
        }
    }
}
