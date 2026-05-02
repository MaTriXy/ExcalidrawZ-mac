//
//  ExcalidrawCore+CanvasPreferences.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import Foundation

extension ExcalidrawCore {
    /// Push a partial update to the canvas preferences. Only non-nil fields on `update` are sent.
    @MainActor
    func setCanvasPreferences(_ update: CanvasPreferencesSnapshot) async throws {
        guard !self.isLoading else { return }
        let payload = try update.jsonStringified()
        try await webView.evaluateJavaScript("window.excalidrawZHelper.setCanvasPreferences(\(payload)); 0;")
    }

    /// Fetch the current full canvas preferences snapshot from the web side.
    @MainActor
    func fetchCanvasPreferences() async throws -> CanvasPreferencesSnapshot? {
        guard !self.isLoading else { return nil }
        let result = try await webView.evaluateJavaScript("window.excalidrawZHelper.getCanvasPreferences()")
        guard let dict = result as? [String: Any] else { return nil }
        let data = try JSONSerialization.data(withJSONObject: dict)
        return try JSONDecoder().decode(CanvasPreferencesSnapshot.self, from: data)
    }
}
