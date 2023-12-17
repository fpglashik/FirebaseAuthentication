//
//  PhoneAuthenticationView.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/15/23.
//

import SwiftUI


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
                .keyboardType(.decimalPad)
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
