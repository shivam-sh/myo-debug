//
//  Myo_DebugApp.swift
//  Myo Debug
//
//  Created by Shivam Sharma on 2022-07-06.
//

import SwiftUI

@main
struct Myo_DebugApp: App {
    var body: some Scene {
        WindowGroup {
            DiagnosticsView(bluetoothManager: BluetoothManager())
        }
    }
}
