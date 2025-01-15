//
//  SignupInput.swift
//  PruebaPosgree
//
//  Created by Jose Decena on 11/12/24.
//

import SwiftUI

struct SignupInput: View {
    @Binding var mail: String
    @Binding var password: String
    @Binding var confirmPassword: String
    
    var body: some View {
        
        TextField("Mail", text: $mail)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.gray.opacity(0.1))
            }
        VStack {
            SecureField("password", text: $password)
            Divider()
            SecureField("confirm password", text: $confirmPassword)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    SignupInput(mail: .constant(""), password: .constant(""), confirmPassword: .constant(""))
}
