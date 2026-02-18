//
//  NetworkManager.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import Security

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case unauthorized
    case noData
    case httpError(Int)
    case requestFailed(Error)
}

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    // Production API URL
    private let baseURL = "https://api.souqira.com"
    
    // Keychain keys
    private let accessTokenKey = "souqira.accessToken"
    private let refreshTokenKey = "souqira.refreshToken"
    
    var accessToken: String? {
        get { getFromKeychain(key: accessTokenKey) }
        set {
            if let token = newValue {
                saveToKeychain(key: accessTokenKey, value: token)
            } else {
                deleteFromKeychain(key: accessTokenKey)
            }
        }
    }
    
    var refreshToken: String? {
        get { getFromKeychain(key: refreshTokenKey) }
        set {
            if let token = newValue {
                saveToKeychain(key: refreshTokenKey, value: token)
            } else {
                deleteFromKeychain(key: refreshTokenKey)
            }
        }
    }
    
    private init() {}
    
    func setAuthToken(_ token: String) {
        self.accessToken = token
    }
    
    func setTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clearAuthToken() {
        self.accessToken = nil
        self.refreshToken = nil
    }
    
    private func createRequest(endpoint: String, method: String = "GET", body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add language header
        let language = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        request.setValue(language, forHTTPHeaderField: "Accept-Language")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    func fetch<T: Decodable>(endpoint: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        var bodyData: Data?
        if let body = body {
            bodyData = try JSONEncoder().encode(body)
        }
        
        guard let request = createRequest(endpoint: endpoint, method: method, body: bodyData) else {
            print("❌ Failed to create request for: \(endpoint)")
            throw NetworkError.invalidURL
        }
        
        print("📡 Making \(method) request to: \(baseURL)\(endpoint)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            print("✅ Response status: \(httpResponse.statusCode)")
            
            // Log response body for debugging
            if let bodyString = String(data: data, encoding: .utf8) {
                print("📦 Response body: \(bodyString.prefix(500))")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    print("❌ Unauthorized (401)")
                    
                    // Try to decode error message from response
                    if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("❌ Error response: \(errorDict)")
                        if let error = errorDict["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            throw NetworkError.serverError(message)
                        }
                    }
                    
                    throw NetworkError.unauthorized
                }

                // Try to decode error message from response
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorDict["message"] as? String {
                    print("❌ Server error: \(message)")
                    throw NetworkError.serverError(message)
                }

                if let bodyString = String(data: data, encoding: .utf8), !bodyString.isEmpty {
                    print("❌ Server error body: \(bodyString)")
                    throw NetworkError.serverError("Server error \(httpResponse.statusCode): \(bodyString)")
                }

                print("❌ Server error: \(httpResponse.statusCode)")
                throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            
            // Custom date decoding strategy to handle ISO8601 with milliseconds
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Try with fractional seconds first
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
                
                // Fallback to without fractional seconds
                dateFormatter.formatOptions = [.withInternetDateTime]
                if let date = dateFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
            }
            
            do {
                let decoded = try decoder.decode(T.self, from: data)
                print("✅ Successfully decoded response")
                return decoded
            } catch {
                print("❌ Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Response data: \(jsonString)")
                }
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            print("❌ Network request failed: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
    
    // MARK: - Multipart Upload
    
    func uploadMultipart<T: Decodable>(
        endpoint: String,
        parameters: [String: String] = [:],
        images: [(data: Data, filename: String)] = []
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add language header
        let language = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        request.setValue(language, forHTTPHeaderField: "Accept-Language")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Add parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add images
        for (index, image) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(image.filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(image.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        print("📡 Uploading multipart to: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Upload failed with status: \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Token Refresh
    
    func refreshAccessToken() async throws {
        guard let refreshToken = refreshToken else {
            throw NetworkError.unauthorized
        }
        
        struct RefreshRequest: Encodable {
            let refreshToken: String
        }
        
        struct TokenResponse: Decodable {
            let accessToken: String
            let refreshToken: String
        }
        
        struct RefreshAPIResponse: Decodable {
            let success: Bool
            let data: TokenResponse
        }
        
        let response: RefreshAPIResponse = try await fetch(
            endpoint: "/api/auth/refresh",
            method: "POST",
            body: RefreshRequest(refreshToken: refreshToken)
        )
        
        self.accessToken = response.data.accessToken
        self.refreshToken = response.data.refreshToken
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
