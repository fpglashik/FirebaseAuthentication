//
//  AlerterViewModel.swift
//  FirebaseAuthentication
//
//  Created by mac 2019 on 12/17/23.
//

import Foundation

class ViewModel: ObservableObject{
    
}

class AlerterViewModel: ViewModel{
    
    @Published var isAlertPresented: Bool = false
    @Published var alert: AlertMe = .none{
        didSet{
            if alert != .none{
                isAlertPresented = true
            }
        }
    }
    
    func dismissAlert(){
        self.alert = .none
    }
}
