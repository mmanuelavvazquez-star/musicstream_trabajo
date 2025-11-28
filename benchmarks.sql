-- BENCHMARK OF SOME OF OUR QUERIES (1,2,3,4,5,6,8,9,10,14,16,18,20)
-- In order to analyze and measure the performance of the chosen queries, we are going to use the command EXPLAIN ANALYZE which will provide us with the necessary information about execution time, rows, costs... This will later be used to optimize the code

SET search_path TO bd030_schema21;

ANALYZE; -- This command updates the database's statistics 

--1
-- Select the song title and the number of times it was played this month
EXPLAIN ANALYZE
SELECT s.song_title, COUNT(*) AS plays_this_month
FROM play_history ph
INNER JOIN song s ON ph.song_id = s.song_id
WHERE DATE_TRUNC('month', ph.play_date) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY s.song_title
ORDER BY plays_this_month DESC
LIMIT 5;

--2
-- Select users who have not played any songs in the last 30 days
EXPLAIN ANALYZE
SELECT u.user_nick
FROM users u
LEFT JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.user_id
HAVING MAX(ph.play_date) < CURRENT_DATE - INTERVAL '30 days' 
       OR MAX(ph.play_date) IS NULL;

--3
-- Calculate the average duration of songs for each genre
EXPLAIN ANALYZE
SELECT g.genre_name, ROUND(AVG(s.song_duration), 2) AS avg_duration
FROM song s
INNER JOIN song_genre sg ON s.song_id = sg.song_id
INNER JOIN genre g ON g.genre_id = sg.genre_id
GROUP BY g.genre_name
ORDER BY avg_duration DESC;

--4
-- Count the number of playlists created by users in each country
EXPLAIN ANALYZE
SELECT u.country, COUNT(p.playlist_id) AS total_playlists
FROM playlist p
JOIN users u ON u.user_id = p.user_id
GROUP BY u.country
ORDER BY total_playlists DESC;

--5
-- Select songs that have been played by users from more than 5 countries
EXPLAIN ANALYZE
SELECT s.song_title, COUNT(DISTINCT u.country) AS countries_count
FROM play_history ph
JOIN song s ON ph.song_id = s.song_id
JOIN users u ON ph.user_id = u.user_id
GROUP BY s.song_title
HAVING COUNT(DISTINCT u.country) > 5
ORDER BY countries_count DESC;

--6
-- Select users with the most played songs
EXPLAIN ANALYZE
SELECT u.user_nick, COUNT(ph.playback_id) AS total_play
FROM users AS u
INNER JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.user_nick
ORDER BY total_play ASC;

--8
-- Select the most played song for each country
EXPLAIN ANALYZE
SELECT DISTINCT ON (u.country)
    u.country,
    s.song_title,
    COUNT(ph.playback_id) AS play_count
FROM play_history ph
INNER JOIN users u ON ph.user_id = u.user_id
INNER JOIN song s ON ph.song_id = s.song_id
GROUP BY u.country, s.song_title
ORDER BY u.country, play_count DESC;

--9
-- Select users and play dates where they listened to at least 3 different artists
EXPLAIN ANALYZE
SELECT 
    ph.user_id,
    ph.play_date,
    COUNT(DISTINCT sa.artist_id) AS distinct_artists
FROM play_history ph
INNER JOIN song_artist sa ON sa.song_id = ph.song_id
GROUP BY ph.user_id, ph.play_date
HAVING COUNT(DISTINCT sa.artist_id) >= 3;

--10
-- Calculate the average listening duration per user
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.user_nick,
    ROUND(AVG(ph.duration_played), 2) AS avg_minutes_played,
    ROUND(SUM(ph.duration_played), 2) AS total_minutes,
    COUNT(ph.playback_id) AS total_plays
FROM users u
JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.user_nick, u.user_id
ORDER BY avg_minutes_played DESC
LIMIT 10;

--14
-- Select top 10 artists based on how many playlists their songs appear in
EXPLAIN ANALYZE
SELECT 
    a.artist_name,
    COUNT(DISTINCT sp.playlist_id) AS playlists_count,
    COUNT(DISTINCT s.song_id) AS total_songs_in_playlists
FROM song s
JOIN song_artist sa ON s.song_id = sa.song_id
JOIN artist a ON sa.artist_id = a.artist_id
JOIN play_history ph ON ph.song_id = s.song_id
JOIN playlist sp ON sp.playlist_id = ph.playlist_id
GROUP BY a.artist_name
ORDER BY playlists_count DESC
LIMIT 10;

--16
-- Select users whose nickname contains 'a', email ends with '.com', and date of birth is within a range
EXPLAIN ANALYZE
SELECT user_id, user_nick, first_name, surname, email, country, date_birth
FROM users
WHERE 
    user_nick LIKE '%a%'                   
    AND email LIKE '%.com'                  
    AND date_birth BETWEEN '1990-01-01' AND '2000-12-31'  
ORDER BY date_birth;

--18
-- Select devices registered between two specific dates
EXPLAIN ANALYZE
SELECT 
    device_id,
    device_name,
    device_type,
    registration_date
FROM device
WHERE registration_date BETWEEN '2024-01-01' AND '2025-01-01'
ORDER BY registration_date;

--20
-- Select songs that have a play count higher than the average of their album
EXPLAIN ANALYZE
SELECT DISTINCT 
    s.song_title,
    s.play_count,
    a.album_name
FROM song AS s
INNER JOIN album AS a ON s.album_id = a.album_id
WHERE s.play_count > (
    SELECT AVG(s2.play_count)
    FROM song s2
    WHERE s2.album_id = s.album_id
)
ORDER BY s.play_count DESC;
