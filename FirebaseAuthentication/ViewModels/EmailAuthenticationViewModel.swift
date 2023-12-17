//
//  EmailAuthenticationViewModel.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/15/23.
//


import Foundation

enum EmailAuthState: Equatable, Identifiable{
    var id: String{
        action
    }
    
    case login
    case register
    case passwordReset
    
    var instruction: String{
        switch self{
        case .login: return "Use your email and password to login"
        case .register: return "Enter a name, email and password to register"
        case .passwordReset: return "Enter your registered email address"
        }
    }
    
    var action: String{
        switch self{
        case .login: return "Login"
        case .register: return "Register"
        case .passwordReset: return "Reset"
        }
    }
    
    var secondaryAction: String{
        switch self{
        case .login: return "Login Here"
        case .register: return "Register Here"
        case .passwordReset: return "Reset Here"
        }
    }
    
    var question: String{
        switch self{
        case .login: return "Already Registered?"
        case .register: return "Not Registered Yet?"
        case .passwordReset: return "Forgot Password?"
        }
    }
    
    var nextStates: [EmailAuthState]{
        switch self{
        case .login: return [.register, .passwordReset]
        case .register: return [.login]
        case .passwordReset: return [.login]
        }
    }
}

struct ValidationMessages {
    static let TitleFor_DisplayName = "Invalid Display Name"
    static let TitleFor_Email = "Invalid Email"
    static let TitleFor_Password = "Password Too Short"
    static let TitleFor_VerificationCode = "Invalid Verification Code"
    
    static let MessageFor_DisplayName = "Display name must be between 3 to 10 characters long."
    static let MessageFor_Email = "Email address is invalid. Enter a correct one."
    static let MessageFor_Password = "Password has to be at least 8 characters long."
    static let MessageFor_VerificationCode = "Verification code should be 6 characters long."
}

class EmailAuthenticationViewModel: AlerterViewModel{
    
    private(set) var emailAuthProvider: any EmailAuthProvider
    
    @Published private(set) var emailAuthState: EmailAuthState = .login
    
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    
    var displayNameFieldHidden: Bool{
        emailAuthState != .register
    }
    var emailFieldHidden: Bool{
        emailAuthState != .login && emailAuthState != .register && emailAuthState != .passwordReset
    }
    var passwordFieldHidden: Bool{
        emailAuthState == .passwordReset
    }
    var isDisplayNameValid: Bool{
        return displayName.count >= 3 && displayName.count <= 10
    }
    var isEmailValid: Bool{
        email.isEmail
    }
    var isPasswordValid: Bool{
        return password.count >= 4
    }
    var inputsValid: Bool{
        switch emailAuthState {
        case .login:
            return isEmailValid && isPasswordValid
        case .register:
            return isDisplayNameValid && isEmailValid && isPasswordValid
        case .passwordReset:
            return isEmailValid
        }
    }
    
    init(emailAuthProvider: EmailAuthProvider) {
        self.emailAuthProvider = emailAuthProvider
    }
        
    private func login(_ onProgressComplete: @escaping ()-> Void){
        
        guard !emailAuthProvider.inProgress else {
            self.alert = .authErrorAlert(from: .inProgress)
            onProgressComplete()
            return
        }
        
        guard inputsValid else{
            
            if !isEmailValid{
                self.alert = .alert(ValidationMessages.TitleFor_Email, ValidationMessages.MessageFor_Email)
            }
            else if !isPasswordValid{
                self.alert = .alert(ValidationMessages.TitleFor_Password, ValidationMessages.MessageFor_Password)
            }
            
            onProgressComplete()
            return
        }
        
        emailAuthProvider.emailPassLogin(email: email, password: password) {[weak self] authError in
            DispatchQueue.main.async {
                if let authError{
                    self?.alert = .authErrorAlert(from: authError)
                }
                onProgressComplete()
            }
        }
    }
    
    private func register(_ onProgressComplete: @escaping ()-> Void){
        
        guard !emailAuthProvider.inProgress else {
            self.alert = .authErrorAlert(from: .inProgress)
            onProgressComplete()
            return
        }
        
        guard inputsValid else{
            
            if !isDisplayNameValid{
                self.alert = .alert(ValidationMessages.TitleFor_DisplayName, ValidationMessages.MessageFor_DisplayName)
            }
            else if !isEmailValid{
                self.alert = .alert(ValidationMessages.TitleFor_Email, ValidationMessages.MessageFor_Email)
            }
            else if !isPasswordValid{
                self.alert = .alert(ValidationMessages.TitleFor_Password, ValidationMessages.MessageFor_Password)
            }
            
            onProgressComplete()
            return
        }
                
        emailAuthProvider.emailPassRegister(displayName: displayName, email: email, password: password) {[weak self] authError in
            DispatchQueue.main.async {
                if let authError{
                    self?.alert = .authErrorAlert(from: authError)
                }
                onProgressComplete()
            }
        }
    }
    
    private func resetPassword(_ onProgressComplete: @escaping ()-> Void){
        
        guard !emailAuthProvider.inProgress else {
            self.alert = .authErrorAlert(from: .inProgress)
            onProgressComplete()
            return
        }
        
        guard inputsValid else{
            
            if !isEmailValid{
                self.alert = .alert(ValidationMessages.TitleFor_Email, ValidationMessages.MessageFor_Email)
            }
            
            onProgressComplete()
            return
        }
        
        emailAuthProvider.resetPassword(email: email) {[weak self] authError in
            DispatchQueue.main.async {
                if let authError{
                    self?.alert = .authErrorAlert(from: authError)
                }
                else{
                    self?.emailAuthState = .login
                    self?.alert = .alert("Verification Link Sent", "A password reset link has been sent to \(self?.email ?? "your email address")")
                }
                onProgressComplete()
            }
        }
    }
        
    //MARK: - User intents
    
    func changeState(nextState: EmailAuthState){
        emailAuthState = nextState
    }
    
    func submitEmailCredentials(onProgressComplete: @escaping ()-> Void){
        if emailAuthState == .register{
            //TODO: Validity for Display name, Email, Password
            register(onProgressComplete)
        }
        else if emailAuthState == .login{
            //TODO: Validity for Email, Password
            login(onProgressComplete)
        }
        else if emailAuthState == .passwordReset{
            //TODO: Validity for Email
            resetPassword(onProgressComplete)
        }
        /*else{
         //TODO: Validity for Code, Password
         verifyPasswordResetCode()
         }*/
    }
    
}

