//
//  DiagnosticsView.swift
//  Myo Debug
//
//  Created by Shivam Sharma on 2022-07-06.
//

import SwiftUI

public struct DiagnosticsView: View {
    @StateObject var bluetoothManager: BluetoothManager

    public var body: some View {
        List {
            Section("Myo Info") {
                Text("Serial: \(bluetoothManager.myoInfo?.serialNumber)" as String)
                Text("SKU: \(bluetoothManager.myoInfo?.sku)" as String)
            }

            Section("Firmware Version") {
                Text("\(bluetoothManager.firmwareVersion?.major)" as String)
                Text("\(bluetoothManager.firmwareVersion?.minor)" as String)
                Text("\(bluetoothManager.firmwareVersion?.patch)" as String)
            }

            Section("Classifier Events") {
                Text("Event: \(bluetoothManager.classifierEvent?.type)" as String)
                Text("Sync Result: \(bluetoothManager.classifierEvent?.eventData.syncResult)" as String)
                Text("Sync Data: \(bluetoothManager.classifierEvent?.eventData.armSyncedData)" as String)
                Text("Arm Direction: \(bluetoothManager.classifierEvent?.eventData.armSyncedData?.xDirection)" as String)
                Text("Current Pose: \(bluetoothManager.classifierEvent?.eventData.pose)" as String)
            }
            Section("Motion Events") {
                Text("Event: \(bluetoothManager.motionEvents?.type)" as String)
                Text("Tap Direction: \(bluetoothManager.motionEvents?.tapDirection)" as String)
                Text("Tap Count: \(bluetoothManager.motionEvents?.tapCount)" as String)
            }

            Section("IMU") {
                Text("Orientation: \(bluetoothManager.imuData?.orientation)" as String)
                Text("Accelerometer: \(bluetoothManager.imuData?.accelerometer)" as String)
                Text("Gyroscope: \(bluetoothManager.imuData?.gyroscope)" as String)
                
                
            }

            Section("EMG1") {
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[0] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[1] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[2] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[3] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[4] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[5] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[6] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample1[7] ?? 0).magnitude, total: 128)
            }
            
            Section("EMG2") {
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[0] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[1] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[2] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[3] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[4] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[5] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[6] ?? 0).magnitude, total: 128)
                ProgressView(value: Float(bluetoothManager.emgData?.sample2[7] ?? 0).magnitude, total: 128)
            }
        }
    }
}

struct DiagnosticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiagnosticsView(bluetoothManager: BluetoothManager())
    }
}
