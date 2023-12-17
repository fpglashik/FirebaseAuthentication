//
//  DummyAuthProvider.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/14/23.
//

import Foundation

class DummyAuthProvider: AuthProvider{
    private let key_SavedLoginUser: String = "LoggedInUser"
    private(set) var inProgress = false
    private let delay: DispatchTimeInterval = DispatchTimeInterval.seconds(1)
    private var user: AuthUser? = nil{
        didSet{
            authUserUpdateDelegate?.authUserDidChange(authUser: user)
        }
    }
    
    var authUserUpdateDelegate: AuthUserUpdateDelegate?
    
    init(){
        retainExistingUser()
//        logout()
    }
    
    func createUser(namePrefix: String, fullName: Bool = false) -> AuthUser{
        let userId = UUID().uuidString
        let userDisplayName = fullName ? namePrefix : "\(namePrefix)\(userId.suffix(3))"
        return AuthUser(id: userId, displayName: userDisplayName)
    }
    
    func loginUser(user: AuthUser) -> Bool{
        let jsonEncoder = JSONEncoder()
        if let userData = try? jsonEncoder.encode(user){
            UserDefaults.standard.set(userData, forKey: key_SavedLoginUser)
            self.user = user
            return true
        }
        
        return false
    }
    
    // MARK: AuthProvider Delegates
    func retainExistingUser(handler: AuthResponseHandler? = nil) {
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        let jsonDecoder = JSONDecoder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            if let savedUserData = UserDefaults.standard.data(forKey: self.key_SavedLoginUser),
               let existingUser = try? jsonDecoder.decode(AuthUser.self, from: savedUserData){
                self.user = existingUser
            }
            self.inProgress = false
            handler?(nil)
        }
    }
    
    func logout(handler: AuthResponseHandler? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            UserDefaults.standard.removeObject(forKey: self.key_SavedLoginUser)
            self.user = nil
            handler?(nil)
        }
    }
}

// MARK: - AnonymousAuthProvider Delegates
extension DummyAuthProvider: AnonymousAuthProvider{
    func loginAnonymously(handler: AuthResponseHandler? = nil) {
        
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
                
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            if self.loginUser(user: self.createUser(namePrefix: "Anonymous_User_")){
                handler?(nil)
            }
            else{
                handler?(.loginFail)
            }
            self.inProgress = false
        }
    }
}

// MARK: - SocialAuthProvider
extension DummyAuthProvider: SocialAuthProvider{
    var supportedSocialOptions: Set<SocialAuthOption> {
        [.apple, .google]
    }
    
    func socialLogin(option: SocialAuthOption, handler: AuthResponseHandler? = nil){
        
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            
            var error: AuthError? = nil
            
            if option == .apple{
                let loginResult = self.loginUser(user: self.createUser(namePrefix: "\(option.name)_User_"))
                
                if loginResult{
                    error = .loginFail
                }
            }
            else{
                error = .other("Login Failed", "\(String(describing: option).capitalized) authentication is not supported yet.")
            }
            self.inProgress = false
            handler?(error)
        }
    }
}

// MARK: - EmailAuthProvider Delegates
extension DummyAuthProvider: EmailAuthProvider{
    func emailPassRegister(displayName: String, email: String, password: String, handler: AuthResponseHandler? = nil) {
        
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            if password == "12345678" && self.loginUser(user: self.createUser(namePrefix: displayName, fullName: true)){
                handler?(nil)
            }
            else{
                handler?(.registrationFail)
            }
            self.inProgress = false
        }
    }
    
    func emailPassLogin(email: String, password: String, handler: AuthResponseHandler? = nil) {
        
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            if password == "12345678" && self.loginUser(user: self.createUser(namePrefix: "Email_User_")){
                handler?(nil)
            }
            else{
                handler?(.loginFail)
            }
            self.inProgress = false
        }
    }
    
    func resetPassword(email: String, handler: AuthResponseHandler? = nil) {
        
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            self.inProgress = false
            handler?(nil)
        }
    }
}

// MARK: - PhoneAuthProvider Delegates
extension DummyAuthProvider: PhoneAuthProvider{
    func phoneRegister(phone: String, handler: AuthResponseHandler? = nil) {
        
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            if phone == "1234567890"{
                handler?(nil)
            }
            else{
                handler?(.registrationFail)
            }
            self.inProgress = false
        }
        
        inProgress = true
    }
    
    func verifyPhoneNumber(code: String, handler: AuthResponseHandler? = nil) {
        
        guard user == nil else{
            handler?(.alreadyLoggedIn)
            return
        }
        guard !inProgress else{
            handler?(.inProgress)
            return
        }
        
        inProgress = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            if code == "1234" && self.loginUser(user: self.createUser(namePrefix: "Phone_User_")){
                handler?(nil)
            }
            else{
                handler?(.codeVerificationFail)
            }
            self.inProgress = false
        }
    }
}
