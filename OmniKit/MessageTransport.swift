//
//  MessageTransport.swift
//  OmniKit
//
//  Created by Pete Schwamb on 8/5/18.
//  Copyright © 2018 Pete Schwamb. All rights reserved.
//

import Foundation

import RileyLinkBLEKit

class MessageTransport {
    
    private let session: CommandSession
    
    private var packetNumber = 0
    private var messageNumber = 0
    private let address: UInt32
    private var ackAddress: UInt32 // During pairing, PDM acks with address it is assigning to channel

    
    init(session: CommandSession, address: UInt32 = 0xffffffff, ackAddress: UInt32? = nil) {
        self.session = session
        self.address = address
        self.ackAddress = ackAddress ?? address
    }
    
    private func incrementPacketNumber(_ count: Int = 1) {
        packetNumber = (packetNumber + count) & 0b11111
    }
    
    private func incrementMessageNumber(_ count: Int = 1) {
        messageNumber = (messageNumber + count) & 0b1111
    }
    
    func makeAckPacket() -> Packet {
        return Packet(address: address, packetType: .ack, sequenceNum: packetNumber, data:Data(bigEndian: ackAddress))
    }
    
    func ackUntilQuiet() throws {
        
        let packetData = makeAckPacket().encoded()
        
        var quiet = false
        while !quiet {
            do {
                let _ = try session.sendAndListen(packetData, repeatCount: 5, timeout: TimeInterval(milliseconds: 600), retryCount: 0, preambleExtension: TimeInterval(milliseconds: 40))
            } catch RileyLinkDeviceError.responseTimeout {
                // Haven't heard anything in 300ms.  POD heard our ack.
                quiet = true
            }
        }
        incrementPacketNumber()
    }
    
    
    func exchangePackets(packet: Packet, repeatCount: Int = 0, packetResponseTimeout: TimeInterval = .milliseconds(165), exchangeTimeout:TimeInterval = .seconds(20), preambleExtension: TimeInterval = .milliseconds(127)) throws -> Packet {
        let packetData = packet.encoded()
        let radioRetryCount = 20
        
        let start = Date()
        
        while (-start.timeIntervalSinceNow < exchangeTimeout)  {
            do {
                let rfPacket = try session.sendAndListen(packetData, repeatCount: repeatCount, timeout: packetResponseTimeout, retryCount: radioRetryCount, preambleExtension: preambleExtension)
                
                let candidatePacket: Packet
                
                do {
                    candidatePacket = try Packet(rfPacket: rfPacket)
                } catch {
                    continue
                }
                
                guard candidatePacket.address == packet.address else {
                    continue
                }
                
                guard candidatePacket.sequenceNum == ((packetNumber + 1) & 0b11111) else {
                    continue
                }
                
                // Once we have verification that the POD heard us, we can increment our counters
                incrementPacketNumber(2)
                
                return candidatePacket
            } catch RileyLinkDeviceError.responseTimeout {
                continue
            }
        }
        
        throw PodCommsError.noResponse
    }
    
    func send(_ messageBlocks: [MessageBlock]) throws -> Message {
        let message = Message(address: address, messageBlocks: messageBlocks, sequenceNum: messageNumber)

        do {
            let responsePacket = try { () throws -> Packet in
                var firstPacket = true
                print("Send to POD: \(message)")
                var dataRemaining = message.encoded()
                while true {
                    let packetType: PacketType = firstPacket ? .pdm : .con
                    let sendPacket = Packet(address: address, packetType: packetType, sequenceNum: self.packetNumber, data: dataRemaining)
                    dataRemaining = dataRemaining.subdata(in: sendPacket.data.count..<dataRemaining.count)
                    firstPacket = false
                    let response = try self.exchangePackets(packet: sendPacket)
                    if dataRemaining.count == 0 {
                        return response
                    }
                }
                }()
            
            guard responsePacket.packetType != .ack else {
                incrementMessageNumber()
                throw PodCommsError.podAckedInsteadOfReturningResponse
            }
            
            // Assemble fragmented message from multiple packets
            let response =  try { () throws -> Message in
                var responseData = responsePacket.data
                while true {
                    do {
                        return try Message(encodedData: responseData)
                    } catch MessageError.notEnoughData {
                        print("Sending ACK for CON")
                        let conPacket = try self.exchangePackets(packet: makeAckPacket(), repeatCount: 3, preambleExtension:TimeInterval(milliseconds: 40))
                        
                        guard conPacket.packetType == .con else {
                            throw PodCommsError.unexpectedPacketType(packetType: conPacket.packetType)
                        }
                        responseData += conPacket.data
                    }
                }
                }()
            
            incrementMessageNumber(2)
            
            try ackUntilQuiet()
            
            guard response.messageBlocks.count > 0 else {
                throw PodCommsError.emptyResponse
            }
            
            return response            
        } catch let error {
            print("Error during communication with POD: \(error)")
            throw error
        }
    }

}
