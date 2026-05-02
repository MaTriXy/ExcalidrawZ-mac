//
//  ExcalidrawWebView.swift
//  ExcalidrawZ
//
//  Created by Chocoford on 5/2/26.
//

import SwiftUI
import WebKit
import Combine
import Logging
import QuartzCore
import UniformTypeIdentifiers

class ExcalidrawWebView: WKWebView {
    var shouldHandleInput = true
    
    enum ToolbarActionKey {
        case number(Int)
        case char(Character)
        case space, escape
    }
    var toolbarActionHandler: (ToolbarActionKey) -> Void
    
    init(
        frame: CGRect,
        configuration: WKWebViewConfiguration,
        toolbarActionHandler: @escaping (ToolbarActionKey) -> Void
    ) {
        self.toolbarActionHandler = toolbarActionHandler
        super.init(frame: frame, configuration: configuration)
#if canImport(UIKit)
        self.scrollView.isScrollEnabled = false
        self.scrollView.backgroundColor = .clear
#endif
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
#if canImport(UIKit)
    override var safeAreaInsets: UIEdgeInsets { .zero }
#endif
    
#if canImport(AppKit)
    override func keyDown(with event: NSEvent) {
        if shouldHandleInput,
           let char = event.characters {
            if let num = Int(char), num >= 0, num <= 9 {
                self.toolbarActionHandler(.number(num))
            } else if ExcalidrawTool.allCases.compactMap({$0.keyEquivalent}).contains(where: {$0 == Character(char)}), !char.isEmpty {
                self.toolbarActionHandler(.char(Character(char)))
            } else if Character(char) == Character(" ") {
                // TODO: migrate to excalidrawZHelper
                self.toolbarActionHandler(.space)
            } else if Character(char) == Character("q") {
                // TODO: migrate to excalidrawZHelper
                self.toolbarActionHandler(.char("q"))
            } else {
                super.keyDown(with: event)
            }
        } else {
            super.keyDown(with: event)
        }
    }
#endif
}

extension Notification.Name {
    static let forceReloadExcalidrawFile = Notification.Name("ForceReloadExcalidrawFile")
}


/// Minimal wrapper to bridge WKWebView to SwiftUI
struct ExcalidrawViewRepresentable {
    @EnvironmentObject private var core: ExcalidrawCore
    
    func makeExcalidrawWebView(context: Context) -> ExcalidrawWebView {
        return context.coordinator.webView
    }
    
    func updateExcalidrawWebView(_ webView: ExcalidrawWebView, context: Context) {
    }
    
    func makeCoordinator() -> ExcalidrawCore {
        return core
    }
}

#if os(macOS)
extension ExcalidrawViewRepresentable: NSViewRepresentable {
    
    func makeNSView(context: Context) -> ExcalidrawWebView {
        makeExcalidrawWebView(context: context)
    }
    
    func updateNSView(_ nsView: ExcalidrawWebView, context: Context) {
        updateExcalidrawWebView(nsView, context: context)
    }
}
#elseif os(iOS)
extension ExcalidrawViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ExcalidrawWebView {
        makeExcalidrawWebView(context: context)
    }
    
    func updateUIView(_ uiView: ExcalidrawWebView, context: Context) {
        updateExcalidrawWebView(uiView, context: context)
    }
}
#endif
