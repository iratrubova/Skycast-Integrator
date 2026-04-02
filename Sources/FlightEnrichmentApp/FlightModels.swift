//
//  FlightModels.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//
import Foundation

// MARK: - API Response Models

struct WeatherData: Codable, Identifiable {
    public let id = UUID()
    public let temperature: Double
    public let condition: String
    public let humidity: Double
    public let windSpeed: Double
    public let icon: String
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case condition = "main"
        case humidity
        case windSpeed = "wind_speed"
        case icon = "weather_icon"
    }
}

struct Place: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let rating: Double
    let imageURL: String?
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case name
        case description
        case rating
        case imageURL = "image_url"
        case category = "type"
    }
}

struct CurrencyData: Codable {
    let code: String
    let name: String
    let rateToUSD: Double
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case rateToUSD = "rate_to_usd"
        case symbol
    }
}

struct ConversionResult: Codable {
    let fromCurrency: String
    let toCurrency: String
    let amount: Double
    let convertedAmount: Double
    let rate: Double
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case fromCurrency = "from"
        case toCurrency = "to"
        case amount
        case convertedAmount = "converted"
        case rate
        case timestamp
    }
}

// MARK: - Enriched Flight Model (for UI)

struct EnrichedFlight: Identifiable {
    let id: UUID
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date?
    let createdAt: Date
    
    var weather: WeatherData?
    var places: [Place]?
    var currency: CurrencyData?
    var conversion: ConversionResult?
    
    var isFullyEnriched: Bool {
        weather != nil && places != nil && currency != nil
    }
}

// MARK: - Flight Search Request

struct FlightSearchRequest {
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date?
    let userCurrency: String // e.g., "USD", "EUR"
}
