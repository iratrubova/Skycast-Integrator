import XCTest
import CoreData
@testable import schoolLF8

final class WeatherMockServiceTests: XCTestCase {
    
    func testParisWeather() async throws {
        let service = WeatherMockService()
        let weather = try await service.fetchWeather(for: "Paris", date: Date())
        XCTAssertEqual(weather.temperature, 18.0)
    }

    func testTokyoWeather() async throws {
        let service = WeatherMockService()
        let weather = try await service.fetchWeather(for: "Tokyo", date: Date())
        XCTAssertEqual(weather.humidity, 45.0)
    }
    
    func testLondonWeather() async throws {
        let service = WeatherMockService()
        let weather = try await service.fetchWeather(for: "London", date: Date())
        XCTAssertEqual(weather.condition, "Rainy")
    }

    func testDefaultWeather() async throws {
    let service = WeatherMockService()
    let weather = try await service.fetchWeather(for: "default", date: Date())
    XCTAssertEqual(weather.windSpeed, 10.0)
}
}


final class CurrencyMockServiceTests: XCTestCase {
    
    func testGermanyCurrency() async throws {
        let service = CurrencyMockService()
        let currency = try await service.convert(amount: 1, from: "USD", to: "EUR")
        XCTAssertEqual(currency.rate, 0.92)
    }
}

final class PlacesServiceTests: XCTestCase {
    
    // Test developed by Ahmed to verify fallback and mock logic
    func testFetchInterestingPlaces() async throws {
        // 1. Arrange
        let service = PlacesMockService()
        let knownCity = "Berlin"
        let unknownCity = "Buxtehude"
        
        // 2. Act
        let knownPlaces = try await service.fetchInterestingPlaces(for: knownCity)
        let fallbackPlaces = try await service.fetchInterestingPlaces(for: unknownCity)
        
        // 3. Assert
        XCTAssertEqual(knownPlaces.first?.name, "Brandenburg Gate", "Should return Berlin landmarks")
        XCTAssertTrue(fallbackPlaces.contains(where: { $0.name.contains("City Center") }), "Should return generic fallback for unknown cities")
        XCTAssertEqual(knownPlaces.count, 5, "Known cities should return 5 places")
        XCTAssertEqual(fallbackPlaces.count, 5, "Fallback should also return 5 places")
    }
}



