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
        abstract: "A command-line tool for converting VSCode themes files into Xcode theme files"
    )

    @Argument(
        help: ArgumentHelp(
            "Path or URL of the VSCode theme file (.json). GitHub and VS Marketplace links are also supported.",
            valueName: "theme-file-path-or-url"
        )
    )
    var pathOrURL: String // = "~/Desktop/theme.json" // uncomment default value for testing within Xcode

    @Option(
        name: .shortAndLong,
        help: "Output directory path (optional)"
    )
    var output: String = "~/Library/Developer/Xcode/UserData/FontAndColorThemes/"

    @Flag(
        name: .shortAndLong,
        help: """
        Skip the color profile correction of VSCode theme values.
        This will cause theme colors to look different in Xcode from what they appear like in VSCode.
        """
    )
    var skipColorProfileCorrection: Bool = false

    @Flag(name: .shortAndLong) var verbose: Bool = false

    func run() throws {
        ConversionParameters.skipColorProfileCorrection = skipColorProfileCorrection

        if let themeJSONURLs = VSMarketplace.themeJSONURLs(fromMarketplaceURL: pathOrURL) {
            for themeJSONURL in themeJSONURLs {
                do {
                    try convertThemeFile(pathOrURL: themeJSONURL.path)
                } catch let error {
                    print(error)
                }
            }
        } else {
            try convertThemeFile(pathOrURL: pathOrURL)
        }
    }
    
    func convertThemeFile(pathOrURL: String) throws {
        // Load the theme file
        let vscodeTheme = try VSCodeTheme.read(fromPathOrURL: pathOrURL)

        // Convert it
        guard let xcodeTheme = XcodeTheme.from(vscodeTheme.colors) else {
            throw TransmogError.couldNotCreateTheme
        }

        if verbose {
            xcodeTheme.content.printValues()
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
