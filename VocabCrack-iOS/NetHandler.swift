//
//  NetHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//
import Foundation

class NetHandler {
    @discardableResult
    class func sendData(_ str:String) -> String? {
        let ret = sendData(str, retLines: 1)
        return ret != nil ? ret![0] : nil
    }
    
    @discardableResult
    class func sendData(_ str:String, retLines:Int) -> [String]?  {
        var input:InputStream?
        var output:OutputStream?
        
        print(Constants.SERVER_ADDRESS + " " + String(Constants.SERVER_PORT))
        Stream.getStreamsToHost(withName: Constants.SERVER_ADDRESS, port: Constants.SERVER_PORT, inputStream: &input, outputStream: &output)
        
        let inputStream = input!
        let outputStream = output!
        
        var data = [UInt8]((str + "\n").utf8)
        
        outputStream.open()
        outputStream.write(&data, maxLength: data.count)
        outputStream.close()
        
        var ret:[String] = [String]()
        
        inputStream.open()
        
        while ret.count < retLines {
            var buffer = [UInt8](repeating: 0, count: 1048576)
            var bytes = inputStream.read(&buffer, maxLength: 1024)
            let data = NSMutableData(bytes: &buffer, length: bytes)
            
            while inputStream.hasBytesAvailable {
                let read = inputStream.read(&buffer, maxLength: 1024)
                bytes += read
                data.append(&buffer, length: read)
            }
            
            if let str = NSString(bytes: data.bytes, length: bytes, encoding: String.Encoding.utf8.rawValue) {
                let split:[String] = Utilities.split(str as String, separator: "\n")
                
                for s in split {
                    ret.append(s)
                }
            }
        }
        
        inputStream.close()
        
        return ret.count > 0 ? ret : nil
    }
}

func compileMsg(_ msg:String...) -> String {
    var ret = ""
    if msg.count > 0 {
        for index in 0...msg.count-1 {
            ret += msg[index]
            if index < msg.count-1 {
                ret += Constants.SPLITTER_1
            }
        }
    }
    return ret
}
