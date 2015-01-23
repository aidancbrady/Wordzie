//
//  NetHandler.swift
//  VocabCrack
//
//  Created by aidancbrady on 12/2/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//
import Foundation

class NetHandler
{
    class func sendData(str:String) -> String?
    {
        Operations.setNetworkActivity(true)
        
        var inputStream:NSInputStream?
        var outputStream:NSOutputStream?
        
        NSStream.getStreamsToHostWithName(Constants.IP, port: Constants.PORT, inputStream: &inputStream, outputStream: &outputStream)
        
        var writeData = [UInt8]((str + "\n").utf8)
        
        outputStream!.open()
        outputStream!.write(&writeData, maxLength: writeData.count)
        outputStream!.close()
        
        inputStream!.open()
        
        var buffer = [UInt8](count:1048576, repeatedValue:0)
        var bytes = inputStream!.read(&buffer, maxLength: 1024)
        var data = NSMutableData(bytes: &buffer, length: bytes)
        
        while inputStream!.hasBytesAvailable
        {
            let read = inputStream!.read(&buffer, maxLength: 1024)
            bytes += read
            data.appendBytes(&buffer, length: read)
        }
        
        inputStream?.close()
        
        Operations.setNetworkActivity(false)
        
        if let str = NSString(bytes: data.bytes, length: bytes, encoding: NSUTF8StringEncoding)
        {
            return str
        }
        
        return nil
    }
    
    class func sendData(str:String, retLines:Int) -> [String]?
    {
        var input:NSInputStream?
        var output:NSOutputStream?
        
        NSStream.getStreamsToHostWithName(Constants.IP, port: Constants.PORT, inputStream: &input, outputStream: &output)
        
        var inputStream = input!
        var outputStream = output!
        
        var data = [UInt8]((str + "\n").utf8)
        
        outputStream.open()
        outputStream.write(&data, maxLength: data.count)
        outputStream.close()
        
        var ret:[String] = [String]()
        
        inputStream.open()
        
        while ret.count < retLines
        {
            var buffer = [UInt8](count:1048576, repeatedValue:0)
            var bytes = inputStream.read(&buffer, maxLength: 1024)
            var data = NSMutableData(bytes: &buffer, length: bytes)
            
            while inputStream.hasBytesAvailable
            {
                let read = inputStream.read(&buffer, maxLength: 1024)
                bytes += read
                data.appendBytes(&buffer, length: read)
            }
            
            if let str = NSString(bytes: data.bytes, length: bytes, encoding: NSUTF8StringEncoding)
            {
                var split:[String] = Utilities.split(str, separator: "\n")
                
                for s in split
                {
                    ret.append(s)
                }
            }
        }
        
        inputStream.close()
        
        if ret.count > 0
        {
            return ret
        }
        
        return nil
    }
}

func compileMsg(msg:String...) -> String
{
    var ret = ""
    
    if msg.count > 0
    {
        for index in 0...msg.count-1
        {
            ret += msg[index]
            
            if index < msg.count-1
            {
                ret += Constants.SPLITTER_1
            }
        }
    }
    
    return ret
}