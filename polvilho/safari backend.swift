//
//  safari backend.swift
//  polvilho
//
//  Created by Douglas Kiarelly Godoy de Araujo on 23.10.2023.
//

// https://github.com/icodeforlove/BinaryCookies.swift/blob/master/Cookies/BinaryCookies.swift

import Foundation

extension NSData {
    func toString (encoding:UInt) -> String {
        return NSString(data: self as Data, encoding: encoding)! as String
    }
}

// The reader for the binary file with the cookies
// This class has several methods to read binary files
// Notably, these include big endian and little endian
// methods, because the Safari cookies binary has both
// types of byte order
class BinaryReader {
    var data:NSData
    
    var bufferPosition:Int = 0
    
    init(data: NSData) {
        self.data = data
    }
    
    func slice (loc:Int, len:Int) -> Data {
        return self.data.subdata(with: NSMakeRange(loc, len))
    }
    
    func readSlice (length:Int) -> NSData {
        let slice = slice(loc:bufferPosition, len:length)
        bufferPosition += length
        return slice as NSData
    }
    
    func readDoubleBE (offset:Int) -> Int64 {
        let data = slice(loc:offset, len:8)
        let value = data.withUnsafeBytes {(pointer: UnsafeRawBufferPointer) -> Int64 in
            let boundPointer = pointer.bindMemory(to: Double.self)
            guard let baseAddress = boundPointer.baseAddress else {
                return 0
            }
            return Int64(bitPattern: UInt64(bigEndian: baseAddress.pointee.bitPattern))
        }
        return value
    }
    
    func readDoubleLE (offset:Int) -> Int64 {
        let data = slice(loc:offset, len:8)
        let value = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Int64 in
            let boundPointer = pointer.bindMemory(to: Double.self)
            guard let baseAddress = boundPointer.baseAddress else {
                return 0
            }
            return Int64(bitPattern: baseAddress.pointee.bitPattern)
        }
        return value
    }
    
    func readIntBE (offset:Int) -> UInt32 {
        let data = slice(loc: offset, len: 4)
        let value = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> UInt32 in
            let boundPointer = pointer.bindMemory(to: UInt32.self)
            guard let baseAddress = boundPointer.baseAddress else {
                return 0
            }
            return UInt32(bigEndian: baseAddress.pointee)
        }
        return value
    }
    
    func readIntBE () -> UInt32 {
        let data = readIntBE(offset: bufferPosition)
        bufferPosition += 4
        return data
    }
    
    func readIntLE (offset:Int) -> UInt32 {
        let data = slice(loc: offset, len: 4)
        let value = data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> UInt32 in
            let boundPointer = pointer.bindMemory(to: UInt32.self)
            guard let baseAddress = boundPointer.baseAddress else {
                return 0
            }
            return UInt32(littleEndian: baseAddress.pointee)
        }
        return value
    }
    
    func readIntLE () -> UInt32 {
        let data = readIntLE(offset: bufferPosition)
        bufferPosition += 4
        return data
    }
}

enum BinaryCookiesError: Error {
    case BadFileHeader
    case DataLoadingFailed
    case InvalidEndOfCookieData
    case UnexpectedCookieHeaderValue
}

struct SafariCookie {
    var expiration:Int64
    var creation:Int64
    var domain:String
    var name:String
    var path:String
    var value:String
    var secure:Bool = false
    var http:Bool = false
}

class CookieParser {
    var numPages:UInt32 = 0
    var pageSizes:[UInt32] = []
    var pageNumCookies:[UInt32] = []
    var pageCookieOffsets:[[UInt32]] = []
    var pages:[BinaryReader] = []
    var cookieData:[[BinaryReader]] = []
    var cookies:[SafariCookie] = []
    
    var reader:BinaryReader?
    
    func getNumCookies (index:Int) throws {
        let page = pages[index]
        let header = page.readIntBE()
    }
    
    func getNumPages() {
        numPages = reader!.readIntBE()
    }
    
    func getPageSizes() {
        for _ in 0..<numPages {
            pageSizes.append(reader!.readIntBE())
        }
    }
    
    func getPages () {
        for (_, pageSize) in pageSizes.enumerated() {
            pages.append(
                BinaryReader(data: reader!.readSlice(length: Int(pageSize)))
            )
                                     
        }
    }
    
    func processCookieData (data:NSData) throws -> [SafariCookie] {
        reader = BinaryReader(data: data)
        let header = reader!.readSlice(length: 4).toString(encoding: NSUTF8StringEncoding)
        if (header == "cook") {
            getNumPages()
            getPageSizes()
            getPages()
            
            for (index, _) in pages.enumerated() {
                try getNumCookies(index: index)
                getCookieOffsets(index: index)
                getCookieData(index: index)
                
                for (cookieIndex, _) in cookieData[index].enumerated() {
                    try parseCookieData(cookie: cookieData[index][cookieIndex])
                }
            }
        } else {
            throw BinaryCookiesError.BadFileHeader
        }
        return cookies
    }
    
