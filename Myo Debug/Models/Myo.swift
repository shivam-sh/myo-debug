//
//  Myo.swift
//  Myo Debug
//
//  Created by Shivam Sharma on 2022-07-06.
//

import Foundation

protocol MyoCommand {
    var commandHeader: Myo.Commands.Header { get }
}


// MARK: - Myo

public struct Myo {
    
    // MARK: - Bluetooth Services
    
    public enum Services: String, CaseIterable {
        case controlService = "d5060001-a904-deb9-4748-2c7f4a124842"
        case imuDataService = "d5060002-a904-deb9-4748-2c7f4a124842"
        case classifierService = "d5060003-a904-deb9-4748-2c7f4a124842"
        case emgDataService = "d5060005-a904-deb9-4748-2c7f4a124842"
        
        // TODO: Unverified, needs further investigation
        // Not documented by thalmic labs
        //        case unknownDataService0 = "d5060004-a904-deb9-4748-2c7f4a124842"
        //        case unknownDataService1 = "d5060006-a904-deb9-4748-2c7f4a124842"
        //        case batteryService = "d506180f-a904-deb9-4748-2c7f4a124842"
        //        case deviceName = "d5062a00-a904-deb9-4748-2c7f4a124842"
    }
    
    
    // MARK: - Bluetooth Characteristics
    
    public enum Characteristics: String {
        /// [R] Serial number and various firmware specific parameters
        case myoInfo = "D5060101-A904-DEB9-4748-2C7F4A124842"
        /// [R]
        case firmwareVersion = "D5060201-A904-DEB9-4748-2C7F4A124842"
        
        /// [W] used to issue commands to the armband
        case command = "D5060401-A904-DEB9-4748-2C7F4A124842"
        
        /// [Notify] - IMU Data
        case imuData = "D5060402-A904-DEB9-4748-2C7F4A124842"
        /// [Indicate] - Motion Event Data
        case motionEvent = "D5060502-A904-DEB9-4748-2C7F4A124842"
        
        /// [Indicate] - Classifier Event Data (Pose)
        case classifierEvent = "D5060103-A904-DEB9-4748-2C7F4A124842"
        
        /// [Notify]
        case emgData0 = "D5060105-A904-DEB9-4748-2C7F4A124842"
        /// [Notify]
        case emgData1 = "D5060205-A904-DEB9-4748-2C7F4A124842"
        /// [Notify]
        case emgData2 = "D5060305-A904-DEB9-4748-2C7F4A124842"
        /// [Notify]
        case emgData3 = "D5060405-A904-DEB9-4748-2C7F4A124842"
        
        // TODO: Unverified, needs further investigation
        //        case maybeBatteryLevel = "2A19"
        //        case unknown = "2A29"
        //        case unknownCharacteristic0 = "D5060104-A904-DEB9-4748-2C7F4A124842"
        //        case unknownCharacteristic1 = "D5060602-A904-DEB9-4748-2C7F4A124842"
    }
    
    
    // MARK: - Device Commands
    
    public enum Commands: UInt8 {
        case setMode = 0x01
        case vibrate = 0x03
        case deepSleep = 0x04
        case vibrate2 = 0x07
        case setSleepMode = 0x09
        case unlock = 0x0a
        case userAction = 0x0b
        

        // MARK: Header
        
        public struct Header {
            let command: Commands
            let payloadSize: UInt8
        }


        // MARK: SetMode
        
        public enum EMGMode: UInt8 {
            case none = 0x00
            case sendEMG = 0x02
            case sendEMGRaw = 0x03
        }
        
        public enum IMUMode: UInt8 {
            case none = 0x00
            case sendData = 0x01
            case sendEvents = 0x02
            case sendAll = 0x03
            case sendRaw = 0x04
        }
        
        public enum ClassifierMode: UInt8 {
            case disabled = 0x00
            case enabled = 0x01
        }
        
