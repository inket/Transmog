//
//  XcodeTheme.swift
//  Transmog
//

import Foundation
import AppKit

extension NSColor {
    var asXcodeColor: XcodeTheme.Color {
        XcodeTheme.Color(rawColor: self)
    }
}

// Resources:
// https://touchwonders.com/blog/a-closer-look-at-xcode-themes

struct XcodeTheme: Theme {
    static func from(_ colors: Colors) -> XcodeTheme? {
        let background = colors.background.asXcodeColor
        let foreground = colors.text.asXcodeColor

        return XcodeTheme(
            content: Content(
                background: colors.background.asXcodeColor,
                currentLineBackground: colors.currentLineBackground?.asXcodeColor ?? background,
                selection: colors.selection?.asXcodeColor,
                cursor: colors.cursor?.asXcodeColor,
                invisibles: colors.invisibles?.asXcodeColor,
                syntaxColors: SyntaxColors(
                    text: colors.text.asXcodeColor,
                    comment: colors.comment?.asXcodeColor,
                    documentation: colors.documentation?.asXcodeColor,
                    documentationKeyword: colors.documentation?.asXcodeColor,
                    mark: colors.documentation?.asXcodeColor ?? colors.comment?.asXcodeColor,
                    string: colors.string?.asXcodeColor,
                    character: colors.character?.asXcodeColor,
                    number: colors.number?.asXcodeColor,
                    keyword: colors.keyword?.asXcodeColor,
                    preprocessor: colors.preprocessor?.asXcodeColor,
                    url: colors.documentation?.asXcodeColor,
                    attribute: foreground,
                    declarationType: colors.declarationType?.asXcodeColor,
                    declarationOther: colors.declarationOther?.asXcodeColor,
                    classNameProject: colors.classNameProject?.asXcodeColor,
                    functionNameProject: colors.functionNameProject?.asXcodeColor,
                    constantProject: colors.constantProject?.asXcodeColor,
                    typeNameProject: colors.typeNameProject?.asXcodeColor,
                    instanceVariableProject: colors.variableAndGlobalProject?.asXcodeColor,
                    preprocessorMacroProject: colors.preprocessor?.asXcodeColor,
                    classNameOther: colors.classNameLibrary?.asXcodeColor,
                    functionNameOther: colors.functionNameLibrary?.asXcodeColor,
                    constantOther: colors.constantLibrary?.asXcodeColor,
                    typeNameOther: colors.typeNameLibrary?.asXcodeColor,
                    instanceVariableOther: colors.variableAndGlobalLibrary?.asXcodeColor,
                    preprocessorMacroOther: colors.preprocessor?.asXcodeColor
                )
            )
        )
    }

    var colors: Colors {
        fatalError("Unsupported")
    }

    // MARK: - Implementation

    let content: Content

    static func read(from data: Data) throws -> Self {
        let content = try PropertyListDecoder().decode(Content.self, from: data)

        return XcodeTheme(content: content)
    }

    func dataForSaving() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        return try encoder.encode(content)
    }
}

// MARK: - Xcode Color Model

extension XcodeTheme {
    struct Color: Codable {
        let rawColor: NSColor

        var plistString: String {
            // Xcode uses generic RGB for rendering the colors
            let color = rawColor.usingColorSpace(.genericRGB) ?? rawColor
            return "\(color.redComponent) \(color.greenComponent) \(color.blueComponent) \(color.alphaComponent)"
        }

        var hexString: String {
            rawColor.hexString
        }

        init(rawColor: NSColor) {
            self.rawColor = rawColor
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawString = try container.decode(String.self)

            let components = rawString.components(separatedBy: .whitespaces)

            rawColor = NSColor(
                red: CGFloat((components[0] as NSString).doubleValue),
                green: CGFloat((components[1] as NSString).doubleValue),
                blue: CGFloat((components[2] as NSString).doubleValue),
                alpha: CGFloat((components[3] as NSString).doubleValue)
            )
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(plistString)
        }
    }
}

// MARK: - Theme File Structure Definition

