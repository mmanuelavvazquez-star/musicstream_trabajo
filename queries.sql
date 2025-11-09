
SET search_path TO bd030_schema21 ;



--INTERROGACIONES

--1
-- Select the song title and the number of times it was played this month
SELECT s.song_title, COUNT(*) AS plays_this_month
FROM play_history ph
-- Join the play history with the song table to get song titles
INNER JOIN song s ON ph.song_id = s.song_id
-- Only include plays from the current month
WHERE DATE_TRUNC('month', ph.play_date) = DATE_TRUNC('month', CURRENT_DATE)
-- Group by song title to count plays per song
GROUP BY s.song_title
-- Order the results by number of plays in descending order
ORDER BY plays_this_month DESC
-- Limit the result to the top 5 most played songs
LIMIT 5;



--2
-- Select users who have not played any songs in the last 30 days
SELECT u.user_nick
FROM users u
-- Left join with play_history to include all users, even those with no plays
LEFT JOIN play_history ph ON u.user_id = ph.user_id
-- Group by user to aggregate their play history
GROUP BY u.user_id
-- Only include users whose latest play was more than 30 days ago, or who have never played
HAVING MAX(ph.play_date) < CURRENT_DATE - INTERVAL '30 days' 
       OR MAX(ph.play_date) IS NULL;




--3
-- Calculate the average duration of songs for each genre
SELECT g.genre_name, ROUND(AVG(s.song_duration), 2) AS avg_duration
FROM song s
-- Join with song_genre to link songs to their genres
INNER JOIN song_genre sg ON s.song_id = sg.song_id
-- Join with genre table to get genre names
INNER JOIN genre g ON g.genre_id = sg.genre_id
-- Group results by genre to calculate the average duration per genre
GROUP BY g.genre_name
-- Order the results by average duration in descending order (longest first)
ORDER BY avg_duration DESC;




--4
-- Count the number of playlists created by users in each country
SELECT u.country, COUNT(p.playlist_id) AS total_playlists
FROM playlist p
-- Join with users to get the country of each playlist creator
JOIN users u ON u.user_id = p.user_id
-- Group results by country to count playlists per country
GROUP BY u.country
-- Order the results by total number of playlists in descending order
ORDER BY total_playlists DESC;




--5
-- Select songs that have been played by users from more than 5 countries
SELECT s.song_title, COUNT(DISTINCT u.country) AS countries_count
FROM play_history ph
-- Join with song table to get song titles
JOIN song s ON ph.song_id = s.song_id
-- Join with users table to get the country of each user
JOIN users u ON ph.user_id = u.user_id
-- Group by song to count distinct countries per song
GROUP BY s.song_title
-- Only include songs played by users from more than 5 different countries
HAVING COUNT(DISTINCT u.country) > 5
-- Order results by the number of countries in descending order
ORDER BY countries_count DESC;


--6
-- Select users with the most played songs
SELECT u.user_nick, COUNT(ph.playback_id) AS total_play
FROM users AS u
-- Join with play_history to count each playback per user
INNER JOIN play_history ph ON u.user_id = ph.user_id
-- Group by user nickname to aggregate total plays per user
GROUP BY u.user_nick
-- Order the results by total plays in ascending order (least to most)
ORDER BY total_play ASC;


--7
-- Select users who have an active subscription
SELECT u.user_nick, sp.subscription_name, sp.duration_months, sp.price
FROM users u
-- Join with user_premium to link users with their subscription plans
JOIN user_premium up ON u.user_id = up.user_id
-- Join with subscription_plan to get subscription details
JOIN subscription_plan sp ON up.subscription_id = sp.subscription_id
-- Only include subscriptions that are currently active
WHERE sp.subscription_status = 'Active';


--8
-- Select the most played song for each country
SELECT DISTINCT ON (u.country)
    u.country,
    s.song_title,
    COUNT(ph.playback_id) AS play_count
FROM play_history ph
-- Join with users to get the country of each playback
INNER JOIN users u ON ph.user_id = u.user_id
-- Join with song to get the song title
INNER JOIN song s ON ph.song_id = s.song_id
-- Group by country and song to count the number of plays per song per country
GROUP BY u.country, s.song_title
-- Order by country and number of plays in descending order
-- DISTINCT ON ensures only the top song per country is selected
ORDER BY u.country, play_count DESC;


