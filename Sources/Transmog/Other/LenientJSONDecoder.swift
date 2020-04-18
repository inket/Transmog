//
//  LenientJSONDecoder.swift
//  Transmog
//

import Foundation
import JavaScriptCore

enum LenientJSONDecoder {
    static func decode<T>(_ type: T.Type, from jsonString: String) throws -> T where T: Decodable {
        let sanitizedJSON = sanitizeJSONComments(jsonString)

        do {
            guard let sanitizedJSONData = sanitizedJSON.data(using: .utf8) else {
                throw TransmogError.invalidInput
            }

            return try JSONDecoder().decode(type, from: sanitizedJSONData)
        } catch {
            guard
                (error as NSError).code == 4864,
                ((error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError)?.code == 3840
            else { throw error }

            // Malformed JSON. Probably because of some comments that we couldn't remove
            // using our regexes. Our last resort is to evaluate it in JS 🙈
            if let jsfiedJSON = jsfiedJSON(jsonString), let jsfiedJSONData = jsfiedJSON.data(using: .utf8) {
                let originalError = error

                do {
                    return try JSONDecoder().decode(type, from: jsfiedJSONData)
                } catch {
                    throw originalError
                }
            } else {
                throw error
            }
        }
    }

    static let lineCommentRegex = try! NSRegularExpression(
        pattern: "^\\s*//.*",
        options: .anchorsMatchLines
    )

    static let endOfLineCommentRegex = try! NSRegularExpression(
        pattern: "^(.*[^\\\\]\"[\\[\\]{},])\\s*\\/\\/.*",
        options: .anchorsMatchLines
    )

    static let multilineCommentRegex = try! NSRegularExpression(
        pattern: "(\\/\\*.*?\\*\\/)",
        options: .dotMatchesLineSeparators
    )

    private static func sanitizeJSONComments(_ jsonString: String) -> String {
        var result = lineCommentRegex.stringByReplacingMatches(
            in: jsonString,
            options: [],
            range: NSRange(location: 0, length: jsonString.count),
            withTemplate: ""
        )

        result = endOfLineCommentRegex.stringByReplacingMatches(
            in: result,
            options: [],
            range: NSRange(location: 0, length: result.count),
            withTemplate: "$1"
        )

        result = multilineCommentRegex.stringByReplacingMatches(
            in: result,
            options: [],
            range: NSRange(location: 0, length: result.count),
            withTemplate: ""
        )

        return result
    }

    private static func jsfiedJSON(_ jsonString: String) -> String? {
        let output = JSContext()!.evaluateScript("var json=\(jsonString);JSON.stringify(json)")?.toString()
        return output == "undefined" ? nil : output
    }
}
