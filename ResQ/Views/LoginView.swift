import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var userId = ""
    @State private var password = ""
    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("ResQ")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Emergency Alerts & Notifications")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("User ID", text: $userId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        authManager.login(userId: userId, password: password)
                    }) {
                        if authManager.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(authManager.isLoading || userId.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 30)
                
                // Register Link
                HStack {
                    Text("Don't have an account?")
                    Button("Register") {
                        showingRegister = true
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .sheet(isPresented: $showingRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}

#Preview("Dark Mode") {
    LoginView()
        .environmentObject(AuthManager.shared)
        .preferredColorScheme(.dark)
}

#Preview("iPhone SE") {
    LoginView()
        .environmentObject(AuthManager.shared)
}

#Preview("iPad") {
    LoginView()
        .environmentObject(AuthManager.shared)
}

