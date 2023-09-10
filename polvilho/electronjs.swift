//
//  electronjs.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 10.09.23.
//

import Foundation

func findFoldersContainingFile(filename: String, inDirectory directory: URL) -> [URL] {
    do {
        let fileManager = FileManager.default
        let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        
        // Filter for subdirectories
        let subdirectories = directoryContents.filter { (url) -> Bool in
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
            return isDirectory.boolValue
        }
        
        var matchingFolders: [URL] = []
        
        // Recursively search subdirectories for the target file
        for subdirectory in subdirectories {
            let subdirectoryMatchingFiles = findFoldersContainingFile(filename: filename, inDirectory: subdirectory)
            
            if subdirectoryMatchingFiles.count > 0 {
                matchingFolders.append(subdirectory)
                matchingFolders += subdirectoryMatchingFiles
            }
        }
        
        // Check if the current directory contains the target file
        if directoryContainsFile(filename: filename, inDirectory: directory) {
            matchingFolders.append(directory)
        }
        
        return matchingFolders
    } catch {
        print("Error: \(error)")
        return []
    }
}

func directoryContainsFile(filename: String, inDirectory directory: URL) -> Bool {
    let fileManager = FileManager.default
    let contents = try? fileManager.contentsOfDirectory(atPath: directory.path)
    return contents?.contains(filename) ?? false
}


