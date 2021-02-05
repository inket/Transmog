//
//  VSCodeTheme.swift
//  Transmog
//

import Foundation
import AppKit
import SwiftHEXColors

extension NSColor {
    // VSCode uses the display's colors instead of assuming the values are sRGB.
    // Therefore, colors are displayed differently from what they're supposed to look like.
    // Our goal is to get the colors to display in other IDEs the same way they display in VSCode,
    // so we embrace this bug by using the main display's color profile.
    // https://github.com/microsoft/vscode/issues/87275
    fileprivate var sameComponentsUsingMainScreenColorProfile: NSColor {
        guard let mainScreenColorSpace = NSScreen.main?.colorSpace else { return self }

        let components = [redComponent, greenComponent, blueComponent, alphaComponent]

        return NSColor(
            colorSpace: mainScreenColorSpace,
            components: components,
            count: 4
        )
    }
}

// Resources:
// https://macromates.com/manual/en/language_grammars

struct VSCodeTheme: Theme {
    let content: Content

    var isDarkTheme: Bool {
        content.type == "dark"
    }

    var colors: Colors {
        let isDarkTheme = content.type == "dark"
        let defaultBackground: NSColor = isDarkTheme ? .black : .white
        let defaultForeground: NSColor = isDarkTheme ? .white : .black

        // vscode/src/vs/editor/common/view/editorColorRegistry.ts
        let defaultCursorColor: NSColor = isDarkTheme ? (NSColor(hexString: "#AEAFAD") ?? .white) : .black

        // Naming conventions: https://macromates.com/manual/en/language_grammars
        return Colors(
            background: color("editor.background") ?? defaultBackground,
            currentLineBackground: color("editor.lineHighlightBackground"),
            selection: color("editor.selectionBackground"),
            cursor: color("editorCursor.foreground") ?? defaultCursorColor,
            invisibles: color("editorWhitespace.foreground"),
            text: color(["editor.foreground", "foreground"]) ?? defaultForeground,
            comment: color("comment~"),
            documentation: color([
                "comment.block.documentation~",
                "comment.block~",
                "comment~"
            ]),
            string: color([
                "string.quoted",
                "string",
                "string.quoted.",
                "string."
            ]),
            character: color([
                "constant.character",
                "constant"
            ]),
            number: color([
                "constant.numeric",
                "constant.character.numeric",
                "constant",
                "constant.numeric.",
                "constant.character.numeric.",
                "constant."
            ]),
            keyword: color([
                "keyword.control",
                "keyword.other",
                "keyword",
                "keyword.control.",
                "keyword.other.",
                "keyword.",
                "storage~"
            ]),
            preprocessor: color([
                "entity.name.function.preprocessor~",
                "entity.name.type~"
            ]),
            declarationType: color("entity.name.type~"),
            declarationOther: color("entity.name.function~"),
            classNameProject: color([
                "variable.other.constant~",
                "variable.other~",
                "variable"
            ]),
            functionNameProject: color([
                "variable.function~",
                "variable"
            ]),
            constantProject: color([
                "entity.name.constant~",
                "variable.other.constant~",
            ]),
            typeNameProject: color([
                "variable.other.constant~",
                "variable.other~",
                "variable"
            ]),
            variableAndGlobalProject: color(["variable", "variable.other~"]),
            classNameLibrary: color("support.class~"),
            functionNameLibrary: color("support.function~"),
            constantLibrary: color(["support.constant~", "constant.language~"]),
            typeNameLibrary: color("support.type~"),
            variableAndGlobalLibrary: color([
                "support.variable~",
                "support~"
            ])
        )
    }

    static func from(_ basicColors: Colors) -> VSCodeTheme? {
        fatalError("Unsupported")
    }

    static func read(from data: Data) throws -> Self {
        guard let rawJSON = String(data: data, encoding: .utf8) else {
            throw TransmogError.invalidInput
        }

        let content = try LenientJSONDecoder.decode(Content.self, from: rawJSON)
        return VSCodeTheme(content: content)
    }

    func dataForSaving() throws -> Data {
        try JSONEncoder().encode(content)
    }
}

// MARK: - Color Lookup

extension VSCodeTheme {
    /**
     Key syntax:
     * "key" for exact match
     * "key." for prefix matching (every key that starts with "key.")
     * "key~" for exact match followed by prefix matching if not found ("key", then "key.")
    */
    fileprivate func color(_ keys: [String]) -> NSColor? {
        for key in keys {
            if let color = color(key) {
                return color
            }
        }

        return nil
    }

    /**
     Key syntax:
     * "key" for exact match
     * "key." for prefix matching (every key that starts with "key.")
     * "key~" for exact match followed by prefix matching if not found ("key", then "key.")
    */
    fileprivate func color(_ key: String) -> NSColor? {
        if key.hasSuffix("~") {
            // Expand "key~" into "key" and "key."
            return color(rawKey: key.replacingOccurrences(of: "~", with: ""))
                ?? color(rawKey: key.replacingOccurrences(of: "~", with: "."))
        } else {
            return color(rawKey: key)
        }
    }

    private func color(rawKey key: String) -> NSColor? {
        let hex: String
        let prefixSearch = key.hasSuffix(".")

        // Search for it within the main colors
        if let foundColor = content.colors[key].flatMap({ $0 }) {
            hex = foundColor
        } else {
            // Search for it within the token colors, in the scope parameter of each token color
            let tokenColor = content.tokenColors.first {
                $0.scope?.array.contains { scope in
                    if prefixSearch {
                        return scope.hasPrefix(key)
                    } else {
                        return scope == key
                    }
                } ?? false
            }

            if let color = tokenColor?.settings?["foreground"] {
                hex = color
            } else {
                return nil
            }
        }

        if ConversionParameters.skipColorProfileCorrection {
            return NSColor(hexString: hex)
        } else {
            return NSColor(hexString: hex)?.sameComponentsUsingMainScreenColorProfile
        }
    }
}

// MARK: - Theme File Structure Definition

extension VSCodeTheme {
    struct Content: Codable {
        let name: String?
        let type: String?

        let colors: [String: String?]
        let tokenColors: [TokenColor]
    }

    struct TokenColor: Codable {
        let name: String?
        let scope: ArrayOrObject<String>?
        let settings: [String: String]?
    }
}
