//
//  APIService.swift
//  Movies
//
//  Created by Rana Alngashy on 06/07/1447 AH.
//
//

import Foundation

// MARK: - Actor Models
struct ActorResponse: Codable {
    let records: [ActorRecord]
}

struct ActorRecord: Codable, Identifiable {
    let id: String
    let fields: ActorFields
}

struct ActorFields: Codable {
    let name: String
    let image: String?
}

// MARK: - Director Models
struct DirectorResponse: Codable {
    let records: [DirectorRecord]
}

struct DirectorRecord: Codable, Identifiable {
    let id: String
    let fields: DirectorFields
}

struct DirectorFields: Codable {
    let name: String
    let image: String?
}

class APIService {
    
    private let baseURL = "https://api.airtable.com/v0/appsfcB6YESLj4NCN"
    private let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"
    
    // MARK: - Fetch Actors
    func fetchActors() async throws -> [ActorRecord] {
        guard let url = URL(string: "\(baseURL)/actors") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ActorResponse.self, from: data)
        return decoded.records
    }
    
    // MARK: - Fetch Directors
    func fetchDirectors() async throws -> [DirectorRecord] {
        guard let url = URL(string: "\(baseURL)/directors") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(DirectorResponse.self, from: data)
        return decoded.records
    }
    
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
   
    
//    Danyah
    
    // MARK: - Fetch Reviews for a Movie
    /// Fetches all reviews for a specific movie
    /// - Parameter movieId: The Airtable record ID of the movie
    /// - Returns: Array of ReviewRecord objects
    func fetchMovieReviews(movieId: String) async throws -> [ReviewRecord] {
        let filterFormula = "movie_id=\"\(movieId)\""
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/reviews?filterByFormula=\(encodedFilter)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ReviewResponse.self, from: data)
        return decoded.records
    }
    
    // MARK: - Post a Review
    /// Submits a new review for a movie
    /// - Parameters:
    ///   - movieId: The Airtable record ID of the movie
    ///   - userId: The Airtable record ID of the user
    ///   - text: The review text
    ///   - rating: The rating (1-10)
    /// - Returns: The created ReviewRecord
    func postReview(movieId: String, userId: String, text: String, rating: Int) async throws -> ReviewRecord {
        guard let url = URL(string: "\(baseURL)/reviews") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "fields": [
                "review_text": text,
                "rate": rating,
                "movie_id": movieId,
                "user_id": userId
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ReviewRecord.self, from: data)
        return decoded
    }
    
    // MARK: - Save Movie (Bookmark)
    /// Saves a movie to user's bookmarks
    /// - Parameters:
    ///   - userId: The Airtable record ID of the user
    ///   - movieId: The Airtable record ID of the movie
    /// - Returns: The created saved_movies record ID
    func saveMovie(userId: String, movieId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/saved_movies") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ⭐️ FIXED: Both user_id and movie_id must be arrays for linked records in Airtable
        let body: [String: Any] = [
            "fields": [
                "user_id": [userId],    // ⭐️ Array for linked record
                "movie_id": [movieId]   // ⭐️ Array for linked record
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // ⭐️ DEBUG: Print what we're sending
        print("DEBUG saveMovie - userId: \(userId)")
        print("DEBUG saveMovie - movieId: \(movieId)")
        print("DEBUG saveMovie - body: \(body)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // ⭐️ DEBUG: Print the response
        if let responseString = String(data: data, encoding: .utf8) {
            print("DEBUG saveMovie - response: \(responseString)")
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG saveMovie - status code: \(httpResponse.statusCode)")
        }
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let recordId = json?["id"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return recordId
    }
    
    // MARK: - Unsave Movie (Remove Bookmark)
    /// Removes a movie from user's bookmarks
    /// - Parameter savedMovieId: The Airtable record ID of the saved_movies entry
    func unsaveMovie(savedMovieId: String) async throws {
        guard let url = URL(string: "\(baseURL)/saved_movies/\(savedMovieId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Check if Movie is Saved
    /// Checks if a movie is in user's bookmarks
    /// - Parameters:
    ///   - userId: The Airtable record ID of the user
    ///   - movieId: The Airtable record ID of the movie
    /// - Returns: The saved_movies record ID if saved, nil otherwise
    func checkIfMovieSaved(userId: String, movieId: String) async throws -> String? {
        let filterFormula = "AND(user_id=\"\(userId)\",movie_id=\"\(movieId)\")"
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/saved_movies?filterByFormula=\(encodedFilter)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let records = json?["records"] as? [[String: Any]],
              let firstRecord = records.first,
              let recordId = firstRecord["id"] as? String else {
            return nil
        }
        
        return recordId
    }

}
