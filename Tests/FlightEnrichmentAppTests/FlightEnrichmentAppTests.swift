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


final class HomeViewModelTests: XCTestCase {
    
    var viewModel: HomeViewModel!

    @MainActor
    override func setUp() {
        super.setUp()
        viewModel = HomeViewModel(
            weatherService: WeatherMockService(),
            placesService: PlacesMockService(),
            currencyService: CurrencyMockService(),
            coreDataStack: CoreDataStack.shared
        )
    }

    // MARK: - Validation Tests (canSearch)
    
    @MainActor
    func testCanSearch_EmptyFields_ReturnsFalse() {
        viewModel.origin = ""
        viewModel.destination = ""
        XCTAssertFalse(viewModel.canSearch, "Should not allow search with empty strings")
    }

    @MainActor
    func testCanSearch_PastDate_ReturnsFalse() {
        viewModel.origin = "London"
        viewModel.destination = "Paris"
        // day - yesterday
        viewModel.departureDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        XCTAssertFalse(viewModel.canSearch, "Should not allow searching for flights in the past")
    }

    @MainActor
    func testCanSearch_FutureDate_ReturnsTrue() {
        viewModel.origin = "London"
        viewModel.destination = "Paris"
        viewModel.departureDate = Date().addingTimeInterval(86400) // Tomorrow
        
        XCTAssertTrue(viewModel.canSearch, "Valid future date and cities should be searchable")
    }

    // MARK: - Search Logic Tests
    
    @MainActor
    func testSearchFlight_Success_UpdatesState() async {
        viewModel.origin = "London"
        viewModel.destination = "Tokyo"
        
        await viewModel.searchFlight()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.showResults)
        XCTAssertNotNil(viewModel.enrichedFlight)
        XCTAssertEqual(viewModel.enrichedFlight?.destination, "Tokyo")
    }


}


