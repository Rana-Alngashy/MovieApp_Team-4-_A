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
    // ✅ View profile (name, email, profile image, saved movies) using email
    func fetchProfileByEmail(email: String) async throws
    -> (user: UserRecord, savedMovies: [MovieRecord]) {

        // 1) fetch user by email
        var comps = URLComponents(string: "\(baseURL)/users")!
        comps.queryItems = [
            URLQueryItem(
                name: "filterByFormula",
                value: "LOWER({email})=LOWER(\"\(email)\")"
            )
        ]

        var request = URLRequest(url: comps.url!)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(UserResponse.self, from: data)
        guard let user = decoded.records.first else {
            throw URLError(.cannotParseResponse)
        }

        // 👉 PUT THIS LINE RIGHT HERE
        let savedMovies = try await fetchSavedMovies(userRecordID: user.id)

        // 3) return both
        return (user: user, savedMovies: savedMovies)
    }

    // ✅ Fetch saved movies for a user (by Airtable user record id)
    func fetchSavedMovies(userRecordID: String) async throws -> [MovieRecord] {

        // 1) Get rows from saved_movies for this user
        var comps = URLComponents(string: "\(baseURL)/saved_movies")!
        comps.queryItems = [
            URLQueryItem(name: "filterByFormula", value: "{user_id}=\"\(userRecordID)\"")
        ]

        var request = URLRequest(url: comps.url!)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(SavedMoviesResponse.self, from: data)

        // 2) Collect movie record IDs
        let movieIDs = decoded.records.flatMap { $0.fields.movieID }
        if movieIDs.isEmpty { return [] }

        // 3) Fetch each movie by record ID from /movies/{id}
        var movies: [MovieRecord] = []
        movies.reserveCapacity(movieIDs.count)

        for id in movieIDs {
            let url = URL(string: "\(baseURL)/movies/\(id)")!
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue(token, forHTTPHeaderField: "Authorization")

            let (mdata, mresp) = try await URLSession.shared.data(for: req)
            guard let mhttp = mresp as? HTTPURLResponse, (200...299).contains(mhttp.statusCode) else {
                throw URLError(.badServerResponse)
            }

            movies.append(try JSONDecoder().decode(MovieRecord.self, from: mdata))
        }

        return movies
    }

   
}
