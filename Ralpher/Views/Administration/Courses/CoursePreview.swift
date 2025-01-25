//
//  CoursePreview.swift
//  Ralpher
//
//  Created by Jose Decena on 25/1/25.
//

import SwiftUI

struct CoursePreview: View {
    let course: CourseModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(course.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

#Preview {
    CoursePreview(course: .init(name: "mi curso de prueba"))
}
