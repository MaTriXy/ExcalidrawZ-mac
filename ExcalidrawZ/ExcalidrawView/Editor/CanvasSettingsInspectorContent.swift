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
                        title: String(localizable: .canvasPreferencesTitle),
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
            Text(localizable: .canvasPreferencesCanvasBackgroundTitle)
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
            Text(localizable: .canvasPreferencesSelectOnTitle)
            Spacer()
            Picker(
                String(localizable: .canvasPreferencesSelectOnTitle),
                selection: $canvasPrefs.boxSelectionMode
            ) {
                Text(
                    localizable: .canvasPreferencesSelectOnOptionWrap
                ).tag(CanvasPreferencesState.BoxSelectionMode.contain)
                Text(
                    localizable: .canvasPreferencesSelectOnOptionOverlap
                ).tag(CanvasPreferencesState.BoxSelectionMode.overlap)
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
            toggleRow(
                String(localizable: .canvasPreferencesToolLockTitle),
                shortcut: "Q",
                isOn: toolLockBinding
            )
            toggleRow(
                String(localizable: .canvasPreferencesSnapToMidpointsTitle),
                shortcut: "⌥S",
                isOn: $canvasPrefs.objectsSnapModeEnabled
            )
            toggleRow(
                String(localizable: .canvasPreferencesToggleGridTitle),
                shortcut: "⌘'",
                isOn: $canvasPrefs.gridModeEnabled
            )
            toggleRow(
                String(localizable: .canvasPreferencesZenModeTitle),
                shortcut: "⌥Z",
                isOn: $canvasPrefs.zenModeEnabled
            )
            toggleRow(
                String(localizable: .canvasPreferencesViewModeTitle),
                shortcut: "⌥R",
                isOn: $canvasPrefs.viewModeEnabled
            )
            toggleRow(
                String(localizable: .canvasPreferencesStatesTitle),
                shortcut: "⌥/",
                isOn: $canvasPrefs.stats
            )
        }
    }

    @ViewBuilder
    private var plainToggles: some View {
        VStack(alignment: .leading, spacing: 8) {
            toggleRow(
                String(localizable: .canvasPreferencesArrowBindingTitle),
                shortcut: nil,
                isOn: bindingPreferenceBinding
            )
            toggleRow(
                String(localizable: .canvasPreferencesSnapToMidpointsTitle),
                shortcut: nil,
                isOn: $canvasPrefs.isMidpointSnappingEnabled
            )
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
