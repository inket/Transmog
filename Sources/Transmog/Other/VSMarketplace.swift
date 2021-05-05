//
//  VSMarketplace.swift
//  Transmog
//

import Foundation
import Zip

private struct Response: Codable {
    struct Result: Codable {
        struct Extension: Codable {
            struct Version: Codable {
                struct File: Codable {
                    let assetType: String
                    let source: URL
                }

                var files: [File]
            }

            var versions: [Version]
        }

        var extensions: [Extension]
    }

    var results: [Result]
}

enum VSMarketplace {
    static func themeJSONURLs(fromMarketplaceURL marketplaceURL: String) -> [URL]? {
        // Valid Marketplace URL
        guard
            let components = URLComponents(string: marketplaceURL),
            components.host == "marketplace.visualstudio.com",
            components.path == "/items",
            components.queryItems?.first(where: { $0.name == "itemName" })?.value != nil
        else {
            return nil
        }

        guard let downloadURL = packageDownloadURL(fromMarketplaceURL: marketplaceURL) else {
            print("Couldn't find package download URL")
            return []
        }

        guard let packagePath = downloadPackage(downloadURL: downloadURL) else {
            print("Couldn't download/extract package")
            return []
        }

        let themesSubdirectory = packagePath.appendingPathComponent("extension").appendingPathComponent("themes")
        let contents = try? FileManager.default.contentsOfDirectory(atPath: themesSubdirectory.path)

        return contents?.compactMap { entry in
            guard entry.lowercased().hasSuffix(".json") else { return nil }
            return themesSubdirectory.appendingPathComponent(entry)
        } ?? []
    }

    static func downloadPackage(downloadURL: String) -> URL? {
        let semaphore = DispatchSemaphore(value: 0)

        var downloadDestinationURL: URL?

        let request = URLRequest(url: URL(string: downloadURL)!)
        let task = URLSession.shared.downloadTask(with: request) { fileURL, urlResponse, error in
            downloadDestinationURL = fileURL
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        guard let downloadedPackageURL = downloadDestinationURL else {
            print("Couldn't download package with URL \(downloadURL)")
            return nil
        }

        let unzipDirectory = downloadedPackageURL.deletingPathExtension().appendingPathComponent("/")

        do {
            try FileManager.default.createDirectory(
                at: unzipDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )

            Zip.addCustomFileExtension("tmp")
            try Zip.unzipFile(
                downloadedPackageURL,
                destination: unzipDirectory,
                overwrite: true,
                password: nil
            )

            return unzipDirectory
        } catch {
            print("Couldn't extract package at URL \(downloadedPackageURL)")
            return nil
        }
    }

    static func packageDownloadURL(fromMarketplaceURL marketplaceURL: String) -> String? {
        let apiURL = URL(string: "https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery")!

        guard
            let components = URLComponents(string: marketplaceURL),
            components.host == "marketplace.visualstudio.com",
            components.path == "/items",
            let itemNameValue = components.queryItems?.first(where: { $0.name == "itemName" })?.value
        else {
            return nil
        }

        let semaphore = DispatchSemaphore(value: 0)

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"

        let requestJSON = """
        {"assetTypes": ["Microsoft.VisualStudio.Services.VSIXPackage"],"filters":[{"criteria":[{"filterType":7,"value":"\(itemNameValue)"}],"direction":2,"pageSize":100,"pageNumber":1,"sortBy":0,"sortOrder":0,"pagingToken":null}],"flags":103}
        """

        request.httpBody = requestJSON.data(using: .utf8)!
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json;api-version=6.1-preview.1;excludeUrls=true", forHTTPHeaderField: "Accept")

        var resultURL: URL?

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                semaphore.signal()
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {
                return
            }

            let responseData = try? JSONDecoder().decode(Response.self, from: data)
            let file = responseData?
                .results.first!
                .extensions.first!
                .versions.first!
                .files.first(where: { $0.assetType == "Microsoft.VisualStudio.Services.VSIXPackage" })

            resultURL = file?.source
        }

        task.resume()

        semaphore.wait()
        
        return resultURL?.absoluteString ?? ""
    }
}
