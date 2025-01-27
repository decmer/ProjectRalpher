//
//  LazyAdapList.swift
//  Ralpher
//
//  Created by Jose Decena on 18/1/25.
//

import SwiftUI

struct LazyAdapList<Content> : View where Content : View {
    var preferredWidth: CGFloat
    var data: () -> Content
    
    init(preferredWidth: CGFloat, data: @escaping () -> Content) {
        self.preferredWidth = preferredWidth + preferredWidth * 0.1
        self.data = data
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let columns = gridCal(for: geometry.size.width)
                LazyVGrid(columns: columns, spacing: calculateSpacing(for: geometry.size.width), content: data)
            }
        }
    }
    
    func gridCal(for screenWidth: CGFloat) -> [GridItem] {
        var gridCalAux = [GridItem]()
        let maxColumns = Int(screenWidth / preferredWidth)
        for _ in 0..<maxColumns {
            gridCalAux.append(.init(.adaptive(minimum: preferredWidth)))
        }
        return gridCalAux
    }
    
    private func calculateSpacing(for screenWidth: CGFloat) -> CGFloat {
        if preferredWidth <= 50 { return 50 }
        if screenWidth < preferredWidth {
            
        }
        let maxColumns = Int(screenWidth / preferredWidth)
        if maxColumns == 1 { return 24 }
        return (screenWidth - CGFloat(maxColumns) * preferredWidth) / CGFloat(maxColumns)
    }
}

#Preview {
    LazyAdapList(preferredWidth: 350) {
        ForEach(Range(1...5), id: \.self) { i in
            Text("Item\(i)")
                .frame(width: 100, height: 100)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}
