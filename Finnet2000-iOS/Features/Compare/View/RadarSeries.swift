//
//  RadarChartView.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import SwiftUI

struct RadarSeries: Identifiable {
    let id = UUID()
    let name: String
    let values: [Double]   // 0...1 arasında normalize değerler
    let color: Color
}

struct RadarChartView: View {
    let categories: [String]
    let series: [RadarSeries]
    let gridLineCount: Int

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size * 0.38
            let count = max(categories.count, 3)
            let angleStep = 2.0 * .pi / Double(count)

            ZStack {
                // Grid halkaları
                ForEach(1...max(gridLineCount, 3), id: \.self) { step in
                    let fraction = Double(step) / Double(max(gridLineCount, 3))
                    PolygonPath(center: center, radius: radius * fraction, vertexCount: count)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                }

                // Eksen çizgileri + Etiketler
                ForEach(0..<count, id: \.self) { i in
                    let angle = angleStep * Double(i) - .pi / 2
                    let end = CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                                      y: center.y + CGFloat(sin(angle)) * radius)

                    Path { path in
                        path.move(to: center)
                        path.addLine(to: end)
                    }
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)

                    let labelOffset: CGFloat = 18
                    let labelPoint = CGPoint(x: center.x + CGFloat(cos(angle)) * (radius + labelOffset),
                                             y: center.y + CGFloat(sin(angle)) * (radius + labelOffset))

                    Text(categories[i % categories.count])
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .position(labelPoint)
                }

                // Seriler
                ForEach(series) { s in
                    let clampedValues = normalize(values: s.values, toCount: count)
                    RadarPolygonPath(center: center, radius: radius, values: clampedValues)
                        .fill(s.color)
                    RadarPolygonPath(center: center, radius: radius, values: clampedValues)
                        .stroke(s.color.opacity(0.9), lineWidth: 2)
                }
            }
        }
    }

    private func normalize(values: [Double], toCount count: Int) -> [Double] {
        var result = values
        if result.count < count {
            result.append(contentsOf: Array(repeating: 0.0, count: count - result.count))
        } else if result.count > count {
            result = Array(result.prefix(count))
        }
        return result.map { max(0.0, min(1.0, $0)) }
    }
}

struct PolygonPath: Shape {
    let center: CGPoint
    let radius: CGFloat
    let vertexCount: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard vertexCount > 2 else { return path }
        let angleStep = 2.0 * .pi / Double(vertexCount)
        for i in 0..<vertexCount {
            let angle = angleStep * Double(i) - .pi / 2
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                                y: center.y + CGFloat(sin(angle)) * radius)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarPolygonPath: Shape {
    let center: CGPoint
    let radius: CGFloat
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let count = values.count
        guard count > 2 else { return path }
        let angleStep = 2.0 * .pi / Double(count)

        for i in 0..<count {
            let angle = angleStep * Double(i) - .pi / 2
            let r = radius * CGFloat(values[i])
            let point = CGPoint(x: center.x + CGFloat(cos(angle)) * r,
                                y: center.y + CGFloat(sin(angle)) * r)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
