//
//  APIService.swift
//  Movies
//
//  Created by Rana Alngashy on 06/07/1447 AH.
//
import Foundation

class APIService {

    private let baseURL = "https://api.airtable.com/v0/appsfcB6YESLj4NCN"
    private let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"

    func fetchMovies() async throws -> [MovieRecord] {
        guard let url = URL(string: "\(baseURL)/movies") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decoded.records
    }
    // MARK: - ADD YOUR FUNCTIONS BELOW THIS

}
