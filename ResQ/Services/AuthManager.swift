import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService: APIServiceProtocol
    private let storageService = StorageService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Allow dependency injection for testing
    init(apiService: APIServiceProtocol? = nil) {
        self.apiService = apiService ?? APIService.shared
        loadUserFromStorage()
    }
    
    // MARK: - Authentication
    func login(userId: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        apiService.login(userId: userId, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.currentUser = response.user
                    self?.isAuthenticated = true
                    self?.saveUserToStorage(response.user)
                }
            )
            .store(in: &cancellables)
    }
    
    func register(_ userData: UserRegister) {
        isLoading = true
        errorMessage = nil
        
        apiService.register(userData)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.currentUser = response.user
                    self?.isAuthenticated = true
                    self?.saveUserToStorage(response.user)
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        clearUserFromStorage()
    }
    
    // MARK: - Storage (using StorageService)
    private func saveUserToStorage(_ user: User) {
        storageService.save(user, forKey: StorageService.Keys.currentUser)
        storageService.save(user.userId, forKey: StorageService.Keys.currentUserID)
    }
    
    private func loadUserFromStorage() {
        if let user: User = storageService.load(User.self, forKey: StorageService.Keys.currentUser) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    private func clearUserFromStorage() {
        storageService.remove(forKey: StorageService.Keys.currentUser)
        storageService.remove(forKey: StorageService.Keys.currentUserID)
    }
}
