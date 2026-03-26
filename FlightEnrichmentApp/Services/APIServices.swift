//
//  APIServices.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL - city name may contain invalid characters"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode weather data"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}

protocol APIServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private let session: URLSession
    private let baseURL = "https://api.flightenrichment.example.com/v1"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw APIError.decodingError
        }
    }
}

struct Endpoint {
    let path: String
    let method: String
    let body: [String: Any]?
    
    init(path: String, method: String = "GET", body: [String: Any]? = nil) {
        self.path = path
        self.method = method
        self.body = body
    }
}
