-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- 1. INSERTING DATA
-- -----------------

-- Add a new user to the database
-- This query runs when a user signs up.
INSERT INTO users (first_name, last_name, username, email, password_hash)
VALUES ('Tarek', 'Attallah', 'tarek_a', 'tarek@example.com', 'hashed_secret_password');

-- Add a new workout session
-- This query runs when a user starts a new workout (e.g., "Leg Day").
INSERT INTO workouts (user_id, start_time, notes)
VALUES (1, '2026-02-16 18:00:00', 'Feeling strong today, aiming for a PR on squats.');

-- Add sets to the workout (assuming workout_id = 1)
-- This happens as the user logs their sets in real-time.
-- Example: Adding 3 sets of Squats (Exercise ID 1).
INSERT INTO sets (workout_id, exercise_id, set_number, reps, weight, rpe)
VALUES
    (1, 1, 1, 10, 100.0, 7), -- Warm-up set
    (1, 1, 2, 8, 120.0, 8),  -- Working set 1
    (1, 1, 3, 5, 140.0, 9);  -- Working set 2 (Heavy)

-- Add a body measurement log
-- Users track their weight weekly.
INSERT INTO body_measurements (user_id, body_weight, body_fat_percentage)
VALUES (1, 85.5, 15.0);


-- 2. READING DATA (SELECT)
-- ------------------------

-- Get all workouts for a specific user (Workout History)
-- This is used to populate the "History" tab in the app.
SELECT id, start_time, notes
FROM workouts
WHERE user_id = 1
ORDER BY start_time DESC;

-- Get detailed view of a specific workout
-- This runs when a user clicks on a workout in their history to see what they did.
SELECT
    e.name AS exercise_name,
    s.set_number,
    s.reps,
    s.weight,
    s.rpe
FROM sets s
JOIN exercises e ON s.exercise_id = e.id
WHERE s.workout_id = 1
ORDER BY s.exercise_id, s.set_number;

-- Find Personal Records (PR) for a specific exercise
-- Uses the VIEW we created in schema.sql to quickly show the user's max lift.
SELECT max_weight_lifted
FROM user_personal_records
WHERE user_id = 1 AND exercise_name = 'Squat';

-- Calculate total volume (Sets * Reps * Weight) for a workout
-- This is a common metric to track work capacity.
SELECT SUM(reps * weight) as total_volume_kg
FROM sets
WHERE workout_id = 1;

-- Search for an exercise by name
-- Used in the search bar when adding an exercise to a workout.
SELECT * FROM exercises
WHERE name LIKE '%Bench%';


-- 3. UPDATING DATA
-- ----------------

-- Update a set's weight (e.g., user made a typo)
UPDATE sets
SET weight = 145.0
WHERE id = 3;

-- Finish a workout (Set the end time)
-- Runs when the user hits "Finish Workout".
UPDATE workouts
SET end_time = CURRENT_TIMESTAMP
WHERE id = 1;


-- 4. DELETING DATA
-- ----------------

-- Delete a workout
-- If a user accidentally created a workout or wants to remove it.
-- Note: Because of ON DELETE CASCADE in schema.sql, this will also delete all associated sets automatically.
DELETE FROM workouts
WHERE id = 1;





