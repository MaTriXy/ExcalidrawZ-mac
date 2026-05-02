//
//  ExcalidrawCore+Search.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import Foundation

/// One match returned by `excalidrawZHelper.searchElements`.
struct SearchResult: Codable, Hashable, Identifiable {
    let elementId: String
    let elementType: ElementType
    let matchIndex: Int
    let matchLength: Int
    let preview: Preview

    /// Frames and text elements are the only thing the JS side searches today.
    enum ElementType: String, Codable, Hashable {
        case text
        case frame
    }

    /// Context window around the match for the host to render.
    struct Preview: Codable, Hashable {
        let text: String
        let matchStart: Int
        let matchLength: Int
        let moreBefore: Bool
        let moreAfter: Bool
    }

    /// One element can have several matches in its text — combine both for stable identity.
    var id: String { "\(elementId)_\(matchIndex)" }
}

extension ExcalidrawCore {
    /// Run a search and (Plan B) highlight matches on the canvas in the same call.
    @MainActor
    func searchElements(
        query: String,
        highlightOnCanvas: Bool = true,
        caseSensitive: Bool = true
    ) async throws -> [SearchResult] {
        guard !self.isLoading else { return [] }
        let queryJSON = try query.jsonStringified()
        let optsJSON = try SearchOptions(
            highlightOnCanvas: highlightOnCanvas,
            caseSensitive: caseSensitive
        ).jsonStringified()
        let script = "window.excalidrawZHelper.searchElements(\(queryJSON), \(optsJSON))"
        let result = try await webView.evaluateJavaScript(script)
        guard let array = result as? [Any] else { return [] }
        let data = try JSONSerialization.data(withJSONObject: array)
        return try JSONDecoder().decode([SearchResult].self, from: data)
    }

    @MainActor
    func clearCanvasHighlights() async throws {
        guard !self.isLoading else { return }
        try await webView.evaluateJavaScript("window.excalidrawZHelper.clearCanvasHighlights(); 0;")
    }

    /// Pan + select the matched element (the JS side defaults the element to ~50% of viewport).
    @MainActor
    func focusSearchResult(elementId: String) async throws {
        guard !self.isLoading else { return }
        let elementIdJSON = try elementId.jsonStringified()
        try await webView.evaluateJavaScript("window.excalidrawZHelper.focusSearchResult(\(elementIdJSON)); 0;")
    }
}

private struct SearchOptions: Encodable {
    let highlightOnCanvas: Bool
    let caseSensitive: Bool
}
