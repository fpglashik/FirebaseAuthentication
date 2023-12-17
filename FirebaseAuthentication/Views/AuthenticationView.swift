//
//  AuthenticationView.swift
//  RockPaperScissorsFight
//
//  Created by mac 2019 on 12/2/23.
//

import SwiftUI

struct AuthenticationView: View{
    
    @EnvironmentObject var authTracker: AuthTracker
    @ObservedObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        
        ZStack{
            
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                
                LogoView()
                    .scaleEffect(0.75, anchor: UnitPoint(x: 0.5, y: 0))
                    .padding(.bottom)
                
                if viewModel.isEmailAuthAvailable && viewModel.isPhoneAuthAvailable{
                    CustomButton(title: "Email Authentication") {
                        withAnimation {
                            viewModel.selectEmailAuthView()
                        }
                    }
                    CustomButton(title: "Phone Authentication"){
                       withAnimation {
                           viewModel.selectPhoneAuthView()
                       }
                    }
                }
                else{
                    Group{
                        emailAuthView
                        phoneAuthView
                    }
                    .padding(.bottom)
                }
                
                Group{
                    Spacer()
                    hDivider
                    Text("Use a Social Login")
                        .foregroundStyle(Color(.secondaryLabel))
                    socialAuthView
                }
                .isHidden(!viewModel.isSocialAuthAvailable, remove: true)
                
                Spacer()
                    .isHidden(viewModel.isSocialAuthAvailable, remove: true)
                
                anonymousAuthView
                    .padding(.vertical)
                
                Button("Logout") {
                    withAnimation {
                        authTracker.authProvider.logout(handler: nil)
                    }
                }
                .isHidden(!authTracker.isAuthenticated, remove: true)
                
            }
            
            selectedAuthView
                
        }
        .frame(maxWidth: 400)
        .padding()
        .alert(viewModel.alert.title,
            isPresented: $viewModel.isAlertPresented,
            actions: { Button("OK", action: viewModel.dismissAlert) },
            message: { Text(viewModel.alert.message) }
        )
    }
    
    private var selectedAuthView: some View{
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
                .isHidden(viewModel.selectedAuthView == .none, remove: true)
            
            VStack{
                Spacer()
                Group{
                    emailAuthView
                        .isHidden(viewModel.selectedAuthView != .email, remove: true)
                    phoneAuthView
                        .isHidden(viewModel.selectedAuthView != .phone, remove: true)
                }
                .padding(.bottom)
                
                Spacer()
                
                Button{
                    withAnimation {
                       viewModel.unselectAuthView()
                    }
                } label:{
                    Image(systemName: "chevron.backward.circle.fill")
                        .scaleEffect(CGSize(width: 3, height: 3))
                }
                .padding(.vertical)
                .isHidden(viewModel.selectedAuthView == .none, remove: true)
            }
        }
        .isHidden(!(viewModel.isEmailAuthAvailable && viewModel.isPhoneAuthAvailable), remove: true)
    }
    
    @ViewBuilder
    private var emailAuthView: some View{
        if viewModel.isEmailAuthAvailable{
            EmailAuthenticationView(viewModel: EmailAuthenticationViewModel(emailAuthProvider: authTracker.authProvider as! EmailAuthProvider))
        }
        else{
            EmptyView()
        }
    }
    @ViewBuilder
    private var phoneAuthView: some View{
        if viewModel.isPhoneAuthAvailable{
            PhoneAuthenticationView(viewModel: PhoneAuthenticationViewModel(phoneAuthProvider: authTracker.authProvider as! PhoneAuthProvider))
        }
        else{
            EmptyView()
        }
    }
    @ViewBuilder
    private var socialAuthView: some View{
        if viewModel.isSocialAuthAvailable{
            SocialAuthenticationView(viewModel: SocialAuthenticationViewModel(socialAuthProvider: viewModel.authProvider as! SocialAuthProvider))
        }
        else{
            EmptyView()
        }
    }
    @ViewBuilder
    private var anonymousAuthView: some View{
        if viewModel.isAnonymousAuthAvailable{
            AnonymousAuthenticationView(viewModel: AnonymousAuthenticationViewModel(anonymousAuthProvider: viewModel.authProvider as! AnonymousAuthProvider))
        }
        else{
            EmptyView()
        }
    }
    
    private var hDivider: some View{
        HStack{
            Rectangle().frame(height: 2).frame(maxWidth: 50)
            Text("Or")
            Rectangle().frame(height: 2).frame(maxWidth: 50)
        }
        .bold()
        .foregroundStyle(.gray)
        .padding(.top)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var authTracker: AuthTracker = AuthTracker(authProvider: DummyAuthProvider())
    static var previews: some View {
        AuthenticationView(viewModel: AuthenticationViewModel(authProvider: authTracker.authProvider))
            .environmentObject(authTracker)
    }
}


