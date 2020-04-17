//
//  CodableArrayOrObject.swift
//  Transmog
//

import Foundation

class ArrayOrObject<T: Codable>: Codable {
    let array: [T]

    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let singleValue = try? container.decode(T.self) {
            array = [singleValue]
        } else {
            array = try container.decode([T].self)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(array)
    }
}
