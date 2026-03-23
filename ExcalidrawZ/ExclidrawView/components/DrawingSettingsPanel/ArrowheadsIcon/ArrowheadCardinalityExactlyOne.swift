//
//  ArrowheadCardinalityExactlyOne.swift
//  ExcalidrawZ
//
//  Created by Codex on 8/10/25.
//

import SwiftUI

struct ArrowheadCardinalityExactlyOne: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height

        path.move(to: CGPoint(x: 0.85 * width, y: 0.5 * height))
        path.addLine(to: CGPoint(x: 0.15 * width, y: 0.5 * height))

        path.move(to: CGPoint(x: 0.85 * width, y: 0.25 * height))
        path.addLine(to: CGPoint(x: 0.85 * width, y: 0.75 * height))

        path.move(to: CGPoint(x: 0.65 * width, y: 0.25 * height))
        path.addLine(to: CGPoint(x: 0.65 * width, y: 0.75 * height))

        return path
    }
}
