//
//  schoolLF8Tests.swift
//  schoolLF8Tests
//
//  Created by Iryna Radionova on 24.03.26.
//
import Testing
@testable import schoolLF8

final class WeatherMockServiceTests: XCTestCase {
    
    var sut: WeatherMockService!
    
    override func setUp() {
        super.setUp()
        sut = WeatherMockService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFetchWeatherForParis() async throws {
        let weather = try await sut.fetchWeather(for: "Paris", date: Date())
        
        XCTAssertEqual(weather.temperature, 18.0)
        XCTAssertEqual(weather.condition, "Cloudy")
        XCTAssertEqual(weather.humidity, 65)
    }
    
    func testFetchWeatherForLondon() async throws {
        let weather = try await sut.fetchWeather(for: "London", date: Date())
        
        XCTAssertEqual(weather.condition, "Rainy")
        XCTAssertEqual(weather.temperature, 15.0)
    }
    
    func testFetchWeatherForUnknownCity() async throws {
        let weather = try await sut.fetchWeather(for: "UnknownCity", date: Date())
        
        XCTAssertEqual(weather.condition, "Sunny")
        XCTAssertEqual(weather.temperature, 20.0)
    }
}


