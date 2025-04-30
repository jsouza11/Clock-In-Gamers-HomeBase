//
//  InputView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/28/25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField: Bool = false
    var textContentType: UITextContentType? = .none
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)

            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .autocapitalization(.none)
                    .textContentType(textContentType)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .textContentType(textContentType)
            }

            Divider()
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com", textContentType: .emailAddress)
    }
}
