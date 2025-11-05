
SET search_path TO bd030_schema21 ;



SELECT user_id 
FROM play_history AS p
WHERE p.duration_played>3;



--SELECCIONA LOS USUARIOS CON MAS CANCIONES REPRODUCIDAS
SELECT u.user_nick, COUNT(ph.playback_id) AS total_play
FROM users AS u
INNER JOIN play_history ph ON u.user_id=ph.user_id
GROUP BY u.user_nick
ORDER BY total_play ASC;


--SELECCIONA LOS USUARIOS CON SUPSCRIPCION ACTIVA
SELECT u.user_nick, sp.subscription_name, sp.duration_months, sp.price
FROM users u
JOIN user_premium up ON u.user_id = up.user_id
JOIN subscription_plan sp ON up.subscription_id = sp.subscription_id
WHERE sp.subscription_status = 'Active';


--SELECCIONA LA CANCION MAS ESCUCHADA DE CADA PAIS
SELECT DISTINCT ON (u.country)
    u.country,
    s.song_title,
    COUNT(ph.playback_id) AS play_count
FROM play_history ph
INNER JOIN users u ON ph.user_id = u.user_id
INNER JOIN song s ON ph.song_id = s.song_id
GROUP BY u.country, s.song_title
ORDER BY u.country, play_count DESC;


SELECT 
    ph.user_id,
    ph.play_date,
    COUNT(DISTINCT sa.artist_id) AS distinct_artists
FROM play_history ph
INNER JOIN song_artist sa ON sa.song_id = ph.song_id
GROUP BY ph.user_id, ph.play_date
HAVING COUNT(DISTINCT sa.artist_id) >= 3;

--PROMEDIO DE DURACION ESCUCHADA POR EL USUARIO
SELECT u.user_id,u.user_nick,ROUND(AVG(ph.duration_played), 2) AS avg_minutes_played,
    ROUND(SUM(ph.duration_played), 2) AS total_minutes,
    COUNT(ph.playback_id) AS total_plays
FROM users u
JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.user_nick,u.user_id
ORDER BY avg_minutes_played DESC
LIMIT 10;

--COMPARACION DE PROMEDIO DE DURACION ENTRE PAISES
SELECT 
    u.country,
    ROUND(AVG(ph.duration_played), 2) AS avg_minutes,
    ROUND(SUM(ph.duration_played), 2) AS total_minutes,
    COUNT(ph.playback_id) AS total_plays
FROM users u
JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.country
ORDER BY avg_minutes DESC;

SELECT 
    s.song_title,
    COUNT(ph.playback_id) AS total_plays
FROM song s
LEFT JOIN play_history ph ON s.song_id = ph.song_id
GROUP BY s.song_title
ORDER BY total_plays DESC;

--QUIEN HA ESCUCHADO WAVES REMIX
SELECT * FROM song;
SELECT 
    s.song_title,
    u.user_nick,
    u.country,
    ph.play_date,
    ph.duration_played,
    ph.completed
FROM play_history ph
JOIN users u ON ph.user_id = u.user_id
JOIN song s ON ph.song_id = s.song_id
WHERE s.song_title = 'Waves Remix'   
ORDER BY ph.play_date DESC;





SELECT 
    d.device_type,
    CASE 
        WHEN up.user_id IS NOT NULL THEN 'Premium'
        WHEN uf.user_id IS NOT NULL THEN 'Free'
        ELSE 'Unknown'
    END AS user_type,
    ROUND(SUM(ph.duration_played), 2) AS total_minutes_played
FROM play_history ph
JOIN device d ON ph.device_id = d.device_id
LEFT JOIN user_premium up ON ph.user_id = up.user_id
LEFT JOIN user_free uf ON ph.user_id = uf.user_id
GROUP BY d.device_type, user_type
ORDER BY total_minutes_played DESC;


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



SELECT 
    s.song_title,
    COUNT(DISTINCT u.country) AS unique_countries
FROM play_history ph
JOIN users u ON ph.user_id = u.user_id
JOIN song s ON ph.song_id = s.song_id
GROUP BY s.song_title
ORDER BY unique_countries DESC
LIMIT 10;


--USUARIOS CUYO NICK LLEVEN LA A, SU EMAIL ACABE EN . COM Y SU FECHA DE NACIMIENTO ESTEN ENTRA LAS INCLUIDAS
SELECT user_id, user_nick, first_name, surname, email, country, date_birth
FROM users
WHERE 
    user_nick LIKE '%a%'                   
    AND email LIKE '%.com'                  
    AND date_birth BETWEEN '1990-01-01' AND '2000-12-31'  
ORDER BY date_birth;


--TIPO DE USUARIO (FREE O PREMIUM) DE UN USUARIO EN CONCRETO DADO EL NICL
SELECT u.user_id, u.user_nick,
    CASE 
        WHEN up.user_id IS NOT NULL THEN 'Premium'
        WHEN uf.user_id IS NOT NULL THEN 'Free'
        ELSE 'Unknown'
    END AS user_type
FROM users u
LEFT JOIN user_premium up ON u.user_id = up.user_id
LEFT JOIN user_free uf ON u.user_id = uf.user_id
WHERE u.user_nick = 'pedro_romero_16';


--DISPOSITIVOS REGISTRADOS ENTRE DOS FECHAS
SELECT 
    device_id,
    device_name,
    device_type,
    registration_date
FROM device
WHERE registration_date BETWEEN '2024-01-01' AND '2025-01-01'
ORDER BY registration_date;


SELECT 
    DISTINCT a.artist_name,
    al.album_name,
    al.album_release_date
FROM artist a
JOIN album_artist aa ON a.artist_id = aa.artist_id
JOIN album al ON aa.album_id = al.album_id
WHERE 
    al.album_release_date BETWEEN '2010-01-01' AND '2020-12-31'
    AND a.artist_name ILIKE '%a%'
ORDER BY al.album_release_date DESC;


--DURACION PROMEDIO DE LAS CANCIONES POR TIPO DE ALBUM
SELECT 
    a.album_type,
    ROUND(AVG(s.song_duration), 2) AS avg_duration
FROM song s
JOIN album a ON s.album_id = a.album_id
GROUP BY a.album_type
HAVING AVG(s.song_duration) IS NOT NULL
ORDER BY avg_duration DESC;


SELECT DISTINCT s.song_title,s.play_count,a.album_name
FROM song AS s
INNER JOIN album AS a ON s.album_id = a.album_id
WHERE s.play_count > (
    SELECT AVG(s2.play_count)
    FROM song s2
    WHERE s2.album_id = s.album_id
)
ORDER BY s.play_count DESC;



SELECT 
    s.song_id,
    s.song_title,
    s.album_id,
    s.song_duration
FROM song s
WHERE EXISTS (
    SELECT 1
    FROM song s2
    WHERE s2.album_id = s.album_id
    GROUP BY s2.album_id
    HAVING COUNT(s2.song_id) > 5
)
ORDER BY s.song_title;

SELECT * FROM artist;

SELECT 
    s.song_title,
    s.song_duration
FROM song s
WHERE EXISTS (
    SELECT 1
    FROM song_artist sa
    JOIN artist a ON sa.artist_id = a.artist_id
    WHERE sa.song_id = s.song_id
      AND a.artist_country LIKE 'Spain'
);
