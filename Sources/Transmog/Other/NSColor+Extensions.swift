//
//  NSColor+Extensions.swift
//  Transmog
//

import Foundation
import AppKit

extension NSColor {
    var hexString: String {
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(redComponent * 255)),
            lroundf(Float(greenComponent * 255)),
            lroundf(Float(blueComponent * 255))
        )

        if alphaComponent < 1 {
            color += String(format: "%02lX", lroundf(Float(alphaComponent * 255)))
        }

        return color
    }
}