    func getCookieOffsets(index:Int) {
        let page = pages[index]
        var offsets:[UInt32] = []
        let numCookies = pageNumCookies[index]
        
        for _ in 0..<numCookies {
            offsets.append(page.readIntLE())
        }
        pageCookieOffsets.append(offsets)
    }
    
    func getCookieData(index:Int) {
        let page = pages[index]
        let cookieOffsets = pageCookieOffsets[index]
        var pageCookies:[BinaryReader] = []
        
        for (_, cookieOffset) in cookieOffsets.enumerated() {
            let cookieSize = page.readIntLE(offset: Int(cookieOffset))
            pageCookies.append(BinaryReader(data:page.slice(loc: Int(cookieOffset), len: Int(cookieSize)) as NSData))
        }
        cookieData.append(pageCookies)
    }
    
    func parseCookieData(cookie:BinaryReader) throws {
        let macEpochOffset:Int64 = 978307199
        var offsets:[UInt32] = []
        
        // some results of calls are unused, but that's fine
        // because they are there for moving the offset
        cookie.readIntLE(offset:0) // unknown
        cookie.readIntLE(offset:4) // unknown2
        let flags = cookie.readIntLE(offset:4+4) // flags
        cookie.readIntLE(offset:8+4) // unknown3
        offsets.append(cookie.readIntLE(offset:12+4)) // domain
        offsets.append(cookie.readIntLE(offset:16+4)) // name
        offsets.append(cookie.readIntLE(offset:20+4)) // path
        offsets.append(cookie.readIntLE(offset:24+4)) // value
        
        let endOfCookie = cookie.readIntLE(offset:28+4)
        if endOfCookie != 0 {
            throw BinaryCookiesError.InvalidEndOfCookieData
        }
        
        let expiration = (cookie.readDoubleLE(offset: 32+8) + macEpochOffset) * 1000
        let creation = (cookie.readDoubleLE(offset: 40+8) + macEpochOffset) * 1000
        var domain:String = ""
        var name:String = ""
        var path:String = ""
        var value:String = ""
        var secure:Bool = false
        var http:Bool = false
        
        let nsCookieString = cookie.data.toString(encoding: NSASCIIStringEncoding) as NSString
        
        for (index, offset) in offsets.enumerated() {
            let endOffset = nsCookieString.range(of: "\u{0000}", options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(Int(offset), nsCookieString.length - Int(offset))).location
            
            let string = nsCookieString.substring(with: NSMakeRange(Int(offset), Int(endOffset)-Int(offset)))
            
            if (index == 0) {
                domain = string
            } else if (index == 1) {
                name = string
            } else if (index == 2) {
                path = string
            } else if (index == 3) {
                value = string
            }
        }
        
        if (flags == 1) {
            secure = true
        } else if (flags == 4) {
            http = true
        } else if (flags == 5) {
            secure = true
            http = true
        }
        cookies.append(SafariCookie(expiration: expiration, creation: creation, domain: domain, name: name, path: path, value: value, secure: secure, http: http))
    }
}


public class BinaryCookies {
    class func parse(cookiePath: String, callback: @escaping (BinaryCookiesError?, [SafariCookie]?) -> ()) {
        let parser = CookieParser()
        DispatchQueue.global(qos: .default).async {
            guard let data = NSData(contentsOf: URL(fileURLWithPath: cookiePath)) else {
                callback(BinaryCookiesError.DataLoadingFailed, nil)
                return
            }

            do {
                callback(nil, try parser.processCookieData(data: data))
            } catch {
                callback(error as? BinaryCookiesError, nil)
            }
        }
    }
    
    class func parse(cookieURL: NSURL, callback: @escaping (BinaryCookiesError?, [SafariCookie]?) -> ()) {
        let parser = CookieParser()
        DispatchQueue.global(qos: .default).async {
            guard let data = NSData(contentsOf: cookieURL as URL) else {
                callback(BinaryCookiesError.DataLoadingFailed, nil)
                return
            }

            do {
                callback(nil, try parser.processCookieData(data: data))
            } catch {
                callback(error as? BinaryCookiesError, nil)
            }
        }
    }
    
    class func parse(data: NSData, callback: @escaping (BinaryCookiesError?, [SafariCookie]?) -> ()) {
        let parser = CookieParser()
        DispatchQueue.global(qos: .default).async {
            do {
                callback(nil, try parser.processCookieData(data: data))
            } catch {
                callback(error as? BinaryCookiesError, nil)
            }
        }
    }
}
