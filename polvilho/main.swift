//
//  main.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 05.09.23.
//

import Foundation


// path to Mozilla cookies

// path to Safari cookies

// path to DuckDuckGo cookies

var deleteCookies: Bool = false
let arguments = CommandLine.arguments

if arguments.contains("--delete") || arguments.contains("-d") {
    deleteCookies = true
} else {
    deleteCookies = false
}

countChromeCookies(delete: deleteCookies)
