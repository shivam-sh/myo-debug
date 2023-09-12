//
//  BluetoothService.swift
//  Myo Debug
//
//  Created by Shivam Sharma on 2022-07-06.
//

import CoreBluetooth

final class BluetoothManager: NSObject, ObservableObject {
    
    var centralManager: CBCentralManager?
    
    var peripheral: CBPeripheral? = nil
    
    @Published var myoInfo: Myo.FirmwareInfo? = nil
    @Published var firmwareVersion: Myo.FirmwareVersion? = nil
    @Published var imuData: Myo.IMUData? = nil
    @Published var classifierEvent: Myo.ClassifierEvent? = nil
    @Published var motionEvents: Myo.MotionEvent? = nil
    @Published var emgData: Myo.EMGData? = nil
    @Published var parsedEMG: [Int8] = Array(repeating: 0, count: 8)
    
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            
            centralManager?.scanForPeripherals(withServices: [
                CBUUID(string: Myo.Services.controlService.rawValue)
            ])
        @unknown default:
            print("Uh oh")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard RSSI.intValue < -20 else { return }
        peripheral.delegate = self
        self.peripheral = peripheral
        centralManager?.connect(peripheral)
        centralManager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        peripheral.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let charactersitics = service.characteristics else { return }
        
        for characteristic in charactersitics {
            switch Myo.Characteristics(rawValue: characteristic.uuid.uuidString) {
            case .myoInfo:
                peripheral.readValue(for: characteristic)
            case .firmwareVersion:
                peripheral.readValue(for: characteristic)
            case .command:
                peripheral.writeValue(
                    Myo.Commands.SetMode(
                        emgMode: .sendEMG,
                        imuMode: .sendData,
                        classifierMode: .enabled)
                    .packed(),
                    for: characteristic, type: .withResponse)

            case .imuData:
                peripheral.setNotifyValue(true, for: characteristic)
            case .motionEvent:
                peripheral.setNotifyValue(true, for: characteristic)
            case .classifierEvent:
                peripheral.setNotifyValue(true, for: characteristic)
            case .emgData0:
                peripheral.setNotifyValue(true, for: characteristic)
            case .emgData1:
                peripheral.setNotifyValue(true, for: characteristic)
            case .emgData2:
                peripheral.setNotifyValue(true, for: characteristic)
            case .emgData3:
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print(characteristic)
            print(error.debugDescription)
            return
        }
        guard let value = characteristic.value else {
            print(characteristic)
            return
        }

        switch Myo.Characteristics(rawValue: characteristic.uuid.uuidString) {
        case .myoInfo:
//            print("myoInfo")
            do {
                myoInfo = try Myo.FirmwareInfo(data: value)
            } catch {}
        case .firmwareVersion:
//            print("firmwareVersion")
            do {
                firmwareVersion = try Myo.FirmwareVersion(data: value)
            } catch {}
        case .command:
//            print("command")
            break
        case .imuData:
//            print("imuData")
            do {
                imuData = try Myo.IMUData(data: value)
            } catch {}
        case .motionEvent:
//            print("motionEvent")
            do {
                motionEvents = try Myo.MotionEvent(data: value)
            } catch {}
        case .classifierEvent:
//            print("classifierEvent")
            do {
                classifierEvent = try Myo.ClassifierEvent(data: value)
            } catch {}
        case .emgData0, .emgData1, .emgData2, .emgData3:
            do {
                try emgData = Myo.EMGData(data: value)
                if ((emgData?.sample2.isEmpty) != nil) {
                    parsedEMG = emgData?.sample1 ?? []
                }
                else {
                    parsedEMG = emgData?.sample2 ?? []
                }
            } catch {}
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print(error.debugDescription)
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print(error.debugDescription)
            return
        }
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {}
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {}
}

