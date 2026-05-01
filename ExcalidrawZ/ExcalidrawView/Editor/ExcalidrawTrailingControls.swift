//
//  ExcalidrawTrailingControls.swift
//  ExcalidrawZ
//
//  Created by OpenAI on 2025/2/14.
//

import SwiftUI

import ChocofordUI

struct ExcalidrawTrailingControls: View {
    @Environment(\.containerHorizontalSizeClass) private var containerHorizontalSizeClass

    @EnvironmentObject private var appPreference: AppPreference
    @EnvironmentObject private var layoutState: LayoutState
    @EnvironmentObject private var fileState: FileState

    private var shouldShowFileHistoryButton: Bool {
        fileState.currentActiveFile != nil
    }

    private var shouldShowInspectorButton: Bool {
        if #available(macOS 13.0, iOS 16.0, *),
           appPreference.inspectorLayout == .sidebar {
            return false
        }

        return true
    }

    var body: some View {
        if containerHorizontalSizeClass != .compact,
           shouldShowFileHistoryButton || shouldShowInspectorButton {
            VStack(alignment: .trailing, spacing: 10) {
                if shouldShowFileHistoryButton {
                    FileHistoryButton()
                        .labelStyle(.iconOnly)
                        .modernButtonStyle(style: .glass, shape: .circle)
                }

                if shouldShowInspectorButton {
                    Button {
                        layoutState.isInspectorPresented.toggle()
                    } label: {
                        Label(.localizable(.librariesTitle), systemSymbol: .sidebarRight)
                    }
                    .labelStyle(.iconOnly)
                    .modernButtonStyle(style: .glass, shape: .circle)
                    .help(.localizable(.librariesTitle))
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
    }
}
