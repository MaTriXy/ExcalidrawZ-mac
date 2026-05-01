//
//  SearchInspectorContent.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import SwiftUI

import ChocofordUI

/// Inspector content that bridges to Excalidraw's global search.
///
/// UI scaffold only — wire up to `excalidrawWebCoordinator` once the JS-side API lands.
struct SearchInspectorContent: View {
    @EnvironmentObject var fileState: FileState
    @EnvironmentObject var layoutState: LayoutState
    @EnvironmentObject var appPreference: AppPreference

    @State private var query: String = ""

    var body: some View {
#if os(macOS)
        if appPreference.inspectorLayout == .sidebar {
            content()
                .toolbar {
                    InspectorHeaderToolbar(
                        title: "Search",
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
        VStack(alignment: .leading, spacing: 16) {
            searchField

            Divider()

            resultsPlaceholder
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemSymbol: .magnifyingglass)
                .foregroundStyle(.secondary)
            TextField("Search canvas...", text: $query)
                .textFieldStyle(.plain)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemSymbol: .xmarkCircleFill)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
        )
    }

    @ViewBuilder
    private var resultsPlaceholder: some View {
        VStack(spacing: 8) {
            if query.isEmpty {
                Text("Type to search elements on the canvas.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                // TODO: replace with real results once excalidrawZHelper exposes a search API.
                Text("No results")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 24)
    }
}
