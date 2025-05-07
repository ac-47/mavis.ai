//
//  LoginView.swift
//  whisper.swiftui
//
//  Created by RyanAubrey on 4/29/25.
//

import SwiftUI
import GoogleSignInSwift
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to MAVIS")
                .font(.largeTitle)

            Text("Please sign in with Google to continue.")

            GoogleSignInButton(action: {
                authViewModel.signInWithGoogle()
            })
            .frame(height: 50)
            .padding(.horizontal, 50)

            if let errorMessage = authViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top)
            }

            Spacer() 
        }
        .padding()
    }
}
