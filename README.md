# FitTrack Database

Backend database for a personal fitness tracking application focused on resistance training, strength progression, and basic body composition monitoring.

**Purpose**  
Replace the traditional paper workout log with a structured, queryable digital system that helps users record workouts, track progress, and monitor body metrics over time.

- **Owner**: Al-Tarek Mohamed Al-Saied  
- **Location**: Cairo, Egypt  
- **Video Overview**: [https://youtu.be/iHNiHi7b11M](https://youtu.be/iHNiHi7b11M)  
- **Detailed Design**: [DESIGN.md](./DESIGN.md)

## Key Features

- Multi-user support (each user's data is completely private)
- Extensible exercise library (name, muscle group, equipment)
- Workout session logging (start/end time + notes)
- Detailed set recording: exercise, weight (kg), reps, RPE
- Body measurement tracking (weight, body fat percentage)
- Personal Records (PR) calculation — heaviest weight per exercise per user
- Fast queries for progress analysis (e.g. "Bench Press last 30 days")

## Out of Scope (Current Version)

- Nutrition / calorie / macro tracking
- Social features (sharing, following, leaderboards)
- Automatic program generation or smart coaching
- Real-time wearable integration (heart rate, etc.)

## Core Schema

| Table                | Purpose                               | Key Fields                                  |
|----------------------|---------------------------------------|---------------------------------------------|
| `users`              | User accounts                         | id, username, email, password_hash          |
| `exercises`          | Exercise catalog                      | id, name, muscle_group, equipment           |
| `workouts`           | Training sessions                     | id, user_id, start_time, end_time, notes    |
| `sets`               | Individual sets                       | id, workout_id, exercise_id, reps, weight, rpe |
| `body_measurements`  | Body composition logs                 | id, user_id, date, weight, body_fat_perc    |

### Main Relationships

- User → Workouts           (1 : many)
- Workout → Sets            (1 : many)
- Exercise → Sets           (1 : many)
- User → Body Measurements  (1 : many)

## Optimizations Already Implemented

- Indexes on frequently filtered columns (`user_id`, `workout_id`, `exercises.name`)
- Materialized view: `v_user_personal_records` for fast PR lookups
- Constraints (RPE 1–10, unique exercise names, etc.)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/Tarekattallah/FitTrack-Database.git
cd FitTrack-Database

# Create the database (SQLite example)
sqlite3 fittrack.db < schema.sql

# Optional: load sample data
sqlite3 fittrack.db < seed.sql
