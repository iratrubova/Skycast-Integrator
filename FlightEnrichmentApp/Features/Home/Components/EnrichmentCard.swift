//
//  EnrichmentCard.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//

import SwiftUI

struct EnrichmentCard: View {
    let flight: EnrichedFlight
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("\(flight.origin) → \(flight.destination)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(flight.departureDate, style: .date)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Weather Section
                if let weather = flight.weather {
                    WeatherCard(weather: weather)
                }
                
                // Currency Section
                if let currency = flight.currency, let conversion = flight.conversion {
                    CurrencyCard(currency: currency, conversion: conversion)
                }
                
                // Places Section
                if let places = flight.places {
                    PlacesCard(places: places)
                }
            }
            .padding()
        }
    }
}

struct WeatherCard: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather Forecast", systemImage: "cloud.sun.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("\(Int(weather.temperature))°")
                        .font(.system(size: 48, weight: .thin))
                    
                    Text(weather.condition)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Label("\(weather.humidity)%", systemImage: "humidity")
                    Label("\(Int(weather.windSpeed)) km/h", systemImage: "wind")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

struct CurrencyCard: View {
    let currency: CurrencyData
    let conversion: ConversionResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Currency & Exchange", systemImage: "coloncurrencysign.circle.fill")
                .font(.headline)
                .foregroundColor(.green)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(currency.symbol)\(Int(conversion.amount)) \(conversion.fromCurrency)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("=")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.2f", conversion.convertedAmount)) \(conversion.toCurrency)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("1:\(String(format: "%.2f", conversion.rate))")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            
            Text("Local currency: \(currency.name) (\(currency.code))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(16)
    }
}

struct PlacesCard: View {
    let places: [Place]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Must Visit Places", systemImage: "star.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            ForEach(places.prefix(3)) { place in
                PlaceRow(place: place)
                
                if place.id != places.prefix(3).last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
}

struct PlaceRow: View {
    let place: Place
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(place.category.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", place.rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    let sampleFlight = EnrichedFlight(
        id: UUID(),
        origin: "New York",
        destination: "Paris",
        departureDate: Date(),
        returnDate: nil,
        createdAt: Date(),
        weather: WeatherData(
            temperature: 22.5,
            condition: "Partly Cloudy",
            humidity: 65,
            windSpeed: 12.5,
            icon: "02d"
        ),
        places: [
            Place(
                id: "1",
                name: "Eiffel Tower",
                description: "Iconic iron tower",
                rating: 4.8,
                imageURL: nil,
                category: "landmark"
            ),
            Place(
                id: "2",
                name: "Louvre Museum",
                description: "World's largest art museum",
                rating: 4.9,
                imageURL: nil,
                category: "museum"
            )
        ],
        currency: CurrencyData(
            code: "EUR",
            name: "Euro",
            rateToUSD: 1.08,
            symbol: "€"
        ),
        conversion: ConversionResult(
            fromCurrency: "EUR",
            toCurrency: "USD",
            amount: 100,
            convertedAmount: 108.0,
            rate: 1.08,
            timestamp: Date()
        )
    )
    
    EnrichmentCard(flight: sampleFlight)
}
