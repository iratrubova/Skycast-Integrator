import Foundation

final class RealWeatherService: WeatherServiceProtocol {
    private let apiKey = "2e44e4fb8c1f64f937ac44d816a0fe45" // Replace with your working key
    private let session: URLSession
    
    init() {
        // Configure session with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }
    
    func fetchWeather(for city: String, date: Date) async throws -> WeatherData {
        // Build URL components properly
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        guard let url = components.url else {
            print("Failed to build URL for city: \(city)")
            throw APIError.invalidURL
        }
        
        print("Fetching weather for: \(city)")
        print("URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                throw APIError.invalidResponse
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response: \(jsonString)")
            }
            
            if httpResponse.statusCode == 401 {
                print("Invalid API key")
                throw APIError.serverError(401)
            }
            
            if httpResponse.statusCode == 404 {
                print("City not found")
                throw APIError.serverError(404)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            struct OWResponse: Codable {
                struct Main: Codable {
                    let temp: Double
                    let humidity: Int
                }
                struct Weather: Codable {
                    let main: String
                    let icon: String
                }
                struct Wind: Codable {
                    let speed: Double
                }
                let main: Main
                let weather: [Weather]
                let wind: Wind
            }
            
            let owData = try JSONDecoder().decode(OWResponse.self, from: data)
            
            print("Got weather: \(owData.main.temp)°C, \(owData.weather.first?.main ?? "Unknown")")
            
            return WeatherData(
                temperature: owData.main.temp,
                condition: owData.weather.first?.main ?? "Unknown",
                humidity: owData.main.humidity,
                windSpeed: owData.wind.speed,
                icon: owData.weather.first?.icon ?? "01d"
            )
            
        } catch let error as APIError {
            throw error
        } catch let error as URLError {
            print("URL Error: \(error.code.rawValue) - \(error.localizedDescription)")
            // Return mock data on network failure
            print("Using mock weather due to network error")
            return getMockWeather(for: city)
        } catch {
            print("Unexpected error: \(error)")
            print("Using mock weather due to error")
            return getMockWeather(for: city)
        }
    }
    
    private func getMockWeather(for city: String) -> WeatherData {
        let mockData: [String: WeatherData] = [
            "London": WeatherData(temperature: 12.5, condition: "Cloudy", humidity: 78, windSpeed: 15.2, icon: "03d"),
            "Paris": WeatherData(temperature: 15.0, condition: "Clear", humidity: 65, windSpeed: 12.0, icon: "01d"),
            "New York": WeatherData(temperature: 18.3, condition: "Sunny", humidity: 55, windSpeed: 18.5, icon: "01d"),
            "Tokyo": WeatherData(temperature: 22.0, condition: "Rain", humidity: 80, windSpeed: 10.0, icon: "10d"),
            "Berlin": WeatherData(temperature: 14.2, condition: "Overcast", humidity: 72, windSpeed: 14.0, icon: "04d"),
            "Rome": WeatherData(temperature: 24.5, condition: "Sunny", humidity: 60, windSpeed: 8.5, icon: "01d")
        ]
        
        return mockData[city] ?? WeatherData(temperature: 20.0, condition: "Partly Cloudy", humidity: 65, windSpeed: 12.0, icon: "02d")
    }
}

final class CurrencyApiService: CurrencyServiceProtocol {
    private let apiKey = "b3ed9dea1d4520f0914a9079"
    private let baseURL = "https://v6.exchangerate-api.com/v6"
    
    private let symbols = ["USD": "$", "EUR": "€", "GBP": "£", "JPY": "¥", "AUD": "A$", "CAD": "C$"]
    private let countryToCurrency = [
        "US": "USD", "GB": "GBP", "FR": "EUR", "DE": "EUR",
        "JP": "JPY", "CN": "CNY", "AU": "AUD", "CA": "CAD",
        "AE": "AED", "TH": "THB", "SG": "SGD"
    ]

    // MARK: - Models (Moved inside or kept at file scope)
    struct ExchangeRateResponse: Codable {
        let conversion_rates: [String: Double]
    }

    struct PairConversionResponse: Codable {
        let conversion_rate: Double
        let conversion_result: Double
    }

