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

struct VSCodeTheme: Theme {
    let content: Content

    var isDarkTheme: Bool {
        content.type == "dark"
    }

    var colors: Colors {
        let isDarkTheme = content.type == "dark"
        let defaultBackground: NSColor = isDarkTheme ? .black : .white
        let defaultForeground: NSColor = isDarkTheme ? .white : .black

        return Colors(
            background: color(forKey: "editor.background") ?? defaultBackground,
            currentLineBackground: color(forKey: ""),
            selection: color(forKey: "editor.selectionBackground"),
            cursor: color(forKey: "editorCursor.foreground"),
            invisibles: color(forKey: "editorWhitespace.foreground"),
            text: color(forKey: "editor.foreground") ?? color(forKey: "foreground") ?? defaultForeground,
            comment: color(forKey: "comment"),
            documentation: color(forKey: "comment"),
            string: color(forKey: "string.quoted") ?? color(forKey: "string"),
            character: color(forKey: "constant.character"),
            number: color(forKey: "constant.numeric") ?? color(forKey: "constant.character.numeric"),
            keyword: color(forKey: "keyword.other") ?? color(forKey: "keyword"),
            variable: color(forKey: "variable") ?? color(forKey: "variable.other"),
            preprocessor: color(forKey: "entity.name.function.preprocessor.cpp"),
            declarationType: color(forKey: "storage.type"),
            declarationOther: color(forKey: "entity.name.function") ?? color(forKey: "storage"),
            classNameProject: color(forKey: "entity.name.class"),
            functionNameProject: color(forKey: "entity.name.function") ?? color(forKey: "variable.function"),
            constantProject: color(forKey: "entity.name.constant") ?? color(forKey: "variable.other.constant"),
            typeNameProject: color(forKey: "entity.name.type"),
            classNameLibrary: color(forKey: "support.class"),
            functionNameLibrary: color(forKey: "support.function"),
            constantLibrary: color(forKey: "support.constant") ?? color(forKey: "constant.language"),
            typeNameLibrary: color(forKey: "support.type")
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

    private func color(forKey key: String) -> NSColor? {
        let hex: String

        if let foundColor = content.colors[key].flatMap({ $0 }) {
            hex = foundColor
        } else {
            let tokenColor = content.tokenColors.first {
                $0.scope?.array.contains(key) == true
            }

            if let color = tokenColor?.settings["foreground"] {
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
        let settings: [String: String]
    }
}
