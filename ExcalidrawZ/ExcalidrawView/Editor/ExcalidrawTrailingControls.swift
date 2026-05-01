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

    @EnvironmentObject private var layoutState: LayoutState
    @EnvironmentObject private var fileState: FileState

    var body: some View {
        if containerHorizontalSizeClass != .compact {
            VStack(alignment: .trailing, spacing: 10) {
                Button {
                    layoutState.isInspectorPresented.toggle()
                } label: {
                    Label(.localizable(.librariesTitle), systemSymbol: .book)
                }
                .labelStyle(.iconOnly)
                .modernButtonStyle(style: .glass, size: .extraLarge, shape: .circle)
                .help(.localizable(.librariesTitle))
                .keyboardShortcut("0", modifiers: [.command, .option])
                
                FileHistoryButton()
                    .labelStyle(.iconOnly)
                    .modernButtonStyle(style: .glass, size: .extraLarge, shape: .circle)
            }
            .padding(.top, 16)
            .padding(.trailing, 8)
        }
    }
}
