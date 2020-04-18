//
//  main.swift
//  Transmog
//

import Foundation
import ArgumentParser

enum ConversionParameters {
    static var skipColorProfileCorrection: Bool = false
}

struct Transmog: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "transmog",
        abstract: "A command-line tool to convert VSCode theme files into Xcode theme files"
    )

    @Argument(
        // default: "~/Desktop/theme.json", // uncomment for testing within Xcode
        help: ArgumentHelp(
            "Path or URL of the VSCode theme file (.json). GitHub links are also supported.",
            valueName: "theme-file-path-or-url"
        ),
        transform: { URLExpander.expandedURL($0) }
    )
    var pathOrURL: String

    @Option(
        name: .shortAndLong,
        default: "~/Library/Developer/Xcode/UserData/FontAndColorThemes/",
        help: "Output directory path (optional)"
    )
    var output: String

    @Flag(
        name: .shortAndLong,
        help: """
        Skip the color profile correction of VSCode theme values.
        This will cause theme colors to look different in Xcode from what they appear like in VSCode.
        """
    )
    var skipColorProfileCorrection: Bool

    func run() throws {
        ConversionParameters.skipColorProfileCorrection = skipColorProfileCorrection

        // Load the theme file
        let vscodeTheme = try VSCodeTheme.read(fromPathOrURL: pathOrURL)

        // Convert it
        guard let xcodeTheme = XcodeTheme.from(vscodeTheme.colors) else {
            throw TransmogError.couldNotCreateTheme
        }

        // Figure out the theme name
        var themeName = vscodeTheme.content.name ?? pathOrURL.lastPathComponentWithoutPathExtension
        themeName = themeName.removingPercentEncoding ?? themeName
        let outputName = "(t)\(themeName)"

        // Determine the output path
        let outputPath = ("\(output)/\(outputName).xccolortheme" as NSString).expandingTildeInPath

        // Save it
        try xcodeTheme.save(toPath: outputPath)

        print("Saved as \"\(outputName)\"")
    }
}

Transmog.main()
