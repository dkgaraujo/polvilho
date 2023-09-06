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
        countChromeCookies(delete: deleteCookies)
        }
}

