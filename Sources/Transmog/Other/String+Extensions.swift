//
//  String+Extensions.swift
//  Transmog
//

import Foundation

extension String {
    var isNetworkURL: Bool {
        guard let urlComponents = URLComponents(string: self) else { return false }

        switch urlComponents.host {
        case "http", "https": return true
        case "file": return false
        case .none: return !FileManager.default.fileExists(atPath: self)
        default: return false
        }
    }

    var lastPathComponentWithoutPathExtension: String {
        ((self as NSString).deletingPathExtension as NSString).lastPathComponent
    }
}
