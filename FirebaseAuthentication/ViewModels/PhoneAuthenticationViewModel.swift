//
//  PhoneAuthenticationViewModel.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/17/23.
//

import Foundation

enum PhoneAuthState: Equatable, Identifiable{
    var id: String{
        action
    }
    
    case register
    case verify
    
    var instruction: String{
        switch self{
        case .register: return "Enter a valid phone number"
        case .verify: return "Submit verification OTP"
        }
    }
    
    var action: String{
        switch self{
        case .register: return "Submit"
        case .verify: return "Verify"
        }
    }
}

class PhoneAuthenticationViewModel: AlerterViewModel{
    private(set) var phoneAuthProvider: any PhoneAuthProvider
    
    @Published private(set) var authState: PhoneAuthState = .register
    @Published var phoneNo: String = ""
    @Published var verificationCode: String = ""
    
    var phoneNoFieldHidden: Bool{
        authState != .register
    }
    var codeFieldHidden: Bool{
        authState != .verify
    }
    
    var isPhoneNoValid: Bool{
        phoneNo.isPhoneNo
    }
    var isVerificationCodeValid: Bool{
        return verificationCode.count > 2
    }
    
    init(phoneAuthProvider: PhoneAuthProvider) {
        self.phoneAuthProvider = phoneAuthProvider
    }
    
    private func submitPhoneNumber(onProgressComplete: @escaping ()-> Void){
        guard !phoneAuthProvider.inProgress else {
            self.alert = .authErrorAlert(from: .inProgress)
            onProgressComplete()
            return
        }
        
        guard isPhoneNoValid else{
            
            self.alert = .alert("Invalid Phone Number", "\(phoneNo) is not a valid phone number. Please enter a valid one.")
            
            onProgressComplete()
            return
        }
        
        phoneAuthProvider.phoneRegister(phone: phoneNo){[weak self] authError in
            DispatchQueue.main.async {
                if let authError{
                    self?.alert = .authErrorAlert(from: authError)
                }
                else{
                    self?.authState = .verify
                }
                onProgressComplete()
            }
        }
        
    }
    
    private func submitOTP(onProgressComplete: @escaping ()-> Void){
        guard !phoneAuthProvider.inProgress else {
            self.alert = .authErrorAlert(from: .inProgress)
            onProgressComplete()
            return
        }
        
        guard isPhoneNoValid else{
            self.alert = .alert("Invalid Phone Number", "\(phoneNo) is not a valid phone number. Please enter a valid one.")
            
            onProgressComplete()
            return
        }
        
        phoneAuthProvider.verifyPhoneNumber(code: verificationCode){[weak self] authError in
            DispatchQueue.main.async {
                if let authError{
                    self?.alert = .authErrorAlert(from: authError)
                }
                
                onProgressComplete()
            }
        }
        
    }
    
    //MARK: - User intents
    
    
    func submit(onProgressComplete: @escaping ()-> Void){
        if authState == .register{
            submitPhoneNumber(onProgressComplete: onProgressComplete)
        }
        else{
            submitOTP(onProgressComplete: onProgressComplete)
        }
    }

}
