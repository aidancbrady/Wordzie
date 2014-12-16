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
        var inputStream:NSInputStream?
        var outputStream:NSOutputStream?
        
        NSStream.getStreamsToHostWithName(Constants.IP, port: Constants.PORT, inputStream: &inputStream, outputStream: &outputStream)
        
        var data = [UInt8]((str + "\n").utf8)
        
        outputStream!.open()
        outputStream!.write(&data, maxLength: data.count)
        outputStream!.close()
        
        inputStream!.open()
        
        var buffer = [UInt8](count:16384, repeatedValue:0)
        var bytes = inputStream!.read(&buffer, maxLength: 16384)
        inputStream?.close()
        
        if let str = NSString(bytes: &buffer, length: bytes, encoding: NSUTF8StringEncoding)
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
            var buffer = [UInt8](count:16384, repeatedValue:0)
            var bytes = inputStream.read(&buffer, maxLength: 16384)
            
            if let str = NSString(bytes: &buffer, length: bytes, encoding: NSUTF8StringEncoding)
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