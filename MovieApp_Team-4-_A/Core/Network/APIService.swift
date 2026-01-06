import Foundation

class APIService {
    
    private let baseURL = "https://api.airtable.com/v0/appsfcB6YESLj4NCN"
    // INVALID_TOKEN
    private let token = "Bearer pat7E88yW3dgzlY61.2b7d03863aca9f1262dcb772f7728bd157e695799b43c7392d5faf4f52fcb001"
    
    // MARK: - Generic Helper
    private func performRequest<T: Decodable>(urlString: String, method: String = "GET", body: [String: Any]? = nil) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw APIError.unknown(error)
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.requestFailed(statusCode: 0)
            }
            
            // ERROR HANDLING LOGIC (Tests #2 & #3)
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                // Test #2: Session Expired
                throw APIError.unauthorized
            case 500...599:
                // Test #3: Server Error
                throw APIError.serverError
            default:
                // Test #3: 404 Not Found or other bad URL
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Server Error: \(errorString)")
                }
                throw APIError.requestFailed(statusCode: httpResponse.statusCode)
            }
            
            // Handle DELETE empty response case
            if method == "DELETE" && data.isEmpty {
                 // Return empty data if T allows, or handle specifically.
            }
            
            // Test #4: Decoding Error happens here if data doesn't match struct
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
            
        } catch let error as DecodingError {
            // Test #4: Explicitly catches data mismatch
            print("❌ Decoding Error: \(error)")
            throw APIError.decodingError
            
        } catch let error as APIError {
            // Catches errors thrown manually above (like .unauthorized)
            throw error
            
        } catch let error as URLError where error.code == .notConnectedToInternet {
            // Test #1: Explicitly catches No Internet
            // Wraps the system error so the UI says "The Internet connection appears to be offline."
            print("❌ Internet Connection Error: \(error.localizedDescription)")
            throw APIError.unknown(error)
            
        } catch {
            // Fallback for any other weird system errors
            throw APIError.unknown(error)
        }
    }
    
    // MARK: - Fetch Actors
    func fetchActors() async throws -> [ActorRecord] {
        let response: ActorResponse = try await performRequest(urlString: "\(baseURL)/actors")
        return response.records
    }
    
    // MARK: - Fetch Directors
    func fetchDirectors() async throws -> [DirectorRecord] {
        let response: DirectorResponse = try await performRequest(urlString: "\(baseURL)/directors")
        return response.records
    }
    
    // MARK: - Fetch Movies
    func fetchMovies() async throws -> [MovieRecord] {
        let response: MovieResponse = try await performRequest(urlString: "\(baseURL)/movies")
        return response.records
    }
    
    // MARK: - User & Profile
    func fetchProfileByEmail(email: String) async throws -> (user: UserRecord, savedMovies: [MovieRecord]) {
        var comps = URLComponents(string: "\(baseURL)/users")!
        comps.queryItems = [URLQueryItem(name: "filterByFormula", value: "LOWER({email})=LOWER(\"\(email)\")")]
        
        guard let urlString = comps.url?.absoluteString else { throw APIError.invalidURL }
        
        let userResponse: UserResponse = try await performRequest(urlString: urlString)
        
        guard let user = userResponse.records.first else {
            throw APIError.unknown(NSError(domain: "UserNotFound", code: 404))
        }
        
        let savedMovies = try await fetchSavedMovies(userRecordID: user.id)
        
        return (user: user, savedMovies: savedMovies)
    }
    
    // OPTIMIZED: Parallel Fetching
    func fetchSavedMovies(userRecordID: String) async throws -> [MovieRecord] {
        var comps = URLComponents(string: "\(baseURL)/saved_movies")!
        comps.queryItems = [URLQueryItem(name: "filterByFormula", value: "{user_id}=\"\(userRecordID)\"")]
        
        guard let urlString = comps.url?.absoluteString else { throw APIError.invalidURL }
        
        let response: SavedMoviesResponse = try await performRequest(urlString: urlString)
        let movieIDs = response.records.flatMap { $0.fields.movieID }
        
        if movieIDs.isEmpty { return [] }
        
        return try await withThrowingTaskGroup(of: MovieRecord.self) { group in
            for id in movieIDs {
                group.addTask {
                    return try await self.performRequest(urlString: "\(self.baseURL)/movies/\(id)")
                }
            }
            
            var movies: [MovieRecord] = []
            for try await movie in group {
                movies.append(movie)
            }
            return movies
        }
    }
    
    // MARK: - Reviews
    func fetchMovieReviews(movieId: String) async throws -> [ReviewRecord] {
        let filterFormula = "movie_id=\"\(movieId)\""
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
             throw APIError.invalidURL
        }
        
        let response: ReviewResponse = try await performRequest(urlString: "\(baseURL)/reviews?filterByFormula=\(encodedFilter)")
        return response.records.sorted { $0.createdTime > $1.createdTime }
    }
    
    func postReview(movieId: String, userId: String, text: String, rating: Int) async throws -> ReviewRecord {
        let body: [String: Any] = [
            "fields": [
                "review_text": text,
                "rate": rating,
                "movie_id": movieId,
                "user_id": userId
            ]
        ]
        
        return try await performRequest(urlString: "\(baseURL)/reviews", method: "POST", body: body)
    }
    
    // MARK: - Actions
    func saveMovie(userId: String, movieId: String) async throws -> String {
        let body: [String: Any] = [
            "fields": [
                "user_id": userId,
                "movie_id": [movieId]
            ]
        ]
        
        struct SaveResponse: Decodable { let id: String }
        let response: SaveResponse = try await performRequest(urlString: "\(baseURL)/saved_movies", method: "POST", body: body)
        return response.id
    }
    
    func unsaveMovie(savedMovieId: String) async throws {
        struct DeleteResponse: Decodable { let id: String; let deleted: Bool }
        let _: DeleteResponse = try await performRequest(urlString: "\(baseURL)/saved_movies/\(savedMovieId)", method: "DELETE")
    }
    
    func checkIfMovieSaved(userId: String, movieId: String) async throws -> String? {
        let filterFormula = "AND(user_id=\"\(userId)\",movie_id=\"\(movieId)\")"
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw APIError.invalidURL
        }
        
        struct GenericRecordResponse: Decodable {
            let records: [TempRecord]
            struct TempRecord: Decodable { let id: String }
        }
        
        let response: GenericRecordResponse = try await performRequest(urlString: "\(baseURL)/saved_movies?filterByFormula=\(encodedFilter)")
        return response.records.first?.id
    }

    // MARK: - User Updates
    func signInExistingUser(email: String, password: String) async throws -> UserRecord {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let response: UserResponse = try await performRequest(urlString: "\(baseURL)/users")
        
        guard let user = response.records.first(where: { $0.fields.email.lowercased() == cleanEmail }) else {
            throw APIError.unknown(NSError(domain: "Auth", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
        }
        return user
    }
    
    func updateUserProfile(recordID: String, name: String, email: String) async throws {
        let body: [String: Any] = ["fields": ["name": name, "email": email]]
        let _: UserRecord = try await performRequest(urlString: "\(baseURL)/users/\(recordID)", method: "PATCH", body: body)
    }
    
    func updateUserProfileImage(recordID: String, imageURL: String) async throws {
        let body: [String: Any] = ["fields": ["profile_image": imageURL]]
        let _: UserRecord = try await performRequest(urlString: "\(baseURL)/users/\(recordID)", method: "PATCH", body: body)
    }
    
    // MARK: - Junction Tables (Optimized)
    func fetchMovieActors(movieId: String) async throws -> [ActorRecord] {
        let filterFormula = "{movie_id}=\"\(movieId)\""
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw APIError.invalidURL }
        
        let response: MovieActorsResponse = try await performRequest(urlString: "\(baseURL)/movie_actors?filterByFormula=\(encodedFilter)")
        
        let actorIds = response.records.map { $0.fields.actor_id }
        if actorIds.isEmpty { return [] }
        
        return try await withThrowingTaskGroup(of: ActorRecord.self) { group in
            for actorId in actorIds {
                group.addTask {
                    return try await self.performRequest(urlString: "\(self.baseURL)/actors/\(actorId)")
                }
            }
            var actors: [ActorRecord] = []
            for try await actor in group {
                actors.append(actor)
            }
            return actors
        }
    }
    
    func fetchMovieDirectors(movieId: String) async throws -> [DirectorRecord] {
        let filterFormula = "{movie_id}=\"\(movieId)\""
        guard let encodedFilter = filterFormula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw APIError.invalidURL }
        
        let response: MovieDirectorsResponse = try await performRequest(urlString: "\(baseURL)/movie_directors?filterByFormula=\(encodedFilter)")
        
        let directorIds = response.records.map { $0.fields.director_id }
        if directorIds.isEmpty { return [] }
        
        return try await withThrowingTaskGroup(of: DirectorRecord.self) { group in
            for directorId in directorIds {
                group.addTask {
                    return try await self.performRequest(urlString: "\(self.baseURL)/directors/\(directorId)")
                }
            }
            var directors: [DirectorRecord] = []
            for try await director in group {
                directors.append(director)
            }
            return directors
        }
    }
}
