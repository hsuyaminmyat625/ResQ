//
//  APIServiceProtocol.swift
//  ResQ
//
//  Created by sym on 2025/11/19.
//
// APIServiceProtocol.swift
import Foundation
import Combine

protocol APIServiceProtocol {
    func login(userId: String, password: String) -> AnyPublisher<LoginResponse, APIError>
    func register(_ userData: UserRegister) -> AnyPublisher<RegisterResponse, APIError>
}
