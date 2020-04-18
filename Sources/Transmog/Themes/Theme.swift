//
//  Theme.swift
//  Transmog
//

import Foundation
import AppKit

protocol Theme {
    // read/write
    static func read(from data: Data) throws -> Self
    func dataForSaving() throws -> Data

    // conversion between themes
    static func from(_ colors: Colors) -> Self?
    var colors: Colors { get }
}

extension Theme {
    static func read(fromPathOrURL pathOrURL: String) throws -> Self {
        if pathOrURL.isNetworkURL {
            guard let url = URL(string: URLExpander.expandedURL(pathOrURL)) else {
                throw TransmogError.invalidURL
            }

            let data = try Data(contentsOf: url)
            return try read(from: data)
        } else {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathOrURL))
            return try read(from: data)
        }
    }

    func save(toPath path: String) throws {
        let url = URL(fileURLWithPath: path)
        let data = try dataForSaving()
        try data.write(to: url)
    }
}

struct Colors {
    let background: NSColor
    let currentLineBackground: NSColor?
    let selection: NSColor?
    let cursor: NSColor?
    let invisibles: NSColor?

    let text: NSColor
    let comment: NSColor?
    let documentation: NSColor?
    let string: NSColor?
    let character: NSColor?
    let number: NSColor?
    let keyword: NSColor?
    let variable: NSColor?

    let preprocessor: NSColor?

    let declarationType: NSColor?
    let declarationOther: NSColor?
    let classNameProject: NSColor?
    let functionNameProject: NSColor?
    let constantProject: NSColor?
    let typeNameProject: NSColor?
    let classNameLibrary: NSColor?
    let functionNameLibrary: NSColor?
    let constantLibrary: NSColor?
    let typeNameLibrary: NSColor?
}