        public struct SetMode: MyoCommand {
            let commandHeader = Header(
                command: .setMode,
                payloadSize: 3)
            let emgMode: EMGMode
            let imuMode: IMUMode
            let classifierMode: ClassifierMode
        }
        
        
        // MARK: Vibrate
        
        public enum VibrationType: UInt8 {
            case none = 0x00
            case short = 0x01
            case medium = 0x02
            case long = 0x03
        }
        
        struct Vibrate: MyoCommand {
            let commandHeader: Header

            let type: VibrationType?

            let duration: UInt16?
            let strength: UInt8?
            
            public init(type: VibrationType) {
                commandHeader = Header(command: .vibrate, payloadSize: 1)
                self.type = type
                
                duration = nil
                strength = nil
            }
            
            public init(duration: UInt16, strength: UInt8) {
                commandHeader = Header(command: .vibrate, payloadSize: 2)
                
                // TODO: Vibration Mode 2
                
                type = nil
                self.duration = nil
                self.strength = nil
            }
        }


        // MARK: DeepSleep

        public struct DeepSleep: MyoCommand {
            let commandHeader = Header(command: .deepSleep, payloadSize: 0)
        }


        // MARK: SetSleepMode
        
        public enum SleepMode: UInt8 {
            case normal = 0
            case neverSleep = 1
        }

        public struct SetSleepMode: MyoCommand {
            let commandHeader = Header(command: .setSleepMode, payloadSize: 1)
            let sleepMode: SleepMode
        }


        // MARK: SetUnlockMode
        
        public enum UnlockMode: UInt8 {
            case lock = 0x00
            case unlockTimed = 0x01
            case unlockHold = 0x02
        }

        public struct SetUnlockMode: MyoCommand {
            let commandHeader = Header(command: .unlock, payloadSize: 1)
            let unlockMode: UnlockMode
        }


        // MARK: UserAction
        
        public enum UserActionType: UInt8 {
            case single = 0
        }
        
        public struct UserAction: MyoCommand {
            let commandHeader = Header(command: .userAction, payloadSize: 1)
            let actionType: UserActionType
        }
    }
    
    
    // MARK: - Device Data


    public enum Poses: UInt16 {
        case rest = 0x0000
        case fist = 0x0001
        case waveIn = 0x0002
        case waveOut = 0x0003
        case fingersSpread = 0x0004
        case doubleTap = 0x0005
        case unknown = 0xffff
    }


    // MARK: FirmwareInfo

    public struct FirmwareInfo {
        let serialNumber: [UInt8]
        
        let unlockPose: UInt16
        let activeClassifierType: ClassifierModel
        let activeClassifierIndex: UInt8
        let hasCustomClassifier: UInt8
        
        let streamIndicating: UInt8
        let sku: SKU
        let reserved: [UInt8]
    }
    
    public enum SKU: UInt8 {
        case unknown = 0
        case black = 1
        case white = 2
    }
    
    public enum HardwareRevision: UInt16 {
        case unknown = 0
        case revC = 1
        case revD = 2
    }

    // MARK: FirmwareVersion
    
    public struct FirmwareVersion {
        let major: UInt16
        let minor: UInt16
        let patch: UInt16
        let hardwareRevision: HardwareRevision
    }
    
    public enum ClassifierModel: UInt8 {
        case builtIn = 0
        case custom = 1
    }


    // MARK: IMUData

    public struct IMUData {
        public struct Quaternion {
            let w: Int16
            let x: Int16
            let y: Int16
            let z: Int16
        }
        
        let orientation: Quaternion
        let accelerometer: [Int16]
        let gyroscope: [Int16]
        
        static let defaultSampleRate = 50
        static let orientationScale = 16384.0
        static let accelerometerScale = 2048.0
        static let gyroscopeScale = 16.0
    }
    
    public enum MotionEventType: UInt8 {
        case tap = 0x00
    }


    // MARK: MotionEvent

    public struct MotionEvent {
        let type: MotionEventType
        
        let tapDirection: UInt8
        let tapCount: UInt8
    }


    // MARK: ClassifierEvent

