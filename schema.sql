-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- 1. USERS TABLE
-- Represents the individuals using the application.
-- We store basic profile info. 'username' and 'email' must be unique to prevent duplicates.
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL, -- Storing hash, never plain text
    joined_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. EXERCISES TABLE
-- Acts as the central library of available movements (e.g., Bench Press, Squat).
-- 'muscle_group' is restricted to specific categories to ensure consistent data for filtering.
CREATE TABLE exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    muscle_group TEXT CHECK(muscle_group IN ('Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio', 'Full Body')),
    equipment TEXT -- e.g., 'Barbell', 'Dumbbell', 'Machine', 'Bodyweight'
);

-- 3. WORKOUTS TABLE
-- Represents a single training session performed by a user.
-- It links a user to a specific point in time.
CREATE TABLE workouts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME,
    notes TEXT, -- User can write "Felt tired" or "Great energy"
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. SETS TABLE
-- The core data point. Represents one set of a specific exercise within a workout.
-- Includes details like weight, reps, and RPE (Rate of Perceived Exertion).
CREATE TABLE sets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    workout_id INTEGER,
    exercise_id INTEGER,
    set_number INTEGER, -- Order of the set in the exercise (1st set, 2nd set, etc.)
    reps INTEGER CHECK(reps > 0),
    weight REAL CHECK(weight >= 0), -- weight in kg or lbs
    rpe INTEGER CHECK(rpe BETWEEN 1 AND 10), -- 1 (easy) to 10 (max effort)
    FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)
);

-- 5. BODY_MEASUREMENTS TABLE
-- Tracks the user's physical progress over time (weight, body fat).
CREATE TABLE body_measurements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    body_weight REAL, -- in kg or lbs
    body_fat_percentage REAL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- INDEXES
-- Optimizations to speed up common searches.

-- 1. Index on workouts by user
-- Reason: The most common query will be "Show me User X's workout history".
CREATE INDEX idx_workouts_user_id ON workouts(user_id);

-- 2. Index on sets by workout
-- Reason: When loading a workout detail page, we need to quickly fetch all sets belonging to that workout ID.
CREATE INDEX idx_sets_workout_id ON sets(workout_id);

-- 3. Index on exercise names
-- Reason: Users will frequently search for exercises by name (e.g., "Bench...") to add them to a workout.
CREATE INDEX idx_exercises_name ON exercises(name);

-- 4. Index on sets by exercise
-- Reason: Required for analytical queries like "Show me progress on Bench Press over time".
CREATE INDEX idx_sets_exercise_id ON sets(exercise_id);


-- VIEWS
-- Virtual tables to simplify complex queries.

-- 1. User Personal Records (PRs) View
-- This view automatically calculates the heaviest weight lifted for each exercise by every user.
-- It joins sets, workouts, and exercises to provide a clean summary.
CREATE VIEW user_personal_records AS
SELECT
    w.user_id,
    u.username,
    e.name AS exercise_name,
    MAX(s.weight) AS max_weight_lifted
FROM sets s
JOIN workouts w ON s.workout_id = w.id
JOIN exercises e ON s.exercise_id = e.id
JOIN users u ON w.user_id = u.id
GROUP BY w.user_id, e.id;
