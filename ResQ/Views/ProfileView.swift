import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            Form {
                if let user = authManager.currentUser {

                    Section(header: Text("User Information")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.name ?? "-")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("User ID")
                            Spacer()
                            Text(user.userId ?? "-")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email ?? "_")
                                .foregroundColor(.secondary)
                        }

                        if let phone = user.phone {
                            HStack {
                                Text("Phone")
                                Spacer()
                                Text(phone)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Section(header: Text("Preferences")) {
                        HStack {
                            Text("Preferred Language")
                            Spacer()
                            Text((user.preferredLanguage ?? "_").uppercased())
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Severity Threshold")
                            Spacer()
                            Text((user.severityThreshold ?? "-").capitalized)
                                .foregroundColor(.secondary)
                        }
                    }

                    Section(header: Text("Notification Preferences")) {
                        HStack {
                            Text("Email")
                            Spacer()
                            Image(systemName: (user.notificationPreferences?.email ?? false)
                                  ? "checkmark.circle.fill"
                                  : "xmark.circle")
                                .foregroundColor((user.notificationPreferences?.email ?? false) ? .green : .gray)
                        }

                        HStack {
                            Text("Push")
                            Spacer()
                            Image(systemName: (user.notificationPreferences?.push ?? false)
                                  ? "checkmark.circle.fill"
                                  : "xmark.circle")
                                .foregroundColor((user.notificationPreferences?.push ?? false) ? .green : .gray)
                        }

                        HStack {
                            Text("SMS")
                            Spacer()
                            Image(systemName: (user.notificationPreferences?.sms ?? false)
                                  ? "checkmark.circle.fill"
                                  : "xmark.circle")
                                .foregroundColor((user.notificationPreferences?.sms ?? false) ? .green : .gray)
                        }
                    }

                    // ❗ Section ကို Section ထဲမထည့်ပါနဲ့ — separate section လုပ်ပါ
                    Section(header: Text("Alert Categories")) {
                        if let categories = user.alertCategories, !categories.isEmpty {
                            ForEach(categories, id: \.self) { category in
                                Text(category.capitalized)
                            }
                        } else {
                            Text("-")
                                .foregroundColor(.secondary)
                        }
                    }

                    Section {
                        Button {
                            showingLogoutAlert = true
                        } label: {
                            Text("Logout")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }

                } else {
                    Text("No user logged in")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

// ✅ Preview ကို struct body အပြင်မှာ
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager.shared)
    }
}

