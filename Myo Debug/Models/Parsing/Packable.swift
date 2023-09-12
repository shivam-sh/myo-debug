//
//  Packable.swift
//  Myo Debug
//
//  Created by Shivam Sharma on 2022-07-06.
//

import Foundation

/// Used when something should be packable down to a bytestream
protocol Packable {
    var bytesWhenPacked: Int { get }
    func packed() -> Data
}

/// Used when something should be instantiable bytestream
protocol Unpackable {
    static var expectedDataLength: Int { get }
    init(data: Data) throws
}

/// Error types associated with instantiation for something conforming to the Unpackable protocol
enum UnpackError: Error {
    case incorrectNumberOfBytes(_ actual: Int, expected: Int)
}

