//
//  String+Extensions.swift
//  Transmog
//

import Foundation

extension String {
    var lastPathComponentWithoutPathExtension: String {
        ((self as NSString).deletingPathExtension as NSString).lastPathComponent
    }
}
