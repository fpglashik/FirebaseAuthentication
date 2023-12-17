//
//  PhoneAuthenticationView.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/15/23.
//

import SwiftUI

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
        //        let phoneNoRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        //        return NSPredicate(format: "SELF MATCHES %@", phoneNoRegex).evaluate(with: phoneNo)
        return phoneNo.count > 5
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


struct PhoneAuthenticationView: View {
    
    @ObservedObject var viewModel: PhoneAuthenticationViewModel
    @EnvironmentObject var progressHandler: CustomProgressHandler
    
    var body: some View {
        VStack{
            phoneAuth
        }
        .disabled(viewModel.phoneAuthProvider.inProgress)
        .alert(viewModel.alert.title, isPresented: $viewModel.isAlertPresented)
        {
            Button("OK", role: .cancel) {
                viewModel.alert = .none
            }
        } message: {
            Text(viewModel.alert.message)
        }
    }
    
    @ViewBuilder
    private var phoneAuth: some View{
        
        // MARK: Input Fields
        VStack{
            Text(viewModel.authState.instruction)
            
            CustomTextField(text: $viewModel.phoneNo, placeholder: "Phone Number", symbolName: "phone.fill")
                .padding(.bottom, 5)
                .isHidden(viewModel.phoneNoFieldHidden, remove: true)
            
            CustomTextField(text: $viewModel.verificationCode, placeholder: "Verification Code", symbolName: "key.horizontal.fill")
                .padding(.bottom, 5)
                .isHidden(viewModel.codeFieldHidden, remove: true)
        }
        
        // MARK: Submit Button
        VStack{
            Button{
                withAnimation{
                    progressHandler.updateProgressState(true, message: viewModel.authState == .register ? "Logging In" : "Verifying")
                    viewModel.submit {
                        progressHandler.updateProgressState(false)
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text(viewModel.authState.action.uppercased())
                        .bold()
                        .foregroundStyle(.white)
                        .padding()
                    Spacer()
                }
            }
            .background(Color.accentColor)
            .cornerRadius(10)
            .padding(.top)
        }
    }
}

#Preview {
    PhoneAuthenticationView(viewModel: PhoneAuthenticationViewModel(phoneAuthProvider: DummyAuthProvider() ))
        .environmentObject(CustomProgressHandler())
}
