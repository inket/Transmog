//
//  JSONSanitizer.swift
//  Transmog
//

import Foundation

enum JSONSanitizer {
    static func sanitizedJSON(for json: String) throws -> String {
        let commentRegex = try NSRegularExpression(pattern: "//.*", options: [])
        let multilineCommentRegex = try NSRegularExpression(
            pattern: "(\\/\\*.*?\\*\\/)",
            options: .dotMatchesLineSeparators
        )

        var sanitizedJSON = commentRegex.stringByReplacingMatches(
            in: json,
            options: [],
            range: NSRange(location: 0, length: json.count),
            withTemplate: ""
        )

        sanitizedJSON = multilineCommentRegex.stringByReplacingMatches(
            in: sanitizedJSON,
            options: [],
            range: NSRange(location: 0, length: sanitizedJSON.count),
            withTemplate: ""
        )

        return sanitizedJSON
    }
}
