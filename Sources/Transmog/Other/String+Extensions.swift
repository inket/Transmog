//
//  String+Extensions.swift
//  Transmog
//

import Foundation

extension String {
    var isNetworkURL: Bool {
        guard let urlComponents = URLComponents(string: self) else { return false }

        switch urlComponents.scheme {
        case "http", "https": return true
        case "file": return false
        case .none:
            let expandedPath = (self as NSString).expandingTildeInPath
            return !FileManager.default.fileExists(atPath: expandedPath)
        default: return false
        }
    }

    var lastPathComponentWithoutPathExtension: String {
        ((self as NSString).deletingPathExtension as NSString).lastPathComponent
    }
}
