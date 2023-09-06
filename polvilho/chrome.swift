//
//  chrome.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 05.09.23.
//

import Foundation
import SQLite3



public func countChromeCookies(delete: Bool) {
    // path to Chrome cookies
    let chromeCookiesDB = NSString("~/Library/Application Support/Google/Chrome/Default/Cookies")
        .expandingTildeInPath
    
    var db: OpaquePointer? = nil
    if sqlite3_open(chromeCookiesDB, &db) == SQLITE_OK {
        print("Chrome cookies... found!")
        
        let countCookiesQuery = "select count(*) from cookies"
        let deleteCookiesQuery = "delete from cookies;"
        var statement: OpaquePointer? = nil
        
        // Count cookies
        
        if
            sqlite3_prepare_v2(db, countCookiesQuery, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let cookieCount = sqlite3_column_int(statement, 0)
                print("Number of cookies found: \(cookieCount)")
            } else {
                print("Couldn't count :(")
            }
        } else {
            print("Query preparation failed")
        }
        
        // Delete cookies (if prompted by user)

        if delete == true {
            if sqlite3_prepare_v2(db, deleteCookiesQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Chrome cookies deleted!")
                    if
                        sqlite3_prepare_v2(db, countCookiesQuery, -1, &statement, nil) == SQLITE_OK {
                        
                        if sqlite3_step(statement) == SQLITE_ROW {
                            let cookieCount = sqlite3_column_int(statement, 0)
                            if cookieCount == 0 {
                                print("I can confirm all Chrome cookies are deleted.")
                            } else {
                                print("Weird, there are still \(cookieCount) cookie(s).")
                            }
                            
                        } else {
                            print("Couldn't count :(")
                        }
                    } else {
                        print("Query preparation failed")
                    }
                } else {
                    print("Failed to delete the cookies.")
                }
            } else {
                print("Query preparation failed")
            }
        }
        
    } else {
        print("Failure...")
    }
}
