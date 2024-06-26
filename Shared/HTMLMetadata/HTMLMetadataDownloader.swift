//
//  HTMLMetadataDownloader.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 11/26/17.
//  Copyright © 2017 Ranchero Software. All rights reserved.
//

import Foundation
import Web
import Parser

struct HTMLMetadataDownloader {

	static let serialDispatchQueue = DispatchQueue(label: "HTMLMetadataDownloader")

	@MainActor static func downloadMetadata(for url: String, _ completion: @escaping (RSHTMLMetadata?) -> Void) {
		guard let actualURL = URL(unicodeString: url) else {
			completion(nil)
			return
		}

		downloadUsingCache(actualURL) { (data, response, error) in
			if let data = data, !data.isEmpty, let response = response, response.statusIsOK, error == nil {
				let urlToUse = response.url ?? actualURL
				let parserData = ParserData(url: urlToUse.absoluteString, data: data)
				parseMetadata(with: parserData, completion)
				return
			}

			completion(nil)
		}
	}

	private static func parseMetadata(with parserData: ParserData, _ completion: @escaping (RSHTMLMetadata?) -> Void) {
		serialDispatchQueue.async {
			let htmlMetadata = RSHTMLMetadataParser.htmlMetadata(with: parserData)
			DispatchQueue.main.async {
				completion(htmlMetadata)
			}
		}
	}
}
