//
//  ContentView.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 2/11/25.
//
import SwiftUI

struct ContentView: View {    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                Home()
            }
            else {
                LoginView()
            }
            
            
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
  
}
