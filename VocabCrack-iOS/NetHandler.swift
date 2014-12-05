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
        var input:NSInputStream?
        var output:NSOutputStream?
        
        NSStream.getStreamsToHostWithName(Constants.IP, port: Constants.PORT, inputStream: &input, outputStream: &output)
        
        let inputStream = input!
        let outputStream = output!
        
        inputStream.open()
        outputStream.open()
        
        var data = [UInt8]((str + "\n").utf8)
        
        outputStream.write(&data, maxLength: data.count)
        outputStream.close()
        
        var buffer = [UInt8]()
        var bytes = inputStream.read(&buffer, maxLength: 1024)
        
        inputStream.close()
        
        if let str = NSString(bytes: &buffer, length: bytes, encoding: NSUTF8StringEncoding)
        {
            return str
        }
        
        return nil
    }
}