--9
-- Select users and play dates where they listened to at least 3 different artists
SELECT 
    ph.user_id,
    ph.play_date,
    COUNT(DISTINCT sa.artist_id) AS distinct_artists
FROM play_history ph
-- Join with song_artist to find which artists are associated with each song
INNER JOIN song_artist sa ON sa.song_id = ph.song_id
-- Group by user and play date to count distinct artists per user per day
GROUP BY ph.user_id, ph.play_date
-- Only include records where the user listened to 3 or more distinct artists
HAVING COUNT(DISTINCT sa.artist_id) >= 3;




--10
-- Calculate the average listening duration per user
SELECT 
    u.user_id,
    u.user_nick,
    -- Average duration played per user, rounded to 2 decimal places
    ROUND(AVG(ph.duration_played), 2) AS avg_minutes_played,
    -- Total duration played by the user, rounded to 2 decimal places
    ROUND(SUM(ph.duration_played), 2) AS total_minutes,
    -- Total number of plays by the user
    COUNT(ph.playback_id) AS total_plays
FROM users u
-- Join with play_history to get all play records for each user
JOIN play_history ph ON u.user_id = ph.user_id
-- Group by user to aggregate plays and durations
GROUP BY u.user_nick, u.user_id
-- Order by average minutes played in descending order (most active users first)
ORDER BY avg_minutes_played DESC
-- Limit to the top 10 users
LIMIT 10;


--11
-- Compare the average listening duration across countries
SELECT 
    u.country,
    -- Average duration of songs played per country, rounded to 2 decimals
    ROUND(AVG(ph.duration_played), 2) AS avg_minutes,
    -- Total duration of songs played per country, rounded to 2 decimals
    ROUND(SUM(ph.duration_played), 2) AS total_minutes,
    -- Total number of plays per country
    COUNT(ph.playback_id) AS total_plays
FROM users u
-- Join with play_history to get all play records for each user
JOIN play_history ph ON u.user_id = ph.user_id
-- Group by country to aggregate listening stats per country
GROUP BY u.country
-- Order by average minutes played in descending order (countries with longest average listening first)
ORDER BY avg_minutes DESC;

-- Select songs along with the total number of times they have been played
SELECT 
    s.song_title,
    -- Count the number of playbacks per song
    COUNT(ph.playback_id) AS total_plays
FROM song s
-- Left join with play_history to include songs that may have never been played
LEFT JOIN play_history ph ON s.song_id = ph.song_id
-- Group by song title to aggregate play counts
GROUP BY s.song_title
-- Order by total plays in descending order (most played songs first)
ORDER BY total_plays DESC;



--12
-- Find who has listened to the song "Selena Gomez 44"
SELECT DISTINCT
    s.song_title,
    u.user_nick,
    u.country,
    ph.play_date,
    ph.duration_played,
    ph.completed
FROM play_history ph
-- Join with users to get user information
JOIN users u ON ph.user_id = u.user_id
-- Join with songs to get song information
JOIN song s ON ph.song_id = s.song_id
-- Filter to only include plays of the song "Selena Gomez 44"
WHERE s.song_title = 'Selena Gomez 44'   
-- Order by play date in descending order (most recent plays first)
ORDER BY ph.play_date DESC;



--13
-- Calculate total listening time by device type and user subscription type
SELECT 
    d.device_type,
    -- Determine the user type based on their subscription
    CASE 
        WHEN up.user_id IS NOT NULL THEN 'Premium'  -- User has a premium subscription
        WHEN uf.user_id IS NOT NULL THEN 'Free'     -- User has a free subscription
        ELSE 'Unknown'                              -- User not found in either table
    END AS user_type,
    -- Sum of duration played per device and user type, rounded to 2 decimals
    ROUND(SUM(ph.duration_played), 2) AS total_minutes_played
FROM play_history ph
-- Join with device table to get device type
JOIN device d ON ph.device_id = d.device_id
-- Left join with premium and free user tables to determine subscription type
LEFT JOIN user_premium up ON ph.user_id = up.user_id
LEFT JOIN user_free uf ON ph.user_id = uf.user_id
-- Group by device type and user type to aggregate listening time
GROUP BY d.device_type, user_type
-- Order by total minutes played in descending order (most active device/user types first)
ORDER BY total_minutes_played DESC;



