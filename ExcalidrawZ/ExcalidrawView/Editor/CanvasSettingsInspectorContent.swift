//
//  CanvasSettingsInspectorContent.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import SwiftUI

import ChocofordUI

/// Inspector content showing per-canvas settings: select mode, view modes, snap behavior, etc.
///
/// UI scaffolding only. The toggles use `@State` placeholders — the real source of truth
/// is the active file's Excalidraw `appState`. Wire them through `ExcalidrawCore` later.
struct CanvasSettingsInspectorContent: View {
    @EnvironmentObject var fileState: FileState
    @EnvironmentObject var layoutState: LayoutState
    @EnvironmentObject var appPreference: AppPreference

    enum SelectionMode: String, CaseIterable, Identifiable {
        case wrap
        case overlap
        var id: String { rawValue }
    }

    @State private var selectionMode: SelectionMode = .wrap

    @State private var toolLockEnabled: Bool = false
    @State private var stickToObjectsEnabled: Bool = false
    @State private var gridEnabled: Bool = false
    @State private var zenModeEnabled: Bool = false
    @State private var viewModeEnabled: Bool = false
    @State private var shapePropertiesPanelEnabled: Bool = false

    @State private var arrowBindingEnabled: Bool = true
    @State private var snapToMidpointsEnabled: Bool = true

    var body: some View {
#if os(macOS)
        if appPreference.inspectorLayout == .sidebar {
            content()
                .toolbar {
                    InspectorHeaderToolbar(
                        title: "Canvas",
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
    private var selectModeRow: some View {
        HStack {
            Text("Select on")
            Spacer()
            Picker("Select on", selection: $selectionMode) {
                Text("Wrap").tag(SelectionMode.wrap)
                Text("Overlap").tag(SelectionMode.overlap)
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
            toggleRow("Tool lock", shortcut: "Q", isOn: $toolLockEnabled)
            toggleRow("Stick to objects", shortcut: "⌥S", isOn: $stickToObjectsEnabled)
            toggleRow("Toggle grid", shortcut: "⌘'", isOn: $gridEnabled)
            toggleRow("Zen mode", shortcut: "⌥Z", isOn: $zenModeEnabled)
            toggleRow("View mode", shortcut: "⌥R", isOn: $viewModeEnabled)
            toggleRow("Canvas & shape properties", shortcut: "⌥/", isOn: $shapePropertiesPanelEnabled)
        }
    }

    @ViewBuilder
    private var plainToggles: some View {
        VStack(alignment: .leading, spacing: 8) {
            toggleRow("Arrow binding", shortcut: nil, isOn: $arrowBindingEnabled)
            toggleRow("Snap to midpoints", shortcut: nil, isOn: $snapToMidpointsEnabled)
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
}
