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
    var ip = "104.236.13.142"
    var port = 26830
    
    func sendData(str:String) -> String?
    {
        var input:NSInputStream?
        var output:NSOutputStream?
        
        NSStream.getStreamsToHostWithName(ip, port: port, inputStream: &input, outputStream: &output)
        
        let inputStream = input!
        let outputStream = output!
        
        inputStream.open()
        outputStream.open()
        
        var data = [UInt8]((str + "\n").utf8)
        
        outputStream.write(&data, maxLength: data.count)
        
        outputStream.close()
        
        var buffer = [UInt8](count: 1024, repeatedValue: 0)
        
        do {
            var bytes = inputStream.read(&buffer, maxLength: 1024)
        } while inputStream.hasBytesAvailable
        
        if let str = String(bytes:buffer, encoding:NSUTF8StringEncoding)
        {
            return str
        }
        
        inputStream.close()
        
        return nil
    }
}