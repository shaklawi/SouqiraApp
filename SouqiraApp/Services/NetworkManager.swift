//
//  NetworkManager.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import Security
import SwiftUI
import UIKit

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

    private let baseURL: String
    
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
    
    private init() {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
           !configured.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            baseURL = configured
        } else {
            baseURL = "https://api.souqira.com"
        }
    }
    
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
    
    private func createRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        includeAuthorization: Bool = true
    ) -> URLRequest? {
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
        
        if includeAuthorization, let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }

    private func extractErrorMessage(from data: Data) -> String? {
        guard let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        if let nested = errorDict["error"] as? [String: Any],
           let message = nested["message"] as? String {
            return message
        }
        if let nested = errorDict["error"] as? [String: Any],
           let messageMap = nested["message"] as? [String: Any] {
            let combined = messageMap
                .map { "\($0.key): \($0.value)" }
                .sorted()
                .joined(separator: "\n")
            if !combined.isEmpty {
                return combined
            }
        }
        if let message = errorDict["message"] as? String {
            return message
        }
        if let error = errorDict["error"] as? String {
            return error
        }
        return nil
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            dateFormatter.formatOptions = [.withInternetDateTime]
            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
        }

        return decoder
    }

    private func executeRequest<T: Decodable>(
        endpoint: String,
        method: String,
        bodyData: Data?,
        includeAuthorization: Bool = true,
        retryOnUnauthorized: Bool = true
    ) async throws -> T {
        guard let request = createRequest(
            endpoint: endpoint,
            method: method,
            body: bodyData,
            includeAuthorization: includeAuthorization
        ) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 401,
           retryOnUnauthorized,
           endpoint != "/api/auth/refresh",
           refreshToken != nil {
            do {
                try await refreshAccessToken()
                return try await executeRequest(
                    endpoint: endpoint,
                    method: method,
                    bodyData: bodyData,
                    includeAuthorization: includeAuthorization,
                    retryOnUnauthorized: false
                )
            } catch {
                clearAuthToken()
            }
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                if let message = extractErrorMessage(from: data) {
                    throw NetworkError.serverError(message)
                }
                throw NetworkError.unauthorized
            }

            if let message = extractErrorMessage(from: data) {
                throw NetworkError.serverError(message)
            }

            if let bodyString = String(data: data, encoding: .utf8), !bodyString.isEmpty {
                throw NetworkError.serverError("Server error \(httpResponse.statusCode): \(bodyString)")
            }

            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }

        do {
            return try makeDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetch<T: Decodable>(endpoint: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        var bodyData: Data?
        if let body = body {
            bodyData = try JSONEncoder().encode(body)
        }

        do {
            return try await executeRequest(endpoint: endpoint, method: method, bodyData: bodyData)
        } catch let error as NetworkError {
            throw error
        } catch {
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
        for image in images {
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

        let bodyData = try JSONEncoder().encode(RefreshRequest(refreshToken: refreshToken))
        let response: RefreshAPIResponse = try await executeRequest(
            endpoint: "/api/auth/refresh",
            method: "POST",
            bodyData: bodyData,
            includeAuthorization: false,
            retryOnUnauthorized: false
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

actor ImagePipeline {
    static let shared = ImagePipeline()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private var inFlight: [URL: Task<UIImage, Error>] = [:]

    init() {
        let cache = URLCache(
            memoryCapacity: 100 * 1024 * 1024,
            diskCapacity: 500 * 1024 * 1024,
            diskPath: "souqira-image-cache"
        )

        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = cache
        configuration.timeoutIntervalForRequest = 30
        configuration.httpMaximumConnectionsPerHost = 8

        session = URLSession(configuration: configuration)
        memoryCache.countLimit = 300
    }

    func image(for url: URL) async throws -> UIImage {
        let key = url as NSURL

        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        if let task = inFlight[url] {
            return try await task.value
        }

        let task = Task<UIImage, Error> {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }

            guard let image = UIImage(data: data) else {
                throw URLError(.cannotDecodeRawData)
            }

            memoryCache.setObject(image, forKey: key)
            return image
        }

        inFlight[url] = task

        do {
            let result = try await task.value
            inFlight[url] = nil
            return result
        } catch {
            inFlight[url] = nil
            throw error
        }
    }

    func prefetch(urls: [URL]) async {
        for url in urls {
            _ = try? await image(for: url)
        }
    }
}

struct CachedRemoteImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let loadedImage {
                content(Image(uiImage: loadedImage))
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            guard let url else {
                loadedImage = nil
                return
            }

            if loadedImage != nil {
                return
            }

            loadedImage = try? await ImagePipeline.shared.image(for: url)
        }
    }
}
