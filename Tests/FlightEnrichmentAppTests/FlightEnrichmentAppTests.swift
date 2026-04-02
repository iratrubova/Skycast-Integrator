import XCTest
@testable import schoolLF8

final class WeatherMockServiceTests: XCTestCase {
    
    func testParisWeather() async throws {
        let service = WeatherMockService()
        let weather = try await service.fetchWeather(for: "Paris", date: Date())
        XCTAssertEqual(weather.temperature, 18.0)
    }
    
    func testLondonWeather() async throws {
        let service = WeatherMockService()
        let weather = try await service.fetchWeather(for: "London", date: Date())
        XCTAssertEqual(weather.condition, "Rainy")
    }
}


final class CurrencyMockServiceTests: XCTestCase {
    
    func testGermanyCurrency() async throws {
        let service = CurrencyMockService()
        let currency = try await service.fetchCurrency(for: "DE")
        XCTAssertEqual(currency.rate, 0.92)
    }
    
    func testChinaCurrency() async throws {
        let service = CurrencyMockService()
        let currency = try await service.fetchCurrency(for: "CN")
        XCTAssertEqual(currency.rate, 7.19)
    }
}

// Testing Github