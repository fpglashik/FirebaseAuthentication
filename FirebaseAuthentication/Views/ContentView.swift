//
//  ContentView.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/13/23.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var authTracker: AuthTracker
    @State var showAuthView: Bool = false
    let colors: [Color] = [.red, .green, .blue, .cyan, .teal, .orange, .brown, .gray]
    
    var body: some View {
        
        ZStack{
            VStack {
                Text("Hello, \(authTracker.displayName)!")
                    .isHidden(!authTracker.isAuthenticated, remove: true)
                    .padding(.vertical)
                
                ScrollView(.horizontal, showsIndicators: true){
                    HStack{
                        ForEach(colors.prefix(authTracker.isAuthenticated ? colors.count : 3), id: \.self){ color in
                            color.clipShape(.circle)
                                .frame(width: 50, height: 50)
                        }
                    }
                    .frame(height: 100)
                }
                
                Button("Login for More Colors") {
                    withAnimation {
                        showAuthView.toggle()
                    }
                }
                .padding(.vertical)
                .isHidden(authTracker.isAuthenticated, remove: true)
                
                Button("Logout") {
                    withAnimation {
                        authTracker.authProvider.logout{ _ in
                            showAuthView = false
                        }
                    }
                }
                .isHidden(!authTracker.isAuthenticated, remove: true)
            }
            .padding()
                        
            authView
                .isHidden(!showAuthView, remove: true)
        }
        .onChange(of: authTracker.isAuthenticated){ value in
            if value{
                showAuthView = false
            }
        }
    }
    
    private var authView: some View{
        ZStack{
            Color(.systemBackground)
                .ignoresSafeArea()
            
            AuthenticationView(viewModel: AuthenticationViewModel(authProvider: authTracker.authProvider))
            
            HStack{
                VStack{
                    Button{
                        withAnimation {
                            showAuthView = false
                        }
                    } label:{
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.red)
                            .scaleEffect(CGSize(width: 2, height: 2), anchor: UnitPoint(x: -0.2, y: -0.1))
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthTracker(authProvider: DummyAuthProvider()))
        .environmentObject(CustomProgressHandler())
}
