import SwiftUI
import Combine

struct RegisterView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var userId = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var preferredLanguage = "en"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("User ID", text: $userId)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone (Optional)", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Preferences")) {
                    Picker("Preferred Language", selection: $preferredLanguage) {
                        Text("Japanese").tag("jpn")
                        Text("English").tag("en")
                        Text("Myanmar").tag("my")
                        Text("Thai").tag("th")
                        Text("Vietnamese").tag("vi")
                    }
                }
                
                if let errorMessage = authManager.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: register) {
                        if authManager.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || authManager.isLoading)
                }
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
                // Dismiss the view when registration is successful
                if newValue && !oldValue {
                    dismiss()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !userId.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@")
    }
    
    private func register() {
        let userData = UserRegister(
            userId: userId,
            password: password,
            confirmPassword: confirmPassword,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            preferredLanguage: preferredLanguage
        )
        
        // Clear any previous errors
        authManager.register(userData)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager.shared)
}

#Preview("Dark Mode") {
    RegisterView()
        .environmentObject(AuthManager.shared)
        .preferredColorScheme(.dark)
}
