import Foundation
import Combine
import CoreData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var origin: String = ""
    @Published var destination: String = ""
    @Published var departureDate: Date = Date().addingTimeInterval(86400) // Tomorrow by default
    @Published var returnDate: Date? = nil
    @Published var userCurrency: String = "USD"
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    @Published var enrichedFlight: EnrichedFlight?
    @Published var showResults: Bool = false
    
    private let weatherService: WeatherServiceProtocol
    private let placesService: PlacesServiceProtocol
    private let currencyService: CurrencyServiceProtocol
    private let coreDataStack: CoreDataStack
    
    // FIX: Compare dates only (ignore time component)
    var canSearch: Bool {
        !origin.isEmpty &&
        !destination.isEmpty &&
        Calendar.current.startOfDay(for: departureDate) >= Calendar.current.startOfDay(for: Date())
    }
    
//    init(
//        weatherService: WeatherServiceProtocol = RealWeatherService(),
//        placesService: PlacesServiceProtocol = PlacesApiService(),
//        currencyService: CurrencyServiceProtocol = CurrencyApiService(),
//        coreDataStack: CoreDataStack = .shared
//    ) {
//        self.weatherService = weatherService
//        self.placesService = placesService
//        self.currencyService = currencyService
//        self.coreDataStack = coreDataStack
//    }
    
    init(
        weatherService: WeatherServiceProtocol = WeatherMockService(), // Use Mock
        placesService: PlacesServiceProtocol = PlacesMockService(),   // Use Mock
        currencyService: CurrencyServiceProtocol = CurrencyMockService(), // Use Mock
        coreDataStack: CoreDataStack = .shared
    ) {
        self.weatherService = weatherService
        self.placesService = placesService
        self.currencyService = currencyService
        self.coreDataStack = coreDataStack
    }
    
    func searchFlight() async {
        guard canSearch else {
            errorMessage = "Please fill in all fields correctly"
            showError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. GET COUNTRY FROM JSON: Find the code (like "CN") before starting tasks
            let countryCodeForDestination = getCountryCode(for: destination)
            
            async let weatherTask = fetchWeather()
            async let placesTask = fetchPlaces()
            
            // 2. PASS JSON CODE: Update your fetchCurrency call to use the JSON result
            async let currencyTask = currencyService.fetchCurrency(for: countryCodeForDestination)
            
            let (weather, places, currency) = try await (weatherTask, placesTask, currencyTask)
            
            // The rest of your code stays exactly the same...
            let conversion = try? await currencyService.convert(
                amount: 100,
                from: currency.code,
                to: userCurrency
            )
            
            let flight = EnrichedFlight(
                id: UUID(),
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                returnDate: returnDate,
                createdAt: Date(),
                weather: weather,
                places: places,
                currency: currency,
                conversion: conversion
            )
            
            self.enrichedFlight = flight
            self.showResults = true
            
            await saveFlight(flight)
            
        } catch let error as APIError {
            errorMessage = "API Error: \(error.localizedDescription)"
            showError = true
        } catch {
            errorMessage = "Failed to fetch data: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func fetchWeather() async throws -> WeatherData {
        return try await weatherService.fetchWeather(for: destination, date: departureDate)
    }
    
    private func fetchPlaces() async throws -> [Place] {
        return try await placesService.fetchInterestingPlaces(for: destination)
    }
    
    private func fetchCurrency() async throws -> CurrencyData {
        let countryCode = mapCityToCountryCode(destination)
        return try await currencyService.fetchCurrency(for: countryCode)
    }
    
    private func mapCityToCountryCode(_ city: String) -> String {
        let mapping: [String: String] = [
            "London": "GB", "Paris": "FR", "Tokyo": "JP", "New York": "US",
            "Berlin": "DE", "Rome": "IT", "Madrid": "ES", "Sydney": "AU",
            "Dubai": "AE", "Singapore": "SG", "Barcelona": "ES", "Amsterdam": "NL",
            "Prague": "CZ", "Vienna": "AT", "Budapest": "HU", "Milan": "IT",
            "Munich": "DE", "Lisbon": "PT", "Athens": "GR", "Istanbul": "TR",
            "Bangkok": "TH", "Hong Kong": "CN", "Toronto": "CA", "Vancouver": "CA",
            "Los Angeles": "US", "San Francisco": "US", "Chicago": "US", "Miami": "US",
            "Las Vegas": "US", "Boston": "US", "Seattle": "US", "Washington": "US",
            "Mexico City": "MX", "Cancun": "MX", "Rio de Janeiro": "BR", "Sao Paulo": "BR",
            "Buenos Aires": "AR", "Cape Town": "ZA", "Cairo": "EG", "Moscow": "RU",
            "Seoul": "KR", "Beijing": "CN", "Shanghai": "CN", "Delhi": "IN",
            "Mumbai": "IN", "Jakarta": "ID", "Kuala Lumpur": "MY", "Manila": "PH",
            "Hanoi": "VN", "Taipei": "TW", "Auckland": "NZ", "Melbourne": "AU",
            "Brisbane": "AU", "Perth": "AU", "Adelaide": "AU", "Gold Coast": "AU",
            "Cairns": "AU", "Darwin": "AU", "Hobart": "AU", "Canberra": "AU",
            "Wellington": "NZ", "Christchurch": "NZ", "Queenstown": "NZ", "Fiji": "FJ",
            "Bora Bora": "PF", "Maldives": "MV", "Seychelles": "SC", "Mauritius": "MU",
            "Morocco": "MA", "Tunisia": "TN", "Kenya": "KE", "Tanzania": "TZ",
            "Zimbabwe": "ZW", "Botswana": "BW", "Namibia": "NA", "Zambia": "ZM",
            "Ghana": "GH", "Nigeria": "NG", "Ethiopia": "ET", "Uganda": "UG",
            "Rwanda": "RW", "Senegal": "SN", "Ivory Coast": "CI", "Cameroon": "CM"
        ]
        return mapping[city] ?? "US"
    }
    
    private func saveFlight(_ flight: EnrichedFlight) async {
        coreDataStack.performBackgroundTask { context in
            let flightEntity = FlightEntity(context: context)
            flightEntity.id = flight.id
            flightEntity.origin = flight.origin
            flightEntity.destination = flight.destination
            flightEntity.departureDate = flight.departureDate
            flightEntity.returnDate = flight.returnDate
            flightEntity.createdAt = flight.createdAt
            
            if let authUser = AuthService.shared.currentUser {
                let userRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
                userRequest.predicate = NSPredicate(format: "id == %@", authUser.id)
                
                if let user = try? context.fetch(userRequest).first {
                    flightEntity.user = user
                }
            }
            
            if let weather = flight.weather {
                let enrichment = EnrichmentDataEntity(context: context)
                enrichment.id = UUID()
                enrichment.weatherTemp = weather.temperature
                enrichment.weatherCondition = weather.condition
                enrichment.currencyCode = flight.currency?.code ?? ""
                enrichment.exchangeRate = flight.conversion?.rate ?? 0
                enrichment.localPriceExample = flight.conversion?.amount ?? 0
                enrichment.flight = flightEntity
                
                if let places = flight.places,
                   let placesData = try? JSONEncoder().encode(places) {
                    enrichment.placesJSON = String(data: placesData, encoding: .utf8) ?? ""
                }
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to save flight: \(error)")
            }
        }
    }
    
    func clearSearch() {
        origin = ""
        destination = ""
        departureDate = Date().addingTimeInterval(86400) // Tomorrow
        returnDate = nil
        enrichedFlight = nil
        showResults = false
    }
    
    struct CityMapping: Codable {
        let city: String
        let country: String
    }

    private func getCountryCode(for cityName: String) -> String {
        // 1. Find the file in the app bundle
        guard let url = Bundle.main.url(forResource: "city_country_mapping", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not find city_country_mapping.json")
            return "US" // Default fallback
        }
        
        do {
            // 2. Decode the JSON into an array of CityMapping
            let mappings = try JSONDecoder().decode([CityMapping].self, from: data)
            
            // 3. Search for the city (case-insensitive)
            let found = mappings.first { $0.city.lowercased() == cityName.lowercased() }
            
            print("JSON Lookup: \(cityName) -> \(found?.country ?? "US")")
            return found?.country ?? "US"
            
        } catch {
            print("Error decoding JSON: \(error)")
            return "US"
        }
    }

}
