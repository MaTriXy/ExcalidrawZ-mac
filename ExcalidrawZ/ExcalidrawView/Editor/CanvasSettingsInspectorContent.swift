//
//  CanvasSettingsInspectorContent.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import SwiftUI

import ChocofordUI

/// Inspector content for canvas-level preferences. Bindings drive `CanvasPreferencesState`
/// directly — its per-field `didSet` pushes partial updates to the web side.
struct CanvasSettingsInspectorContent: View {
    @EnvironmentObject var fileState: FileState
    @EnvironmentObject var layoutState: LayoutState
    @EnvironmentObject var appPreference: AppPreference
    @EnvironmentObject var canvasPrefs: CanvasPreferencesState

    /// Tool lock isn't part of canvas preferences — it's still driven by `toggleToolbarAction("Q")`.
    @State private var toolLockEnabled: Bool = false

    var body: some View {
#if os(macOS)
        if appPreference.inspectorLayout == .sidebar {
            content()
                .toolbar {
                    InspectorHeaderToolbar(
                        title: "Preference",
                        isInspectorPresented: layoutState.isInspectorPresented
                    )
                }
        } else {
            content()
        }
#else
        content()
#endif
    }

    @ViewBuilder
    private func content() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                canvasBackgroundRow

                Divider()

                selectModeRow

                Divider()

                shortcutToggles

                Divider()

                plainToggles
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var canvasBackgroundRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Canvas background")
            ColorButtonGroup(
                colors: ColorPalette.canvasBackgroundQuickPicks,
                selectedColor: canvasPrefs.viewBackgroundColor
            ) { color in
                canvasPrefs.viewBackgroundColor = color
            }
        }
    }

    @ViewBuilder
    private var selectModeRow: some View {
        HStack {
            Text("Select on")
            Spacer()
            Picker("Select on", selection: $canvasPrefs.boxSelectionMode) {
                Text("Wrap").tag(CanvasPreferencesState.BoxSelectionMode.contain)
                Text("Overlap").tag(CanvasPreferencesState.BoxSelectionMode.overlap)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            .modernButtonStyle(style: .glass, size: .regular, shape: .capsule)
        }
    }

    @ViewBuilder
    private var shortcutToggles: some View {
        VStack(alignment: .leading, spacing: 8) {
            toggleRow("Tool lock", shortcut: "Q", isOn: toolLockBinding)
            toggleRow("Stick to objects", shortcut: "⌥S", isOn: $canvasPrefs.objectsSnapModeEnabled)
            toggleRow("Toggle grid", shortcut: "⌘'", isOn: $canvasPrefs.gridModeEnabled)
            toggleRow("Zen mode", shortcut: "⌥Z", isOn: $canvasPrefs.zenModeEnabled)
            toggleRow("View mode", shortcut: "⌥R", isOn: $canvasPrefs.viewModeEnabled)
            toggleRow("Canvas & shape properties", shortcut: "⌥/", isOn: $canvasPrefs.stats)
        }
    }

    @ViewBuilder
    private var plainToggles: some View {
        VStack(alignment: .leading, spacing: 8) {
            toggleRow("Arrow binding", shortcut: nil, isOn: bindingPreferenceBinding)
            toggleRow("Snap to midpoints", shortcut: nil, isOn: $canvasPrefs.isMidpointSnappingEnabled)
        }
    }

    @ViewBuilder
    private func toggleRow(_ title: String, shortcut: String?, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack {
                Text(title)
                Spacer()
                if let shortcut {
                    if #available(macOS 13.0, *) {
                        Text(shortcut)
                            .foregroundStyle(.secondary)
                            .monospaced()
                    } else {
                        Text(shortcut)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .toggleStyle(.switch)
    }

    // MARK: - UI-only Bindings

    /// Arrow binding: enum on the wire, Bool in the UI.
    private var bindingPreferenceBinding: Binding<Bool> {
        Binding(
            get: { canvasPrefs.bindingPreference == .enabled },
            set: { canvasPrefs.bindingPreference = $0 ? .enabled : .disabled }
        )
    }

    /// Tool lock: not in canvas preferences — uses the toolbar action shortcut "Q".
    private var toolLockBinding: Binding<Bool> {
        Binding(
            get: { toolLockEnabled },
            set: { newValue in
                toolLockEnabled = newValue
                Task {
                    try? await fileState.excalidrawWebCoordinator?.toggleToolbarAction(key: Character("q"))
                }
            }
        )
    }

}
