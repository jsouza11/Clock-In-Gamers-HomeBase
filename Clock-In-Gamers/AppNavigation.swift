import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = 0  //Track selected tab

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                
                Home()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)  //Assign tag

                ProfView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(1)

                Schedule()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .tag(2)

                ChatroomView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("Chatroom")
                    }
                    .tag(3)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                }
            }
        }
    }

}
#Preview {
    AppNavigation()
        .environmentObject(AuthViewModel.preview)
        .environmentObject(AppData())
}