extension XcodeTheme {
    struct Content: Codable {
        enum CodingKeys: String, CodingKey {
            // Background
            case background = "DVTSourceTextBackground"
            // Current Line
            case currentLineBackground = "DVTSourceTextCurrentLineHighlightColor"
            // Selection
            case selection = "DVTSourceTextSelectionColor"
            // Cursor
            case cursor = "DVTSourceTextInsertionPointColor"
            // Invisibles
            case invisibles = "DVTSourceTextInvisiblesColor"

            case syntaxColors = "DVTSourceTextSyntaxColors"
        }

        let background: Color
        let currentLineBackground: Color?
        let selection: Color?
        let cursor: Color?
        let invisibles: Color?

        let syntaxColors: SyntaxColors

        func printValues(_ object: Any? = nil) {
            let mirror = Mirror(reflecting: object ?? self)

            print("\(mirror.subjectType) [")

            mirror.children.forEach {
                guard let label = $0.label else { return }

                if $0.value is SyntaxColors {
                    printValues($0.value)
                } else {
                    switch $0.value {
                    case Optional<Any>.none: print("    \(label): <default>")
                    case let color as Color: print("    \(label): \(color.hexString)")
                    default: break
                    }
                }
            }

            print("]")
        }
    }

    struct SyntaxColors: Codable {
        enum CodingKeys: String, CodingKey {
            // Plain Text
            case text = "xcode.syntax.plain"
            // Comments
            case comment = "xcode.syntax.comment"
            // Documentation Markup
            case documentation = "xcode.syntax.comment.doc"
            // Documentation Markup Keywords
            case documentationKeyword = "xcode.syntax.comment.doc.keyword"
            // Mark
            case mark = "xcode.syntax.mark"
            // Strings
            case string = "xcode.syntax.string"
            // Characters
            case character = "xcode.syntax.character"
            // Numbers
            case number = "xcode.syntax.number"
            // Keywords
            case keyword = "xcode.syntax.keyword"
            // Preprocessor Statements
            case preprocessor = "xcode.syntax.preprocessor"

            // URLs
            case url = "xcode.syntax.url"
            // Attributes (XML attributes)
            case attribute = "xcode.syntax.attribute"

            // Type Declarations
            case declarationType = "xcode.syntax.declaration.type"
            // Other Declarations
            case declarationOther = "xcode.syntax.declaration.other"

            // Project Class Names
            case classNameProject = "xcode.syntax.identifier.class"
            // Project Function and Method Names
            case functionNameProject = "xcode.syntax.identifier.function"
            // Project Constants
            case constantProject = "xcode.syntax.identifier.constant"
            // Project Type Names
            case typeNameProject = "xcode.syntax.identifier.type"
            // Project Instance Variables and Globals
            case instanceVariableProject = "xcode.syntax.identifier.variable"
            // Project Preprocessor Macros
            case preprocessorMacroProject = "xcode.syntax.identifier.macro"

            // Other Class Names
            case classNameOther = "xcode.syntax.identifier.class.system"
            // Other Function and Method Names
            case functionNameOther = "xcode.syntax.identifier.function.system"
            // Other Constants
            case constantOther = "xcode.syntax.identifier.constant.system"
            // Other Type Names
            case typeNameOther = "xcode.syntax.identifier.type.system"
            // Other Instance Variables and Globals
            case instanceVariableOther = "xcode.syntax.identifier.variable.system"
            // Other Preprocessor Macros
            case preprocessorMacroOther = "xcode.syntax.identifier.macro.system"
        }

        let text: Color?
        let comment: Color?
        let documentation: Color?
        let documentationKeyword: Color?
        let mark: Color?
        let string: Color?
        let character: Color?
        let number: Color?
        let keyword: Color?
        let preprocessor: Color?
        let url: Color?
        let attribute: Color?
        let declarationType: Color?
        let declarationOther: Color?
        let classNameProject: Color?
        let functionNameProject: Color?
        let constantProject: Color?
        let typeNameProject: Color?
        let instanceVariableProject: Color?
        let preprocessorMacroProject: Color?
        let classNameOther: Color?
        let functionNameOther: Color?
        let constantOther: Color?
        let typeNameOther: Color?
        let instanceVariableOther: Color?
        let preprocessorMacroOther: Color?
    }
}
