//
//  WeatherMockService.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 31.03.26.
//

import Foundation

final class WeatherMockService: WeatherServiceProtocol {
    func fetchWeather(for city: String, date: Date) async throws -> WeatherData {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 400_000_000)
        
        let cityLower = city.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Return different weather based on common cities
        switch cityLower {
        case "paris":
            return WeatherData(temperature: 18.0, condition: "Cloudy", humidity: 65, windSpeed: 12.0, icon: "03d")
        case "london":
            return WeatherData(temperature: 15.0, condition: "Rainy", humidity: 80, windSpeed: 20.0, icon: "09d")
        case "tokyo":
            return WeatherData(temperature: 22.0, condition: "Clear", humidity: 45, windSpeed: 8.0, icon: "01d")
        default:
            // Generic fallback
            return WeatherData(temperature: 20.0, condition: "Sunny", humidity: 50, windSpeed: 10.0, icon: "01d")
        }
    }
}
