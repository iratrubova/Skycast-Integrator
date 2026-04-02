//
//  Protocols.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//

import Foundation

// MARK: - Weather
protocol WeatherServiceProtocol {
    func fetchWeather(for city: String, date: Date) async throws -> WeatherData
}

// MARK: - Places
protocol PlacesServiceProtocol {
    func fetchInterestingPlaces(for city: String) async throws -> [Place]
}

// MARK: - Currency
protocol CurrencyServiceProtocol {
    func fetchCurrency(for countryCode: String) async throws -> CurrencyData
    func convert(amount: Double, from: String, to: String) async throws -> ConversionResult
}
