//
//  CanvasPreferencesState.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import SwiftUI

/// Mirror of the canvas-level preferences exposed by `excalidrawZHelper`.
///
/// Web is the source of truth. Inbound updates arrive via `apply(_:)` (called from the
/// `onCanvasPreferencesChanged` handler). Outbound updates fire automatically on `didSet` —
/// any change to a field pushes a partial update to `coordinator.setCanvasPreferences`.
///
/// The `isApplyingFromWeb` guard breaks the web → apply → didSet → web echo loop. It works
/// because `apply()` is synchronous on main, so each `didSet` runs while the flag is still set.
@MainActor
final class CanvasPreferencesState: ObservableObject {
    enum Theme: String, Codable, Hashable {
        case light
        case dark
    }

    enum BindingPreference: String, Codable, Hashable {
        case enabled
        case disabled
    }

    enum PreferredSelectionTool: String, Codable, Hashable {
        case selection
        case lasso
    }

    /// Set by `ExcalidrawCanvasView.setupCoordinators` once the engine is ready.
    weak var coordinator: ExcalidrawCore?

    private var isApplyingFromWeb = false

    @Published var theme: Theme = .light {
        didSet { pushField { $0.theme = theme } }
    }
    @Published var viewBackgroundColor: String = "#ffffff" {
        didSet { pushField { $0.viewBackgroundColor = viewBackgroundColor } }
    }
    @Published var gridModeEnabled: Bool = false {
        didSet { pushField { $0.gridModeEnabled = gridModeEnabled } }
    }
    @Published var zenModeEnabled: Bool = false {
        didSet { pushField { $0.zenModeEnabled = zenModeEnabled } }
    }
    @Published var viewModeEnabled: Bool = false {
        didSet { pushField { $0.viewModeEnabled = viewModeEnabled } }
    }
    @Published var objectsSnapModeEnabled: Bool = false {
        didSet { pushField { $0.objectsSnapModeEnabled = objectsSnapModeEnabled } }
    }
    @Published var isMidpointSnappingEnabled: Bool = true {
        didSet { pushField { $0.isMidpointSnappingEnabled = isMidpointSnappingEnabled } }
    }
    @Published var bindingPreference: BindingPreference = .enabled {
        didSet { pushField { $0.bindingPreference = bindingPreference } }
    }
    @Published var preferredSelectionTool: PreferredSelectionTool = .selection {
        didSet { pushField { $0.preferredSelectionTool = preferredSelectionTool } }
    }
    @Published var stats: Bool = false {
        didSet { pushField { $0.stats = stats } }
    }

    /// Apply a partial diff (from `onCanvasPreferencesChanged`) or a full snapshot.
    /// Suppresses the per-field didSet push for the duration.
    func apply(_ snapshot: CanvasPreferencesSnapshot) {
        isApplyingFromWeb = true
        defer { isApplyingFromWeb = false }
        if let value = snapshot.theme { theme = value }
        if let value = snapshot.viewBackgroundColor { viewBackgroundColor = value }
        if let value = snapshot.gridModeEnabled { gridModeEnabled = value }
        if let value = snapshot.zenModeEnabled { zenModeEnabled = value }
        if let value = snapshot.viewModeEnabled { viewModeEnabled = value }
        if let value = snapshot.objectsSnapModeEnabled { objectsSnapModeEnabled = value }
        if let value = snapshot.isMidpointSnappingEnabled { isMidpointSnappingEnabled = value }
        if let value = snapshot.bindingPreference { bindingPreference = value }
        if let value = snapshot.preferredSelectionTool { preferredSelectionTool = value }
        if let value = snapshot.stats { stats = value }
    }

    private func pushField(_ build: (inout CanvasPreferencesSnapshot) -> Void) {
        guard !isApplyingFromWeb else { return }
        var update = CanvasPreferencesSnapshot()
        build(&update)
        let coordinator = self.coordinator
        Task {
            try? await coordinator?.setCanvasPreferences(update)
        }
    }
}

/// All-optional payload shared by the inbound diff event and the outbound partial-update call.
/// Only non-nil fields are encoded — matching the partial-update contract on the JS side.
struct CanvasPreferencesSnapshot: Codable {
    var theme: CanvasPreferencesState.Theme?
    var viewBackgroundColor: String?
    var gridModeEnabled: Bool?
    var zenModeEnabled: Bool?
    var viewModeEnabled: Bool?
    var objectsSnapModeEnabled: Bool?
    var isMidpointSnappingEnabled: Bool?
    var bindingPreference: CanvasPreferencesState.BindingPreference?
    var preferredSelectionTool: CanvasPreferencesState.PreferredSelectionTool?
    var stats: Bool?

    enum CodingKeys: String, CodingKey {
        case theme
        case viewBackgroundColor
        case gridModeEnabled
        case zenModeEnabled
        case viewModeEnabled
        case objectsSnapModeEnabled
        case isMidpointSnappingEnabled
        case bindingPreference
        case preferredSelectionTool
        case stats
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(theme, forKey: .theme)
        try container.encodeIfPresent(viewBackgroundColor, forKey: .viewBackgroundColor)
        try container.encodeIfPresent(gridModeEnabled, forKey: .gridModeEnabled)
        try container.encodeIfPresent(zenModeEnabled, forKey: .zenModeEnabled)
        try container.encodeIfPresent(viewModeEnabled, forKey: .viewModeEnabled)
        try container.encodeIfPresent(objectsSnapModeEnabled, forKey: .objectsSnapModeEnabled)
        try container.encodeIfPresent(isMidpointSnappingEnabled, forKey: .isMidpointSnappingEnabled)
        try container.encodeIfPresent(bindingPreference, forKey: .bindingPreference)
        try container.encodeIfPresent(preferredSelectionTool, forKey: .preferredSelectionTool)
        try container.encodeIfPresent(stats, forKey: .stats)
    }
}
