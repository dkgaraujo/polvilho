//
//  cookie_mgmt.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 01.10.2023.
//

import Foundation
import SQLite3

// https://stackoverflow.com/questions/43518199/cookies-expiration-time-format#43520042
let COOKIE_TIMESTAMP_ADJ:Double = 11644473600

let countCookiesQuery = "select count(*) from cookies"
let oldestCookieQuery = """
select creation_utc from cookies where creation_utc =
(SELECT min(creation_utc) FROM cookies)
"""
let newestCookieQuery = """
select creation_utc from cookies where creation_utc =
(SELECT max(creation_utc) FROM cookies)
"""
let deleteCookiesQuery = "delete from cookies;"

func FormatCookieDate(CookieTimeStamp: Int64) -> String {
    let CookieDate = Date(timeIntervalSince1970: TimeInterval(Double(CookieTimeStamp) / 1_000_000 - COOKIE_TIMESTAMP_ADJ)) // weird dates
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone(identifier: "UTC") // Use UTC for comparability

    return dateFormatter.string(from: CookieDate)
}

func ManageCookies(cookiesDB: String, name: String, delete: Bool) {
    var db: OpaquePointer? = nil
    if sqlite3_open(cookiesDB, &db) == SQLITE_OK {
        print("\(name) cookies found!")
        
        var statement: OpaquePointer? = nil
        
        // Count cookies
        if sqlite3_prepare_v2(db, countCookiesQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let cookieCount = sqlite3_column_int(statement, 0)
                print("Number of \(name) cookies found: \(cookieCount)")
            } else {
                print("Couldn't count \(name) cookies :(")
            }
        } else {
            print("Query preparation failed")
        }
        
        // Find oldest cookie (by creation date)
        if sqlite3_prepare_v2(db, oldestCookieQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let oldestCookieDateResult: Int64 = sqlite3_column_int64(statement, 0)
                let oldestCookieFormattedDate: String = FormatCookieDate(CookieTimeStamp: oldestCookieDateResult)
                print("The oldest cookie is from \(oldestCookieFormattedDate)")
            } else {
                print("Couldn't find the oldest \(name) cookie :(")
            }
        } else {
            print("Query preparation failed")
        }
        
        // Find newest cookie (by creation date)
        if sqlite3_prepare_v2(db, newestCookieQuery, -1, &statement, nil) == SQLITE_OK {
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let newestCookieDateResult: Int64 = sqlite3_column_int64(statement, 0)
                let newestCookieFormattedDate: String =  FormatCookieDate(CookieTimeStamp: newestCookieDateResult)
                
                print("The newest cookie is from \(newestCookieFormattedDate)")
            } else {
                print("Couldn't find the newest \(name) cookie :(")
            }
        } else {
            print("Query preparation failed")
        }
        
        
        // Delete cookies (if prompted by user)
        if delete {
            if sqlite3_prepare_v2(db, deleteCookiesQuery, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("\(name) cookies deleted!")
                    if
                        sqlite3_prepare_v2(db, countCookiesQuery, -1, &statement, nil) == SQLITE_OK {
                        
                        if sqlite3_step(statement) == SQLITE_ROW {
                            let cookieCount = sqlite3_column_int(statement, 0)
                            if cookieCount == 0 {
                                print("I can confirm all \(name) cookies are deleted.")
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
        sqlite3_finalize(statement)
    } else {
        print("Not possible to find \(name) cookies.\nPath searched: \(cookiesDB).")
    }
}
