//
//  Message.swift
//  OmniKit
//
//  Created by Pete Schwamb on 10/14/17.
//  Copyright © 2017 Pete Schwamb. All rights reserved.
//

import Foundation

public enum MessageError: Error {
    case notEnoughData
    case invalidCrc
    case parsingError(offset: Int, data: Data, error: Error)
    case unknownValue(value: UInt8, typeDescription: String)
    case validationFailed(description: String)
}

struct Message {
    let address: UInt32
    let messageBlocks: [MessageBlock]
    let sequenceNum: Int
    
    init(address: UInt32, messageBlocks: [MessageBlock], sequenceNum: Int) {
        self.address = address
        self.messageBlocks = messageBlocks
        self.sequenceNum = sequenceNum
    }
    
    init(encodedData: Data) throws {
        guard encodedData.count >= 10 else {
            throw MessageError.notEnoughData
        }
        self.address = encodedData[0...].toBigEndian(UInt32.self)
        let b9 = encodedData[4]
        let bodyLen = encodedData[5]
        
        if bodyLen > encodedData.count - 8 {
            throw MessageError.notEnoughData
        }
        
        self.sequenceNum = Int((b9 >> 2) & 0b11111)
        let crc = (UInt16(encodedData[encodedData.count-2]) << 8) + UInt16(encodedData[encodedData.count-1])
        let msgWithoutCrc = encodedData.prefix(encodedData.count - 2)
        guard msgWithoutCrc.crc16() == crc else {
            throw MessageError.invalidCrc
        }
        self.messageBlocks = try Message.decodeBlocks(data: Data(msgWithoutCrc.suffix(from: 6)))
    }
    
    static private func decodeBlocks(data: Data) throws -> [MessageBlock]  {
        var blocks = [MessageBlock]()
        var idx = 0
        repeat {
            guard let blockType = MessageBlockType(rawValue: data[idx]) else {
                throw MessageBlockError.unknownBlockType(rawVal: data[idx])
            }
            do {
                let block = try blockType.blockType.init(encodedData: data.suffix(from: idx))
                blocks.append(block)
                idx += Int(block.data.count)
            } catch (let error) {
                throw MessageError.parsingError(offset: idx, data: data.suffix(from: idx), error: error)
            }
        } while idx < data.count
        return blocks
    }
    
    func encoded() -> Data {
        var bytes = Data(bigEndian: address)
        
        var cmdData = Data()
        for cmd in messageBlocks {
            cmdData.append(cmd.data)
        }
        
        let b9: UInt8 = (UInt8(sequenceNum & 0b11111) << 2) + UInt8((cmdData.count >> 8) & 0b11)
        bytes.append(b9)
        bytes.append(UInt8(cmdData.count & 0xff))
        
        var data = Data(bytes) + cmdData
        let crc = data.crc16()
        data.appendBigEndian(crc)
        return data
    }
}

