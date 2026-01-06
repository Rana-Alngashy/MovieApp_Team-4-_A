# 🎬 MovieApp

## **CRUD Operations & API Integration**

This project integrates with an **Airtable API** to manage **movie data, user profiles, bookmarks, and reviews**.  
Below is a breakdown of how the core **CRUD (Create, Read, Update, Delete)** operations are implemented within the app.

---

## **1. Create (POST)**

### **Write a Review**

Users can submit a new review for any movie.  
This is handled in `WriteReviewView` via the `apiService.postReview` function, which sends:

- **Movie ID**
- **User ID**
- **Review text**
- **Rating (scaled 1–10)**

The data is stored in the Airtable **`reviews`** table.

### **Bookmark a Movie**

When a user taps the bookmark icon in `MoviesDetailsView`, the app calls `apiService.saveMovie` to create a new record in the **`saved_movies`** table, linking:

- `currentUserId`
- `movieID`

---

## **2. Read (GET)**

### **Movies & Categories**

`MoviesCenterView` fetches all available movies using `apiService.fetchMovies`.  
The data is then:

- Filtered into categories such as **Highly Rated**
- Grouped by **genre**

### **Search & Filtering**

To ensure a snappy user experience, search is implemented using **Client-Side Filtering**:

The app fetches the movie dataset once.

As the user types in the search bar, the `MovieViewModel` filters the local array by **Movie** **Name** or **Actor**.

This avoids unnecessary API calls and provides instant, real-time results.

### **Movie Details & Cast**

When a movie is selected, `MoviesDetailsView` loads:

- Movie details
- Associated **actors** and **directors**

This is done by matching record IDs through `fetchActors` and `fetchDirectors`.

### **Reviews & Profile**

- Existing reviews for a selected movie are fetched from the API.  
- User profile data (including saved movies) is loaded using `fetchProfileByEmail`.

---

## **3. Update (PATCH)**

### **User Profile**

From the profile settings screen, users can update:

- Display name  
- Email address  

This uses `apiService.updateUserProfile`, which sends a **PATCH** request to Airtable, updating the user record **without changing the unique ID**.

---

## **4. Delete (DELETE)**

### **Remove Bookmark**

If a user taps the bookmark icon on a previously saved movie:

1. The app identifies the related record ID in the **`saved_movies`** table  
2. Calls `apiService.unsaveMovie` to delete the record  

---

## **Development Practices**

## **State Management & Navigation**

### **NavigationStack**

- Implemented using `NavigationPath` and `.navigationDestination`  
- Enables a decoupled navigation flow from:  
  - Movie grid → Movie details → Review screen  

### **Async / Await**

- All API calls use Swift’s modern concurrency model (`async/await`)  
- Ensures a responsive UI while fetching or posting data  

### **Callbacks**

- Completion closures (e.g. `onReviewAdded`) are used after **Create** and **Delete** actions  
- These trigger a fresh **Read** operation to immediately update the UI  

---

## **Data Integrity**

### **Codable Models**

- `User`, `Movie`, and `Review` models conform to **Codable** and **Sendable**  
- Ensures safe, accurate parsing of JSON responses  
- Improves reliability and thread safety across the app  