--14
-- Select top 10 artists based on how many playlists their songs appear in
SELECT 
    a.artist_name,
    -- Count of distinct playlists that include the artist's songs
    COUNT(DISTINCT sp.playlist_id) AS playlists_count,
    -- Count of distinct songs by the artist that appear in playlists
    COUNT(DISTINCT s.song_id) AS total_songs_in_playlists
FROM song s
-- Join with song_artist to link songs to their artists
JOIN song_artist sa ON s.song_id = sa.song_id
JOIN artist a ON sa.artist_id = a.artist_id
-- Join with play_history to link songs to plays
JOIN play_history ph ON ph.song_id = s.song_id
-- Join with playlist to get playlist information
JOIN playlist sp ON sp.playlist_id = ph.playlist_id
-- Group by artist to aggregate playlist counts and song counts
GROUP BY a.artist_name
-- Order by number of playlists in descending order (most playlists first)
ORDER BY playlists_count DESC
-- Limit to top 10 artists
LIMIT 10;



--15
-- Select the top 10 songs played by users from the most unique countries
SELECT 
    s.song_title,
    -- Count of distinct countries where the song has been played
    COUNT(DISTINCT u.country) AS unique_countries
FROM play_history ph
-- Join with users to get the country of each user
JOIN users u ON ph.user_id = u.user_id
-- Join with songs to get song titles
JOIN song s ON ph.song_id = s.song_id
-- Group by song to aggregate counts of unique countries
GROUP BY s.song_title
-- Order by number of unique countries in descending order (most international songs first)
ORDER BY unique_countries DESC
-- Limit to top 10 songs
LIMIT 10;


--16
-- Select users whose nickname contains 'a', email ends with '.com', and date of birth is within a range
SELECT user_id, user_nick, first_name, surname, email, country, date_birth
FROM users
WHERE 
    -- User nickname contains the letter 'a'
    user_nick LIKE '%a%'                   
    -- Email ends with '.com'
    AND email LIKE '%.com'                  
    -- Date of birth between January 1, 1990 and December 31, 2000
    AND date_birth BETWEEN '1990-01-01' AND '2000-12-31'  
-- Order results by date of birth in ascending order
ORDER BY date_birth;

--17
-- Determine the type of a specific user (Free or Premium) given their nickname
SELECT 
    u.user_id, 
    u.user_nick,
    -- Determine user type based on which table they appear in
    CASE 
        WHEN up.user_id IS NOT NULL THEN 'Premium'  -- User exists in premium table
        WHEN uf.user_id IS NOT NULL THEN 'Free'     -- User exists in free table
        ELSE 'Unknown'                              -- User not found in either table
    END AS user_type
FROM users u
-- Left join with premium and free user tables to check subscription type
LEFT JOIN user_premium up ON u.user_id = up.user_id
LEFT JOIN user_free uf ON u.user_id = uf.user_id
-- Filter for the specific user by nickname
WHERE u.user_nick = 'nick_12';


--18
-- Select devices registered between two specific dates
SELECT 
    device_id,
    device_name,
    device_type,
    registration_date
FROM device
-- Filter devices whose registration date is between January 1, 2024, and January 1, 2025
WHERE registration_date BETWEEN '2024-01-01' AND '2025-01-01'
-- Order results by registration date in ascending order
ORDER BY registration_date;


--19
-- Calculate the average duration of songs by album type
SELECT 
    a.album_type,
    -- Average duration of songs in each album type, rounded to 2 decimals
    ROUND(AVG(s.song_duration), 2) AS avg_duration
FROM song s
-- Join with album table to get album type
JOIN album a ON s.album_id = a.album_id
-- Group by album type to calculate average duration per type
GROUP BY a.album_type
-- Only include album types that have songs (avoid NULL averages)
HAVING AVG(s.song_duration) IS NOT NULL
-- Order results by average duration in descending order (longest average first)
ORDER BY avg_duration DESC;

--20
-- Select songs that have a play count higher than the average of their album
SELECT DISTINCT 
    s.song_title,
    s.play_count,
    a.album_name
FROM song AS s
-- Join with album table to get album name
INNER JOIN album AS a ON s.album_id = a.album_id
-- Filter songs whose play count is greater than the average play count of songs in the same album
WHERE s.play_count > (
    SELECT AVG(s2.play_count)
    FROM song s2
    WHERE s2.album_id = s.album_id
)
-- Order results by play count in descending order (most popular songs first)
ORDER BY s.play_count DESC;


