    public enum ClassifierEventType: UInt8 {
        case armSynced = 0x01
        case armUnsynced = 0x02
        case pose = 0x03
        case unlocked = 0x04
        case locked = 0x05
        case syncFailed = 0x06
    }

    public enum Arm: UInt8 {
        case right = 0x01
        case left = 0x02
        case unknown = 0xff
    }
    
    public enum XDirection: UInt8 {
        case towardsWrist = 0x01
        case towardsElbow = 0x02
        case unknown = 0xff
    }
    
    enum SyncResult: UInt8 {
        case failedTooHard = 0x01
    }

    public struct ClassifierEvent {
        let type: ClassifierEventType
        let eventData: EventData
        
        struct EventData {
            struct ArmSyncedData {
                let arm: Arm
                let xDirection: XDirection
            }
            
            // for .armSynced
            let armSyncedData: ArmSyncedData?
            
            // for .pose
            let pose: Poses?
            
            // for .syncFailed
            let syncResult: SyncResult?
        }
        
    }

    // MARK: EMGData
    
    public struct EMGData {
        var sample1: [Int8]
        var sample2: [Int8]
    }
}


// MARK: - Extension Packable

extension Packable where Self: MyoCommand {
    var bytesWhenPacked: Int { Int(commandHeader.payloadSize) + commandHeader.bytesWhenPacked }
}


// MARK: - Extension Commands

extension Myo.Commands.Header: Packable {
    var bytesWhenPacked: Int { 2 }
    func packed() -> Data {
        return Data([command.rawValue, payloadSize])
    }
}

extension Myo.Commands.SetMode: Packable {
    func packed() -> Data {
        var data = Data()
        data.insert(contentsOf: commandHeader.packed(), at: 0)
        data.insert(emgMode.rawValue, at: data.count)
        data.insert(imuMode.rawValue, at: data.count)
        data.insert(classifierMode.rawValue, at: data.count)
        return data
    }
}

extension Myo.Commands.Vibrate: Packable {
    func packed() -> Data {
        if let type = type {
            var data = Data()
            data.insert(contentsOf: commandHeader.packed(), at: 0)
            data.insert(type.rawValue, at: data.count)
            return data
        }

        // TODO: Vibration Mode 2
        return Data(count: 3)
    }
}

extension Myo.Commands.DeepSleep: Packable {
    func packed() -> Data {
        var data = Data()
        data.insert(contentsOf: commandHeader.packed(), at: 0)
        return data
    }
}

extension Myo.Commands.SetSleepMode: Packable {
    func packed() -> Data {
        var data = Data()
        data.insert(contentsOf: commandHeader.packed(), at: 0)
        data.insert(sleepMode.rawValue, at: data.count)
        return data
    }
}

extension Myo.Commands.SetUnlockMode: Packable {
    func packed() -> Data {
        var data = Data()
        data.insert(contentsOf: commandHeader.packed(), at: 0)
        data.insert(unlockMode.rawValue, at: data.count)
        return data
    }
}

extension Myo.Commands.UserAction: Packable {
    func packed() -> Data {
        var data = Data()
        data.insert(contentsOf: commandHeader.packed(), at: 0)
        data.insert(actionType.rawValue, at: data.count)
        return data
    }
}


// MARK: - Extension Device Data

extension Myo.FirmwareInfo: Unpackable {
    static let expectedDataLength: Int = 20

    init(data: Data) throws {
        guard data.count == Self.expectedDataLength else {
            throw UnpackError.incorrectNumberOfBytes(data.count, expected: Self.expectedDataLength)
        }

        serialNumber = data[0...5].reversed()
        unlockPose = UInt16((data[7] << 4)) + UInt16(data[6])
        activeClassifierType = Myo.ClassifierModel(rawValue: data[8]) ?? .builtIn
        activeClassifierIndex = data[9]
        hasCustomClassifier = data[10]
        streamIndicating = data[11]
        sku = Myo.SKU(rawValue: data[12]) ?? .unknown
        reserved = data[13...19]
            .reversed()
            .compactMap { $0 }
    }
}

