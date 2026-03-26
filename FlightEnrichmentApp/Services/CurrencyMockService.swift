// Services/CurrencyMockService.swift

import Foundation

final class CurrencyMockService: CurrencyServiceProtocol {
    private let rates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "JPY": 150.0,
        "AUD": 1.52,
        "CAD": 1.35,
        "CHF": 0.88,
        "CNY": 7.19,
        "INR": 83.0,
        "AED": 3.67,
        "SGD": 1.34
    ]
    
    private let symbols: [String: String] = [
        "USD": "$", "EUR": "€", "GBP": "£", "JPY": "¥",
        "AUD": "A$", "CAD": "C$", "CHF": "Fr", "CNY": "¥",
        "INR": "₹", "AED": "د.إ", "SGD": "S$"
    ]
    
    private let names: [String: String] = [
        "USD": "US Dollar", "EUR": "Euro", "GBP": "British Pound",
        "JPY": "Japanese Yen", "AUD": "Australian Dollar",
        "CAD": "Canadian Dollar", "CHF": "Swiss Franc",
        "CNY": "Chinese Yuan", "INR": "Indian Rupee",
        "AED": "UAE Dirham", "SGD": "Singapore Dollar"
    ]
    
    private let countryToCurrency: [String: String] = [
        "US": "USD", "GB": "GBP", "FR": "EUR", "DE": "EUR",
        "IT": "EUR", "ES": "EUR", "JP": "JPY", "AU": "AUD",
        "CA": "CAD", "CH": "CHF", "CN": "CNY", "IN": "INR",
        "AE": "AED", "SG": "SGD", "NL": "EUR", "CZ": "CZK",
        "AT": "EUR", "HU": "HUF", "PL": "PLN", "SE": "SEK",
        "NO": "NOK", "DK": "DKK", "FI": "EUR", "BE": "EUR",
        "PT": "EUR", "GR": "EUR", "TR": "TRY", "TH": "THB",
        "MX": "MXN", "BR": "BRL", "AR": "ARS", "ZA": "ZAR"
    ]
    
    func fetchCurrency(for countryCode: String) async throws -> CurrencyData {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let currencyCode = countryToCurrency[countryCode] ?? "USD"
        
        return CurrencyData(
            code: currencyCode,
            name: names[currencyCode] ?? currencyCode,
            rateToUSD: rates[currencyCode] ?? 1.0,
            symbol: symbols[currencyCode] ?? "$"
        )
    }
    
    func convert(amount: Double, from: String, to: String) async throws -> ConversionResult {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        let fromRate = rates[from] ?? 1.0
        let toRate = rates[to] ?? 1.0
        let rate = toRate / fromRate
        let converted = amount * rate
        
        return ConversionResult(
            fromCurrency: from,
            toCurrency: to,
            amount: amount,
            convertedAmount: converted,
            rate: rate,
            timestamp: Date()
        )
    }
}
