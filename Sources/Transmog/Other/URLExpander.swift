//
//  URLExpander.swift
//  Transmog
//

import Foundation

enum URLExpander {
    static func expandedURL(_ url: String) -> String {
        expandedGitHubURL(url)
    }

    private static func expandedGitHubURL(_ url: String) -> String {
        guard URLComponents(string: url)?.host == "github.com" else { return url }

        return url
            .replacingOccurrences(of: "//github.com/", with: "//raw.githubusercontent.com/")
            .replacingOccurrences(of: "/blob/", with: "/")
    }
}