extension Myo.FirmwareVersion: Unpackable {
    static let expectedDataLength: Int = 8

    init(data: Data) throws {
        guard data.count == Self.expectedDataLength else {
            throw UnpackError.incorrectNumberOfBytes(data.count, expected: Self.expectedDataLength)
        }

        major = UInt16(data[1] << 4) + UInt16(data[0])
        minor = UInt16(data[3] << 4) + UInt16(data[2])
        patch = UInt16(data[5] << 4) + UInt16(data[4])
        hardwareRevision = Myo.HardwareRevision(
            rawValue: UInt16(data[7] << 4) + UInt16(data[6])) ?? .unknown
    }
}

extension Myo.MotionEvent: Unpackable {
    static let expectedDataLength: Int = 3

    init(data: Data) throws {
        guard data.count == Self.expectedDataLength else {
            throw UnpackError.incorrectNumberOfBytes(data.count, expected: Self.expectedDataLength)
        }

        type = Myo.MotionEventType(rawValue: data[0]) ?? .tap
        tapDirection = data[1]
        tapCount = data[2]
    }
}

extension Myo.ClassifierEvent: Unpackable {
    static let expectedDataLength: Int = 6 

    init(data: Data) throws {
        guard data.count == Self.expectedDataLength else {
            throw UnpackError.incorrectNumberOfBytes(data.count, expected: Self.expectedDataLength)
        }

        type = Myo.ClassifierEventType(rawValue: data[0]) ?? .locked

        switch type {
        case .armSynced:
            eventData = EventData(
                armSyncedData: EventData.ArmSyncedData(
                    arm: Myo.Arm(rawValue: data[1]) ?? .unknown,
                    xDirection: Myo.XDirection(rawValue: data[2]) ?? .unknown),
                pose: nil,
                syncResult: nil)
        case .syncFailed:
            eventData = EventData(
                armSyncedData: nil,
                pose: nil,
                syncResult: Myo.SyncResult(rawValue: data[1]))
        case .pose:
            eventData = EventData(
                armSyncedData: nil,
                pose: Myo.Poses(rawValue: UInt16(data[2] << 4) + UInt16(data[1])),
                syncResult: nil)
        default:
            eventData = EventData(armSyncedData: nil, pose: nil, syncResult: nil)
        }
    }
}

extension Myo.IMUData: Unpackable {
    static let expectedDataLength: Int = 20

    init(data: Data) throws {
        guard data.count == Self.expectedDataLength else {
            throw UnpackError.incorrectNumberOfBytes(data.count, expected: Self.expectedDataLength)
        }

        orientation = Quaternion(
            w: (Int16(data[1] << 4) + Int16(data[0])),
            x: Int16(data[3] << 4) + Int16(data[2]),
            y: Int16(data[5] << 4) + Int16(data[4]),
            z: Int16(data[7] << 4) + Int16(data[6]))

        accelerometer = [
            Int16(data[9] << 4) + Int16(data[8]),
            Int16(data[11] << 4) + Int16(data[10]),
            Int16(data[13] << 4) + Int16(data[12])
        ]

        gyroscope = [
            Int16(data[15] << 4) + Int16(data[14]),
            Int16(data[17] << 4) + Int16(data[16]),
            Int16(data[19] << 4) + Int16(data[18])
        ]
    }
}

extension Myo.EMGData: Unpackable {
    static let expectedDataLength: Int = 16

    init(data: Data) throws {
        guard data.count == Self.expectedDataLength else {
            throw UnpackError.incorrectNumberOfBytes(data.count, expected: Self.expectedDataLength)
        }

        sample1 = []
        for index in 0..<8 {
            sample1.insert(Int8(bitPattern: data[index]), at: index)
        }
        sample2 = []
        for index in 8..<16 {
            sample2.insert(Int8(bitPattern: data[index]), at: index - 8)
        }
    }
}


// MARK: - Debug

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
