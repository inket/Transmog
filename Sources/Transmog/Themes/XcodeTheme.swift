//
//  XcodeTheme.swift
//  Transmog
//

import Foundation
import AppKit

extension NSColor {
    fileprivate var string: String {
        // Xcode uses generic RGB for rendering the colors
        let color = usingColorSpace(.genericRGB) ?? self
        
        return "\(color.redComponent) \(color.greenComponent) \(color.blueComponent) \(color.alphaComponent)"
    }
}

struct XcodeTheme: Theme {
    static func from(_ colors: Colors) -> XcodeTheme? {
        let background = colors.background.string
        let foreground = colors.text.string

        return XcodeTheme(
            content: Content(
                background: colors.background.string,
                currentLineBackground: colors.currentLineBackground?.string ?? background,
                selection: colors.selection?.string,
                cursor: colors.cursor?.string,
                invisibles: colors.invisibles?.string,
                syntaxColors: SyntaxColors(
                    text: colors.text.string,
                    comment: colors.comment?.string,
                    documentation: colors.documentation?.string,
                    documentationKeyword: colors.documentation?.string,
                    mark: colors.documentation?.string ?? colors.comment?.string,
                    string: colors.string?.string,
                    character: colors.character?.string,
                    number: colors.number?.string,
                    keyword: colors.keyword?.string,
                    preprocessor: colors.preprocessor?.string,
                    url: colors.documentation?.string,
                    attribute: foreground,
                    declarationType: colors.declarationType?.string,
                    declarationOther: colors.declarationOther?.string,
                    classNameProject: colors.classNameProject?.string,
                    functionNameProject: colors.functionNameProject?.string,
                    constantProject: colors.constantProject?.string,
                    typeNameProject: colors.typeNameProject?.string,
                    instanceVariableProject: colors.variable?.string,
                    preprocessorMacroProject: colors.preprocessor?.string,
                    classNameOther: colors.classNameLibrary?.string,
                    functionNameOther: colors.functionNameLibrary?.string,
                    constantOther: colors.constantLibrary?.string,
                    typeNameOther: colors.typeNameLibrary?.string,
                    instanceVariableOther: colors.variable?.string,
                    preprocessorMacroOther: colors.preprocessor?.string
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

        let background: String
        let currentLineBackground: String?
        let selection: String?
        let cursor: String?
        let invisibles: String?

        let syntaxColors: SyntaxColors
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

        let text: String?
        let comment: String?
        let documentation: String?
        let documentationKeyword: String?
        let mark: String?
        let string: String?
        let character: String?
        let number: String?
        let keyword: String?
        let preprocessor: String?
        let url: String?
        let attribute: String?
        let declarationType: String?
        let declarationOther: String?
        let classNameProject: String?
        let functionNameProject: String?
        let constantProject: String?
        let typeNameProject: String?
        let instanceVariableProject: String?
        let preprocessorMacroProject: String?
        let classNameOther: String?
        let functionNameOther: String?
        let constantOther: String?
        let typeNameOther: String?
        let instanceVariableOther: String?
        let preprocessorMacroOther: String?
    }
}
