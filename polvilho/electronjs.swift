//
//  electronjs.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 10.09.23.
//

import Foundation
import SQLite3

func directoryContainsFile(filename: String, inDirectory directory: URL) -> Bool {
    let fileManager = FileManager.default
    let contents = try? fileManager.contentsOfDirectory(atPath: directory.path)
    return contents?.contains(filename) ?? false
}

func findFoldersContainingFile(filename: String, inDirectory directory: URL) -> [URL] {
    var matchingFolders: [URL] = []

    do {
        let fileManager = FileManager.default
        let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        
        // Filter for subdirectories
        let subdirectories = directoryContents.filter { (url) -> Bool in
            var isDirectory: ObjCBool = false
            return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
        }
        
        // Recursively search subdirectories for the target file
        for subdirectory in subdirectories {
            let subdirectoryMatchingFiles = findFoldersContainingFile(filename: filename, inDirectory: subdirectory)
            
            if !subdirectoryMatchingFiles.isEmpty {
                matchingFolders.append(contentsOf: subdirectoryMatchingFiles)
            }
        }
        
        // Check if the current directory contains the target file
        if directoryContainsFile(filename: filename, inDirectory: directory) {
            matchingFolders.append(directory)
        }
    } catch {
        print("Error accessing directory: \(directory.path). Error: \(error.localizedDescription)")
    }
    
    return matchingFolders
}

func findElectronJSCookies() -> [URL] {
    let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Application Support")
    let targetFileName = "Cookies"
    
    var matchingFolders = findFoldersContainingFile(filename: targetFileName, inDirectory: libraryURL)
    
    // Remove duplicates and sort the results
    let uniqueMatchingFolders = Array(Set(matchingFolders)).sorted(by: { $0.path.lowercased() < $1.path.lowercased() })
    
    return uniqueMatchingFolders
}

func manageElectronCookies() {
    let matchingFolders = findElectronJSCookies()
    
    for folder in matchingFolders {
        let appName = folder.deletingLastPathComponent().lastPathComponent
        let cookieFilePath = folder.appendingPathComponent("Cookies").path
        
        // Open the cookie file and analyze
        if let db = openDatabase(atPath: cookieFilePath) {
            let cookieCount = countCookies(in: db)
            let oldestCookieDate = oldestCookie(in: db)
            let newestCookieDate = newestCookie(in: db)
            sqlite3_close(db)
            
            print("App: \(appName)")
            print("Number of cookies: \(cookieCount)")
            print("Oldest cookie date: \(oldestCookieDate)")
            print("Newest cookie date: \(newestCookieDate)")
            print()
        } else {
            print("Failed to open database for \(appName)")
        }
    }
}

func openDatabase(atPath path: String) -> OpaquePointer? {
    var db: OpaquePointer? = nil
    if sqlite3_open(path, &db) == SQLITE_OK {
        return db
    } else {
        print("Failed to open database at path: \(path)")
        return nil
    }
}

func countCookies(in db: OpaquePointer?) -> Int {
    var statement: OpaquePointer? = nil
    let query = "SELECT COUNT(*) FROM cookies"
    var count: Int = 0
    
    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_ROW {
            count = Int(sqlite3_column_int(statement, 0))
        }
    }
    
    sqlite3_finalize(statement)
    return count
}

func oldestCookie(in db: OpaquePointer?) -> String {
    return cookieDate(in: db, query: "SELECT MIN(creation_utc) FROM cookies")
}

func newestCookie(in db: OpaquePointer?) -> String {
    return cookieDate(in: db, query: "SELECT MAX(creation_utc) FROM cookies")
}

func cookieDate(in db: OpaquePointer?, query: String) -> String {
    var statement: OpaquePointer? = nil
    var date: String = "N/A"
    
    if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_ROW {
            let timestamp = sqlite3_column_int64(statement, 0)
            date = formatElectronCookieDate(timestamp)
        }
    }
    
    sqlite3_finalize(statement)
    return date
}

func formatElectronCookieDate(_ timestamp: Int64) -> String {
    let cookieDate = Date(timeIntervalSince1970: TimeInterval(Double(timestamp) / 1_000_000 - 11644473600))
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: cookieDate)
}
