//
//  LoginInput.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI

struct LoginInput: View {
    @Binding var mail: String
    @Binding var password: String
    
    var body: some View {
        VStack {
            TextField("Mail", text: $mail)
            Divider()
            SecureField("password", text: $password)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    LoginInput(mail: .constant(""), password: .constant(""))
}