    func fetchCurrency(for countryCode: String) async throws -> CurrencyData {
        // 1. Get the correct currency code (e.g., "NOK" for "NO")
        let components = [NSLocale.Key.countryCode.rawValue: countryCode]
        let localeIdentifier = NSLocale.localeIdentifier(fromComponents: components)
        let locale = Locale(identifier: localeIdentifier)
        let destinationCurrency = locale.currency?.identifier ?? "USD"

        // 2. FETCH THE RATE FOR THAT SPECIFIC CURRENCY
        // Change "latest/USD" to "latest/\(destinationCurrency)"
        // OR fetch USD and look up the destination currency in the list.
        let urlString = "\(baseURL)/\(apiKey)/latest/USD"
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        
        // 3. Look up the rate for the destination (e.g., NOK)
        let rate = result.conversion_rates[destinationCurrency] ?? 1.0
        
        print("CurrencyAPI: 1 USD = \(rate) \(destinationCurrency)")

        return CurrencyData(
            code: destinationCurrency,
            name: locale.localizedString(forCurrencyCode: destinationCurrency) ?? destinationCurrency,
            rateToUSD: rate,
            symbol: locale.currencySymbol ?? "$"
        )
    }

    func convert(amount: Double, from: String, to: String) async throws -> ConversionResult {
        let urlString = "\(baseURL)/\(apiKey)/pair/\(from)/\(to)/\(amount)"
        print("💱 CurrencyAPI: Converting \(amount) \(from) to \(to)...")
        
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Use the struct name directly
        let response = try JSONDecoder().decode(PairConversionResponse.self, from: data)
        
        print("CurrencyAPI: Conversion Result: \(response.conversion_result)")
        
        return ConversionResult(
            fromCurrency: from,
            toCurrency: to,
            amount: amount,
            convertedAmount: response.conversion_result,
            rate: response.conversion_rate,
            timestamp: Date()
        )
    }
}


// 1. The clean model you use in your SwiftUI Views
struct Attraction: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let category: String

    // We provide a custom initializer so we can create these easily from the API response
    init(id: UUID = UUID(), name: String, address: String, category: String) {
        self.id = id
        self.name = name
        self.address = address
        self.category = category
    }
}


struct GeoapifyFeature: Codable {
    let properties: GeoapifyProperties
}

struct GeoapifyProperties: Codable {
    let name: String?
    let address_line2: String?
    let categories: [String]?
}



import Foundation

final class PlacesApiService: PlacesServiceProtocol {
    private let apiKey = "5ea7d5f6f2154557ae13f2b568261584" // Using your key from the other service
    
    func fetchInterestingPlaces(for city: String) async throws -> [Place] {
        print("PlacesAPI: Searching for \(city)...")
        
        // Step 1: Get Coordinates for the city name
        let geoURL = "https://api.geoapify.com/v1/geocode/search?text=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)&apiKey=\(apiKey)"
        
        guard let url = URL(string: geoURL) else { throw URLError(.badURL) }
        let (geoData, _) = try await URLSession.shared.data(from: url)
        let geoResponse = try JSONDecoder().decode(GeoapifyGeoResponse.self, from: geoData)
        
        guard let location = geoResponse.features.first?.properties else {
            print("PlacesAPI: Could not find coordinates for \(city)")
            return []
        }
        
        let lat = location.lat
        let lon = location.lon
        
        // Step 2: Get Sights near those coordinates
        let placesURL = "https://api.geoapify.com/v2/places?categories=tourism.sights&filter=circle:\(lon),\(lat),5000&limit=5&apiKey=\(apiKey)"
        
        guard let pUrl = URL(string: placesURL) else { throw URLError(.badURL) }
        let (pData, _) = try await URLSession.shared.data(from: pUrl)
        let pResponse = try JSONDecoder().decode(GeoapifyResponse.self, from: pData)
        
        print("PlacesAPI: Found \(pResponse.features.count) sights in \(city)")
        
        return pResponse.features.compactMap { feature -> Place? in
            guard let name = feature.properties.name, !name.isEmpty else { return nil }
            
            return Place(
                id: UUID().uuidString, // Maps to 'place_id' via CodingKeys
                name: name,
                description: feature.properties.address_line2 ?? "Popular attraction",
                rating: Double.random(in: 4.0...5.0),
                imageURL: "https://via.placeholder.com/150", // Maps to 'image_url'
                category: feature.properties.categories?.first ?? "Sights" // Maps to 'type'
            )
        }
    }
}

// MARK: - API Helper Models
struct GeoapifyGeoResponse: Codable {
    let features: [GeoFeature]
}
struct GeoFeature: Codable {
    let properties: GeoProps
}
struct GeoProps: Codable {
    let lat: Double
    let lon: Double
}

struct GeoapifyResponse: Codable {
    let features: [PlaceFeature]
}
struct PlaceFeature: Codable {
    let properties: PlaceProps
}
struct PlaceProps: Codable {
    let name: String?
    let address_line2: String?
    let categories: [String]?
}
