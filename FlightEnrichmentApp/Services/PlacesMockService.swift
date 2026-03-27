import Foundation

final class PlacesMockService: PlacesServiceProtocol {
    private let cityPlaces: [String: [Place]] = [
        "Paris": [
            Place(id: "1", name: "Eiffel Tower", description: "Iconic iron lattice tower", rating: 4.8, imageURL: nil, category: "Landmark"),
            Place(id: "2", name: "Louvre Museum", description: "World's largest art museum", rating: 4.9, imageURL: nil, category: "Museum"),
            Place(id: "3", name: "Notre-Dame", description: "Medieval Catholic cathedral", rating: 4.7, imageURL: nil, category: "Landmark"),
            Place(id: "4", name: "Arc de Triomphe", description: "Triumphal arch", rating: 4.6, imageURL: nil, category: "Monument"),
            Place(id: "5", name: "Montmartre", description: "Artistic hilltop district", rating: 4.5, imageURL: nil, category: "Neighborhood")
        ],
        "London": [
            Place(id: "1", name: "Big Ben", description: "Iconic clock tower", rating: 4.7, imageURL: nil, category: "Landmark"),
            Place(id: "2", name: "Tower of London", description: "Historic castle", rating: 4.6, imageURL: nil, category: "Castle"),
            Place(id: "3", name: "British Museum", description: "World history museum", rating: 4.8, imageURL: nil, category: "Museum"),
            Place(id: "4", name: "Buckingham Palace", description: "Royal residence", rating: 4.5, imageURL: nil, category: "Palace"),
            Place(id: "5", name: "London Eye", description: "Giant observation wheel", rating: 4.4, imageURL: nil, category: "Attraction")
        ],
        "New York": [
            Place(id: "1", name: "Statue of Liberty", description: "Iconic symbol of freedom", rating: 4.8, imageURL: nil, category: "Monument"),
            Place(id: "2", name: "Central Park", description: "Urban park", rating: 4.7, imageURL: nil, category: "Park"),
            Place(id: "3", name: "Empire State Building", description: "Art Deco skyscraper", rating: 4.6, imageURL: nil, category: "Landmark"),
            Place(id: "4", name: "Times Square", description: "Bright lights and theaters", rating: 4.5, imageURL: nil, category: "Entertainment"),
            Place(id: "5", name: "Brooklyn Bridge", description: "Historic suspension bridge", rating: 4.7, imageURL: nil, category: "Landmark")
        ],
        "Tokyo": [
            Place(id: "1", name: "Senso-ji Temple", description: "Ancient Buddhist temple", rating: 4.7, imageURL: nil, category: "Temple"),
            Place(id: "2", name: "Tokyo Tower", description: "Communications tower", rating: 4.5, imageURL: nil, category: "Landmark"),
            Place(id: "3", name: "Shibuya Crossing", description: "Busiest pedestrian crossing", rating: 4.6, imageURL: nil, category: "Landmark"),
            Place(id: "4", name: "Meiji Shrine", description: "Shinto shrine", rating: 4.8, imageURL: nil, category: "Shrine"),
            Place(id: "5", name: "Tsukiji Outer Market", description: "Food and seafood market", rating: 4.6, imageURL: nil, category: "Market")
        ],
        "Berlin": [
            Place(id: "1", name: "Brandenburg Gate", description: "Neoclassical monument", rating: 4.7, imageURL: nil, category: "Monument"),
            Place(id: "2", name: "Berlin Wall Memorial", description: "Historic wall remains", rating: 4.6, imageURL: nil, category: "Memorial"),
            Place(id: "3", name: "Museum Island", description: "UNESCO World Heritage site", rating: 4.8, imageURL: nil, category: "Museum"),
            Place(id: "4", name: "Reichstag Building", description: "Parliament building", rating: 4.5, imageURL: nil, category: "Government"),
            Place(id: "5", name: "Checkpoint Charlie", description: "Cold War landmark", rating: 4.4, imageURL: nil, category: "Landmark")
        ],
        "Rome": [
            Place(id: "1", name: "Colosseum", description: "Ancient amphitheater", rating: 4.9, imageURL: nil, category: "Ancient"),
            Place(id: "2", name: "Vatican Museums", description: "Art and history museums", rating: 4.8, imageURL: nil, category: "Museum"),
            Place(id: "3", name: "Trevi Fountain", description: "Baroque fountain", rating: 4.7, imageURL: nil, category: "Fountain"),
            Place(id: "4", name: "Pantheon", description: "Roman temple", rating: 4.8, imageURL: nil, category: "Temple"),
            Place(id: "5", name: "Spanish Steps", description: "Monumental stairway", rating: 4.6, imageURL: nil, category: "Landmark")
        ]
    ]
    
    func fetchInterestingPlaces(for city: String) async throws -> [Place] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if let places = cityPlaces[city] {
            return places
        }
        
        // Generic fallback - FIXED: added all parameters
        return [
            Place(id: "1", name: "\(city) City Center", description: "Main downtown area", rating: 4.5, imageURL: nil, category: "Downtown"),
            Place(id: "2", name: "Historic District", description: "Old town area", rating: 4.3, imageURL: nil, category: "Historic"),
            Place(id: "3", name: "Local Museum", description: "City museum", rating: 4.2, imageURL: nil, category: "Museum"),
            Place(id: "4", name: "Central Park", description: "Main city park", rating: 4.4, imageURL: nil, category: "Park"),
            Place(id: "5", name: "Popular Restaurant", description: "Local cuisine", rating: 4.6, imageURL: nil, category: "Food")
        ]
    }
}
