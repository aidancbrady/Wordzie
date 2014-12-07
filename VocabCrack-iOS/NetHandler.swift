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
        
        var buffer = [UInt8]()
        var bytes = inputStream!.read(&buffer, maxLength: 1024)
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
        
        for var i = 0; i < retLines; i++
        {
            var buffer = [UInt8]()
            var bytes = inputStream.read(&buffer, maxLength: 1024)
            
            if let str = NSString(bytes: &buffer, length: bytes, encoding: NSUTF8StringEncoding)
            {
                ret.append(str)
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