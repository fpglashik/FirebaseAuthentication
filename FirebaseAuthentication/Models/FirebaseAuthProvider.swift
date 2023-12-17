//
//  FirebaseAuthProvider.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/18/23.
//

import FirebaseAuth

class FirebaseAuthProvider: AuthProvider{

    private var firebaseAuthStateListener: AuthStateDidChangeListenerHandle?
    private(set) var inProgress = false

    private var firebaseUser: User?{
        didSet{
            var authUser: AuthUser? = nil
            if let firebaseUser{
                authUser = AuthUser(id: firebaseUser.uid, displayName: firebaseUser.displayName ?? AuthUser.defaultDisplayName)
            }
            
            authUserUpdateDelegate?.authUserDidChange(authUser: authUser)
        }
    }
    
    var authUserUpdateDelegate: AuthUserUpdateDelegate?
    
    init(){
        retainExistingUser()
//        logout()
    }
    
    // MARK: AuthProvider Delegates
    func retainExistingUser(handler: AuthResponseHandler? = nil) {
        inProgress = true
        firebaseAuthStateListener = Auth.auth().addStateDidChangeListener {auth, user in
            self.firebaseUser = user
            self.inProgress = false
        }
    }
    
    func logout(handler: AuthResponseHandler? = nil) {
        guard firebaseUser != nil else{
            handler?(.notLoggedIn)
            return
        }
        
        do{
            try Auth.auth().signOut()
            handler?(nil)
        }
        catch{
            handler?(.logoutFail)
        }
    }
}

// MARK: - AnonymousAuthProvider Delegates
extension FirebaseAuthProvider: AnonymousAuthProvider{
    func loginAnonymously(handler: AuthResponseHandler? = nil) {
        guard Auth.auth().currentUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            if let error{
                handler?(.other("Login Failed", error.localizedDescription))
            }
            else{
                self?.firebaseUser = authResult?.user
                handler?(nil)
            }
            self?.inProgress = false
        }
    }
}

// MARK: - SocialAuthProvider
extension FirebaseAuthProvider: SocialAuthProvider{
    var supportedSocialOptions: Set<SocialAuthOption> {
        [.apple, .google]
    }
    
    func socialLogin(option: SocialAuthOption, handler: AuthResponseHandler? = nil){
        
        guard firebaseUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            handler?(.other("Login Failed", "\(option.name) login is not supported yet."))
            self.inProgress = false
        }
    }
}

// MARK: - SocialAuthProvider
extension FirebaseAuthProvider: EmailAuthProvider{
    func emailPassRegister(displayName: String, email: String, password: String, handler: AuthResponseHandler? = nil) {
        
        guard firebaseUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        Auth.auth().createUser(withEmail: email, password: password) {[weak self]  authResult, error in
            
            if let error{
                handler?(.other("Registration Failed", error.localizedDescription))
                self?.inProgress = false
            }
            else if let fbUser = authResult?.user{
                
                let changeRequest = fbUser.createProfileChangeRequest()
                changeRequest.displayName = displayName
                
                
                changeRequest.commitChanges { nameChangeError in
                    self?.firebaseUser = fbUser
                    var authError: AuthError? = nil
                    
                    if let _ = nameChangeError{
                        authError = .other("Name Change Failed", "Registration completed successfully. However display name couldn't be saved.")
                    }
                    self?.firebaseUser = fbUser
                    self?.inProgress = false
                    handler?(authError)
                }
            }
            else{
                handler?(.registrationFail)
                self?.inProgress = false
            }
        }
    }
    
    func emailPassLogin(email: String, password: String, handler: AuthResponseHandler? = nil) {
        
        guard firebaseUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                        
            if let error{
                handler?(.other("Login Failed", error.localizedDescription))
                self?.inProgress = false
            }
            else{
                self?.firebaseUser = authResult?.user
                handler?(nil)
                self?.inProgress = false
            }
        }
    }
    
    func resetPassword(email: String, handler: AuthResponseHandler? = nil) {
        
        guard firebaseUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            var authError: AuthError? = nil
            if let error{
                authError = .other("Password Reset Failed", error.localizedDescription)
            }
            handler?(authError)
            self?.inProgress = false
        }
    }
}

// MARK: - PhoneAuthProvider Delegates
extension FirebaseAuthProvider: PhoneAuthProvider{

    func phoneRegister(phone: String, handler: AuthResponseHandler? = nil) {
        
        guard firebaseUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        FirebaseAuth.PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil){[weak self] verificationID, error in
            
            var authError: AuthError? = nil
            if let error{
                authError = .other("Login Failed", error.localizedDescription)
            }
            else{
                UserDefaults.standard.set(verificationID, forKey: "PhoneUserVerificationID")
            }
            
            handler?(authError)
            self?.inProgress = false
        }
    }
    
    func verifyPhoneNumber(code: String, handler: AuthResponseHandler? = nil) {
        
        guard firebaseUser == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        guard let verificationID = UserDefaults.standard.string(forKey: "PhoneUserVerificationID") else{
            handler?(.other("Code Verification Failed", "SMS code verification failed. Please try again later"))
            return
        }
        
        let credential = FirebaseAuth.PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        
        Auth.auth().signIn(with: credential) {[weak self] authResult, error in
            
            if let error{
                handler?(.other("Login Failed", error.localizedDescription))
                self?.inProgress = false
            }
            else{
                self?.firebaseUser = authResult?.user
                handler?(nil)
                self?.inProgress = false
            }
        }
    }
    
}
