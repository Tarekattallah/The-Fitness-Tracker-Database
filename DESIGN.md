The Fitness Tracker Database

Name: Al-Tarek Mohamed Al-Saied

GitHub: https://github.com/Tarekattallah

edX: https://profile.edx.org/u/TarekAttallah

City, Country: Cairo, Egypt

Video overview: <https://youtu.be/iHNiHi7b11M>

Scope
The purpose of this database is to function as the backend for a personal fitness tracking application called "FitTrack." The application aims to help individuals log their resistance training sessions, track their progress over time, and monitor changes in their body composition. It replaces the traditional "pen and paper" logbook with a structured, queryable digital format.

Included in Scope
Users: The system supports multiple users, allowing each to maintain their own private logs and history.

Exercises: A comprehensive library of movements (e.g., Bench Press, Squat) categorized by muscle group and equipment.

Workouts: The specific sessions performed by a user on a given date and time.

Sets: The granular details of a workout, including the weight lifted, repetitions performed, and the intensity (RPE).

Body Measurements: Tracking of user metrics such as body weight and body fat percentage over time.

Outside of Scope
Nutrition: Tracking calories, macronutrients, or meal plans is not included in this version.

Social Networking: Users cannot "follow" each other, share workouts, or compete on leaderboards in this iteration.

Payment/Subscription: There is no schema implementation for billing or premium membership tiers.

Inventory: The database does not track gym equipment availability or maintenance.

Functional Requirements
What a user should be able to do
Create an Account: Register a new user profile with a username and email.

Manage Exercises: Add new custom exercises to the database if they do not already exist in the standard library.

Log Workouts: Create a new workout session and record the start and end times.

Record Sets: Input detailed data for each set performed during a workout, including the specific exercise, weight (in kg), repetitions, and Rate of Perceived Exertion (RPE).

Track Body Metrics: Log daily or weekly body weight and body fat percentage.

View Progress: Query the database to see the history of a specific exercise (e.g., "Show me all my Bench Press sets from last month") to visualize strength progression.

Calculate Personal Records: Retrieve the maximum weight lifted for any given exercise.

What is beyond the scope
Real-time Heart Rate Monitoring: The database is not designed to ingest high-frequency time-series data from wearable devices.

Complex Scheduling: Users cannot set up recurring calendar invites or push notifications for future workouts within the database layer.

Automated Coaching: The system does not generate workout plans automatically based on user performance; it simply logs what was done.

Representation
Entities
The database consists of the following key entities:

1. Users
Attributes: id, username, email, password_hash, created_at.

Type Choices: TEXT is used for username and email. password_hash is stored as TEXT to accommodate hashed strings (e.g., bcrypt). DATETIME is used for created_at to track account age.

Constraints: username and email must be UNIQUE to prevent duplicate accounts.

2. Exercises
Attributes: id, name, muscle_group, equipment.

Type Choices: TEXT for all attributes as they are descriptive labels.

Constraints: name is UNIQUE to avoid having "Bench Press" and "bench press" as two different entries. muscle_group has a CHECK constraint to restrict inputs to valid anatomical categories (e.g., 'Chest', 'Legs', 'Back').

3. Workouts
Attributes: id, user_id, start_time, end_time, notes.

Type Choices: DATETIME for start and end times to allow for precise duration calculations. TEXT for notes to allow users to journal about their energy levels or mood.

Constraints: user_id is a foreign key referencing users(id).

4. Sets
Attributes: id, workout_id, exercise_id, reps, weight, rpe.

Type Choices: INTEGER for reps. REAL (or DECIMAL) for weight, as gym plates often come in 1.25kg or 2.5kg increments. INTEGER for RPE (Rate of Perceived Exertion).

Constraints: rpe has a CHECK constraint to ensure values are between 1 and 10. Foreign keys link to workouts and exercises.

5. Body_Measurements
Attributes: id, user_id, date, weight, body_fat_perc.

Type Choices: REAL for weight and body fat percentage for precision.

Constraints: user_id links to the users table.

Relationships
The entity relationship diagram below illustrates the connections between the tables:

Code snippet
erDiagram
    Users ||--o{ Workouts : "logs"
    Users ||--o{ Body_Measurements : "tracks"
    Workouts ||--|{ Sets : "contains"
    Exercises ||--o{ Sets : "defines"

    Users {
        int id PK
        string username
        string email
    }

    Workouts {
        int id PK
        int user_id FK
        datetime start_time
    }

    Sets {
        int id PK
        int workout_id FK
        int exercise_id FK
        int reps
        float weight
        int rpe
    }

    Exercises {
        int id PK
        string name
        string muscle_group
    }
Users to Workouts: A one-to-many relationship. A single user can log many workouts, but a workout belongs to only one user.

Workouts to Sets: A one-to-many relationship. A workout consists of multiple sets (e.g., 3 sets of Squats, 3 sets of Bench Press).

Exercises to Sets: A one-to-many relationship. A specific exercise (e.g., "Deadlift") can be performed in many different sets across many different workouts by many users.

Users to Body_Measurements: A one-to-many relationship. One user has many measurement logs over time.

Optimizations
I have implemented the following optimizations to ensure the database remains performant as the dataset grows:

Index on Foreign Keys: Indexes have been created on workouts(user_id) and sets(workout_id). Since the most common queries will involve filtering by a specific user or retrieving details for a specific workout, these indexes prevent full table scans.

Index on Searchable Text: An index on exercises(name) facilitates the rapid lookup of exercises when a user is searching the library to add a movement to their workout.

View for Progress: A view named v_user_personal_records was created. This view pre-aggregates the maximum weight lifted for each exercise per user. This avoids having to run expensive aggregate queries (MAX()) on the massive sets table every time a user visits their profile summary.

Limitations
Despite the robust design, there are inherent limitations:

Supersets and Circuits: The current design treats each set as a discrete, sequential event. It does not natively support "Supersets" (linking two different exercises together without rest) in a way that allows for accurate duration tracking between those specific linked sets.

Unit Conversion: The database stores weight in a raw numerical format (assumed to be kg). It does not natively handle conversions between Imperial (lbs) and Metric (kg). If a user switches preferences, the application layer must handle the conversion logic, as the database simply stores the float value.

Equipment Specifics: While the exercises table lists generic equipment, it does not account for variations in equipment weight (e.g., a 20kg barbell vs. a 15kg barbell). The user is expected to input the total weight.
