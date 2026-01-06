//
//  APIService.swift
//  Movies
//
//  Created by Rana Alngashy on 06/07/1447 AH.
//
//

import Foundation

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
    
    // ✅ View profile
    func fetchProfileByEmail(email: String) async throws
    -> (user: UserRecord, savedMovies: [MovieRecord]) {
        
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
        
        let savedMovies = try await fetchSavedMovies(userRecordID: user.id)
        
        return (user: user, savedMovies: savedMovies)
    }
    
    // ✅ Fetch saved movies
    func fetchSavedMovies(userRecordID: String) async throws -> [MovieRecord] {
        
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
        
        let movieIDs = decoded.records.flatMap { $0.fields.movieID }
        if movieIDs.isEmpty { return [] }
        
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
   
    // MARK: - Fetch Reviews for a Movie
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
        
        // ⭐️ SORTED: Sorts reviews by createdTime (Newest > Oldest)
        return decoded.records.sorted { $0.createdTime > $1.createdTime }
    }
    
    // MARK: - Post a Review
    func postReview(movieId: String, userId: String, text: String, rating: Int) async throws -> ReviewRecord {
        guard let url = URL(string: "\(baseURL)/reviews") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // ⭐️ Using Strings for IDs (matching your Postman)
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
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if let responseString = String(data: data, encoding: .utf8) {
                print("❌ Airtable Error Response: \(responseString)")
            }
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ReviewRecord.self, from: data)
        return decoded
    }
    
    // MARK: - Save Movie (Bookmark)
    func saveMovie(userId: String, movieId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/saved_movies") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "fields": [
                "user_id": userId,
                "movie_id": [movieId]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let recordId = json?["id"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return recordId
    }
    
    // MARK: - Unsave Movie
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
    
    // MARK: - Sign In
    func signInExistingUser(email: String, password: String) async throws -> UserRecord {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let url = URL(string: "\(baseURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(UserResponse.self, from: data)

        guard let user = decoded.records.first(where: {
            $0.fields.email.lowercased() == cleanEmail
        }) else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }
    
    // MARK: - Update Profile
    func updateUserProfile(recordID: String, name: String, email: String) async throws {
        let url = URL(string: "\(baseURL)/users/\(recordID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["fields": ["name": name, "email": email]]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    func updateUserProfileImage(recordID: String, imageURL: String) async throws {
        let url = URL(string: "\(baseURL)/users/\(recordID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["fields": ["profile_image": imageURL]]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Fetch Movie Actors
    func fetchMovieActors(movieId: String) async throws -> [ActorRecord] {
        let filterFormula = "{movie_id}=\"\(movieId)\""
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/movie_actors?filterByFormula=\(encodedFilter)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        let decoded = try JSONDecoder().decode(MovieActorsResponse.self, from: data)
        let actorIds = decoded.records.map { $0.fields.actor_id }
        if actorIds.isEmpty { return [] }
        
        var actors: [ActorRecord] = []
        for actorId in actorIds {
            let actorUrl = URL(string: "\(baseURL)/actors/\(actorId)")!
            var actorRequest = URLRequest(url: actorUrl)
            actorRequest.httpMethod = "GET"
            actorRequest.setValue(token, forHTTPHeaderField: "Authorization")
            
            let (actorData, actorResponse) = try await URLSession.shared.data(for: actorRequest)
            guard (actorResponse as? HTTPURLResponse)?.statusCode == 200 else { continue }
            
            let actor = try JSONDecoder().decode(ActorRecord.self, from: actorData)
            actors.append(actor)
        }
        return actors
    }
    
    // MARK: - Fetch Movie Directors
    func fetchMovieDirectors(movieId: String) async throws -> [DirectorRecord] {
        let filterFormula = "{movie_id}=\"\(movieId)\""
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/movie_directors?filterByFormula=\(encodedFilter)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        
        let decoded = try JSONDecoder().decode(MovieDirectorsResponse.self, from: data)
        let directorIds = decoded.records.map { $0.fields.director_id }
        if directorIds.isEmpty { return [] }
        
        var directors: [DirectorRecord] = []
        for directorId in directorIds {
            let directorUrl = URL(string: "\(baseURL)/directors/\(directorId)")!
            var directorRequest = URLRequest(url: directorUrl)
            directorRequest.httpMethod = "GET"
            directorRequest.setValue(token, forHTTPHeaderField: "Authorization")
            
            let (directorData, directorResponse) = try await URLSession.shared.data(for: directorRequest)
            guard (directorResponse as? HTTPURLResponse)?.statusCode == 200 else { continue }
            
            let director = try JSONDecoder().decode(DirectorRecord.self, from: directorData)
            directors.append(director)
        }
        return directors
    }
}
