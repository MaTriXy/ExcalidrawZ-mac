//
//  ArrowheadCardinalityZeroOrMany.swift
//  ExcalidrawZ
//
//  Created by Codex on 8/10/25.
//

import SwiftUI

struct ArrowheadCardinalityZeroOrMany: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        let radius = min(width, height) * 0.12
        let center = CGPoint(x: 0.35 * width, y: 0.5 * height)

        path.move(to: CGPoint(x: 0.85 * width, y: 0.5 * height))
        path.addLine(to: CGPoint(x: 0.15 * width, y: 0.5 * height))

        path.addEllipse(
            in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )
        )

        path.move(to: CGPoint(x: 0.58 * width, y: 0.5 * height))
        path.addLine(to: CGPoint(x: 0.78 * width, y: 0.25 * height))

        path.move(to: CGPoint(x: 0.58 * width, y: 0.5 * height))
        path.addLine(to: CGPoint(x: 0.78 * width, y: 0.75 * height))

        return path
    }
}
