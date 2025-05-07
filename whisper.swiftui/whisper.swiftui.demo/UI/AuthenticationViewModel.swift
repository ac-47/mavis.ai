//
//  LoginView.swift
//  whisper.swiftui
//
//  Created by RyanAubrey on 4/29/25.
//


import Foundation
import FirebaseAuth
import GoogleSignIn
import SwiftUI
import FirebaseCore

@MainActor
class AuthenticationViewModel: ObservableObject {

    @Published var isSignedIn: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentUserName: String? = nil

    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {        addAuthStateListener()
    }

    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
            print("Auth state listener removed.")
        }
    }

    func addAuthStateListener() {
        if authStateHandler != nil { return }

        authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
            self.isSignedIn = (user != nil)
            self.currentUserName = user?.displayName ?? user?.email
            print("Auth State Changed: Signed In = \(self.isSignedIn)")
            if user == nil {
                self.errorMessage = nil
            }
        }
    }

    func signInWithGoogle() {
        print("Attempting Google Sign-In...")
        errorMessage = nil

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Firebase client ID not found."
            print("Error: \(errorMessage!)")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let presentingViewController = UIApplication.shared.getRootViewController() else {
            errorMessage = "Could not find root VC to present sign-in."
            print("Error: \(errorMessage!)")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
             DispatchQueue.main.async {
                guard let self = self else { return }

                guard error == nil else {
                    self.errorMessage = "Google Sign-In Error: \(error!.localizedDescription)"
                    print(self.errorMessage!)
                    return
                }

                guard let user = signInResult?.user, let idToken = user.idToken?.tokenString else {
                    self.errorMessage = "Google Sign-In Error: Missing ID token."
                    print(self.errorMessage!)
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)

                print("Attempting Firebase sign-in...")
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.errorMessage = "Firebase Sign-In Error: \(error.localizedDescription)"
                         print(self.errorMessage!)
                    } else {
                        print("Firebase sign-in successful.")
                        self.errorMessage = nil
                    }
                }
            }
        }
    }

    func signOut() {
        print("Attempting Sign Out...")
        errorMessage = nil
         let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance.signOut()
            print("Successfully signed out.")
            // Listener will update state
        } catch let signOutError as NSError {
             print("Error signing out: %@", signOutError)
             errorMessage = signOutError.localizedDescription
        }
    }
}


extension UIApplication {
    func getRootViewController() -> UIViewController? {
        guard let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return nil }
        var keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        if keyWindow == nil { keyWindow = windowScene.windows.first }
        guard let rootVC = keyWindow?.rootViewController else { return nil }
        var topController = rootVC
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        if let navController = topController as? UINavigationController {
             return navController.topViewController ?? topController
        }
        return topController
    }
}
