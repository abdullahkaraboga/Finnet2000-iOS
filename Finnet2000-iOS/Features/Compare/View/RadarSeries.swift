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
    let values: [Double]   // 0...1 aralığında normalize değerler
    let color: Color
}

struct LegendDot: View {
    let color: Color
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }
}

struct RadarChartView: View {
    let categories: [String]
    let series: [RadarSeries]
    let gridLineCount: Int

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size * 0.40
            let count = categories.count
            let angleStep = 2 * .pi / Double(count)

            ZStack {
                // 🔹 Grid halkaları (arka plan)
                ForEach(1...gridLineCount, id: \.self) { step in
                    let fraction = Double(step) / Double(gridLineCount)
                    PolygonShape(center: center, radius: radius * fraction, sides: count)
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                }

                // 🔹 Eksen çizgileri + Etiketler
                ForEach(0..<count, id: \.self) { i in
                    let angle = angleStep * Double(i) - .pi / 2
                    let end = CGPoint(
                        x: center.x + CGFloat(cos(angle)) * radius,
                        y: center.y + CGFloat(sin(angle)) * radius
                    )

                    Path { path in
                        path.move(to: center)
                        path.addLine(to: end)
                    }
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)

                    let labelOffset: CGFloat = 22
                    let labelPoint = CGPoint(
                        x: center.x + CGFloat(cos(angle)) * (radius + labelOffset),
                        y: center.y + CGFloat(sin(angle)) * (radius + labelOffset)
                    )

                    Text(categories[i])
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.75))
                        .position(labelPoint)
                }

                // 🔹 Seriler (her hisse için alanlar)
                ForEach(series) { s in
                    let clamped = normalize(values: s.values, to: count)
                    RadarPolygon(center: center, radius: radius, values: clamped)
                        .fill(s.color)
                    RadarPolygon(center: center, radius: radius, values: clamped)
                        .stroke(s.color.opacity(0.9), lineWidth: 2)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func normalize(values: [Double], to count: Int) -> [Double] {
        var result = values
        if result.count < count {
            result.append(contentsOf: Array(repeating: 0, count: count - result.count))
        }
        if result.count > count {
            result = Array(result.prefix(count))
        }
        return result.map { max(0, min(1, $0)) }
    }
}

// MARK: - Shapes

struct PolygonShape: Shape {
    let center: CGPoint
    let radius: CGFloat
    let sides: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard sides > 2 else { return path }
        let step = 2 * .pi / Double(sides)

        for i in 0..<sides {
            let angle = Double(i) * step - .pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarPolygon: Shape {
    let center: CGPoint
    let radius: CGFloat
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard values.count > 2 else { return path }
        let step = 2 * .pi / Double(values.count)

        for i in 0..<values.count {
            let angle = Double(i) * step - .pi / 2
            let r = radius * CGFloat(values[i])
            let x = center.x + CGFloat(cos(angle)) * r
            let y = center.y + CGFloat(sin(angle)) * r
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}
