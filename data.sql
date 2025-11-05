-- =============================================================
-- data.sql
-- Población de datos de prueba para bd030_schema21
-- =============================================================

SET search_path TO bd030_schema21, public;

-- =============================================================
-- 1️⃣ USERS (200 registros)
-- =============================================================

-- Insert 200 realistic test users directly from SQL
INSERT INTO users (
    user_id, user_nick, first_name, surname, user_password,
    email, phone_number, date_birth, age, country,
    profile_picture, user_biography
)
SELECT
    'U' || lpad(g::text, 5, '0') AS user_id,
    lower(fn || '_' || ln || '_' || g) AS user_nick,
    fn AS first_name,
    ln AS surname,
    md5('password' || g) AS user_password,
    lower(fn || '.' || ln || g || '@mail.com') AS email,
    CASE 
        WHEN c = 'Spain' THEN '+34' || (600000000 + g)
        WHEN c = 'Mexico' THEN '+52' || (5500000000 + g)
        WHEN c = 'Argentina' THEN '+54' || (900000000 + g)
        WHEN c = 'Chile' THEN '+56' || (900000000 + g)
        WHEN c = 'Colombia' THEN '+57' || (3000000000 + g)
        ELSE '+351' || (900000000 + g)
    END AS phone_number,
    birth AS date_birth,
    date_part('year', age(current_date, birth))::int AS age,
    c AS country,
    'https://picsum.photos/seed/' || g || '/200' AS profile_picture,
    'Music lover, passionate about streaming and live concerts. User ' || g AS user_biography
FROM (
    SELECT 
        g,
        (ARRAY['Carlos','Ana','Luis','María','Pedro','Lucía','Javier','Sofía','Andrés','Laura',
               'Miguel','Valentina','Daniel','Camila','Diego','Isabel','Mateo','Elena','Sebastián','Paula'])
               [floor(random()*20 + 1)] AS fn,
        (ARRAY['García','Rodríguez','López','Martínez','González','Pérez','Sánchez','Ramírez','Torres','Flores',
               'Díaz','Cruz','Reyes','Morales','Vargas','Ramos','Castro','Ortiz','Herrera','Romero'])
               [floor(random()*20 + 1)] AS ln,
        (ARRAY['Spain','Mexico','Argentina','Chile','Colombia','Portugal'])
               [floor(random()*6 + 1)] AS c,
        (DATE '1955-01-01' + (floor(random() * 25000)::int) * INTERVAL '1 day')::date AS birth
    FROM generate_series(1,200) AS g
) s;
SELECT * FROM users


-- =============================================================
-- 2️⃣ USER_FREE (100 registros)
-- =============================================================

INSERT INTO User_Free (user_id, stream_quality, adverts_limits, minutes_free)
SELECT
    user_id,
    CASE
        WHEN random() < 0.4 THEN 'Low'
        WHEN random() < 0.8 THEN 'Medium'
        ELSE 'High'
    END AS stream_quality,
    (3 + floor(random() * 12))::int AS adverts_limits,
    (60 + floor(random() * 540))::int AS minutes_free
FROM users
ORDER BY random()
LIMIT 100;

SELECT * FROM User_Free


-- =============================================================
-- 3️⃣ USER_PREMIUM (100 registros)
-- =============================================================

INSERT INTO User_Premium (user_id, premium_quiality, download_music, subscription_id)
SELECT
    u.user_id,
    CASE
        WHEN random() < 0.8 THEN 'High'
        ELSE 'Ultra'
    END AS premium_quiality,
    (random() < 0.9) AS download_music,  -- 90% can download music
    'S' || lpad(row_number() OVER (ORDER BY u.user_id)::text, 5, '0') AS subscription_id
FROM users u
WHERE u.user_id NOT IN (SELECT user_id FROM User_Free);

SELECT * FROM User_Premium

-- =============================================================
-- 4️⃣ SUBSCRIPTION_PLAN (100 registros)
-- =============================================================

INSERT INTO subscription_plan (
    subscription_id,
    user_id,
    subscription_name,
    duration_months,
    price,
    subscription_status,
    subscription_description,
    max_devices
)
SELECT
    up.subscription_id,
    up.user_id,
    CASE
        WHEN random() < 0.4 THEN 'Individual'
        WHEN random() < 0.7 THEN 'Family'
        ELSE 'Student'
    END AS subscription_name,
    CASE
        WHEN random() < 0.5 THEN 1
        WHEN random() < 0.8 THEN 6
        ELSE 12
    END AS duration_months,
    CASE
        WHEN random() < 0.4 THEN 9.99
        WHEN random() < 0.7 THEN 14.99
        ELSE 4.99
    END AS price,
    CASE
        WHEN random() < 0.9 THEN 'Active'
        ELSE 'Expired'
    END AS subscription_status,
    'Subscription plan for user ' || up.user_id AS subscription_description,
    CASE
        WHEN random() < 0.5 THEN 1
        WHEN random() < 0.8 THEN 3
        ELSE 5
    END AS max_devices
FROM User_Premium up;

SELECT * FROM subscription_plan;
-- =============================================================
-- 5️⃣ DEVICE (150 registros)
-- =============================================================

INSERT INTO device (device_id, device_name, device_type, registration_date)
SELECT
    'D' || lpad((u.g * 10 + d)::text, 6, '0') AS device_id,
    CASE
        WHEN dt = 'Phone' THEN 'Smartphone ' || (100 + floor(random() * 900))::int
        WHEN dt = 'Tablet' THEN 'Tablet ' || (100 + floor(random() * 900))::int
        WHEN dt = 'PC' THEN 'Laptop ' || (100 + floor(random() * 900))::int
        WHEN dt = 'TV' THEN 'Smart TV ' || (100 + floor(random() * 900))::int
        ELSE 'Speaker ' || (100 + floor(random() * 900))::int
    END AS device_name,
    dt AS device_type,
    (current_date - (floor(random() * 1095))::int) AS registration_date  -- within last 3 years
FROM (
    SELECT 
        row_number() OVER () AS g,
        user_id
    FROM users
) u
CROSS JOIN LATERAL (
    SELECT *
    FROM unnest(
        ARRAY['Phone','Tablet','PC','TV','Smart Speaker']
    ) WITH ORDINALITY AS dev(dt, d)
    WHERE d <= (1 + floor(random() * 3))::int  -- each user gets 1-3 random devices
) AS x(dt, d);

SELECT * FROM device;

-- =============================================================
-- 6️⃣ ARTIST (50 registros)
-- =============================================================

INSERT INTO artist (
    artist_id, artist_name, artist_country, artist_date_birth, artist_biography, active_since
)
SELECT
    'A' || lpad(g::text, 4, '0') AS artist_id,
    (ARRAY[
        'Carlos Vives', 'Shakira', 'Luis Miguel', 'Maluma', 'Bad Bunny',
        'Rosalía', 'Dua Lipa', 'Ed Sheeran', 'Billie Eilish', 'Adele',
        'Sebastián Yatra', 'Ricky Martin', 'Nicky Jam', 'Karol G', 'Daddy Yankee',
        'Camila Cabello', 'The Weeknd', 'Justin Bieber', 'Taylor Swift', 'Drake',
        'Ozuna', 'J Balvin', 'Anitta', 'Lali Espósito', 'TINI',
        'C. Tangana', 'Nathy Peluso', 'Pablo Alborán', 'Lola Índigo', 'Måneskin',
        'Post Malone', 'Sia', 'Shawn Mendes', 'Rauw Alejandro', 'Feid',
        'Becky G', 'Nicki Nicole', 'Myke Towers', 'Manuel Turizo', 'Morat',
        'Coldplay', 'Imagine Dragons', 'Linkin Park', 'Ariana Grande', 'Selena Gomez',
        'Harry Styles', 'Lana Del Rey', 'Sam Smith', 'BTS', 'BLACKPINK'
    ])[floor(random() * 50 + 1)] AS artist_name,
    (ARRAY['Spain', 'Mexico', 'Argentina', 'Colombia', 'United States', 'United Kingdom', 'Puerto Rico', 'Chile', 'Brazil'])
        [floor(random() * 9 + 1)] AS artist_country,
    (DATE '1960-01-01' + (floor(random() * 15000)::int) * INTERVAL '1 day')::date AS artist_date_birth,
    'Biography of the artist ' || g || ', known for their diverse musical style and international presence.' AS artist_biography,
    (DATE '1995-01-01' + (floor(random() * 9000)::int) * INTERVAL '1 day')::date AS active_since
FROM generate_series(1, 100) AS g;

SELECT * FROM artist;



-- =============================================================
-- 7️⃣ ALBUM (100 registros)
-- =============================================================

INSERT INTO album (album_id, album_name, album_release_date, album_type, total_tracks, album_duration)
SELECT
    'AL' || g,
    'Álbum_' || g,
    (DATE '2015-01-01' + (g * INTERVAL '10 days')),
    CASE WHEN g % 2 = 0 THEN 'Estudio' ELSE 'EP' END,
    (8 + (g % 10)),
    (30 + (g % 20))
FROM generate_series(1, 100) AS g;

SELECT * FROM album
-- =============================================================
-- 8️⃣ SONG (300 registros)
-- =============================================================
INSERT INTO album_artist (album_id, artist_id)
SELECT
    a.album_id,
    ar.artist_id
FROM album a
JOIN (
    SELECT 
        artist_id,
        row_number() OVER () AS rn
    FROM artist
) ar ON (a.album_id LIKE '%0' || ((ar.rn - 1) % (SELECT COUNT(*) FROM artist) + 1)::text)  -- simple distribución aleatoria
LIMIT (SELECT COUNT(*) FROM album);
INSERT INTO song_artist (song_id, artist_id)
SELECT DISTINCT
    s.song_id,
    aa.artist_id
FROM song s
JOIN album_artist aa ON s.album_id = aa.album_id;
SELECT * FROM song_artist

-- =============================================================
-- 9️⃣ SONG_ARTIST (300 registros)
-- =============================================================
INSERT INTO song (
    song_id, song_title, song_duration, song_release_date, play_count, is_single, album_id
)
SELECT
    'S' || lpad((a.g * 100 + s)::text, 6, '0') AS song_id,
    initcap(
        (ARRAY[
            'Dreams', 'Fire', 'Love Story', 'Echoes', 'Lost', 'Skyline', 
            'Midnight', 'Reflections', 'Energy', 'Waves', 'Heartbeat',
            'Infinity', 'Horizon', 'Golden', 'Memories', 'Magic', 'Whispers',
            'Gravity', 'Colors', 'Shadows', 'Paradise', 'Freedom', 'Sunrise',
            'Electric', 'Dancefloor', 'Moments', 'Desire', 'Journey', 'Lights', 'Rainfall'
        ])[floor(random() * 30 + 1)]
        || ' ' ||
        (ARRAY['I', 'II', 'III', 'Reimagined', 'Remix', 'Deluxe', 'Acoustic', 'Live'])[floor(random() * 8 + 1)]
    ) AS song_title,
    (2 + random() * 4)::numeric(4,2) AS song_duration,  -- 2–6 min
    (a.album_release_date + (floor(random() * 365)::int) * INTERVAL '1 day')::date AS song_release_date,
    (floor(random() * 1000000))::int AS play_count,      -- 0–1,000,000 plays
    (random() < 0.2) AS is_single,                      -- 20% are singles
    a.album_id
FROM (
    SELECT 
        row_number() OVER () AS g,
        album_id,
        album_name,
        album_release_date
    FROM album
) a
CROSS JOIN LATERAL generate_series(1, (5 + floor(random() * 10))::int) AS s;
SELECT * FROM song;




-- =============================================================
-- 🔟 ALBUM_ARTIST (100 registros)
-- =============================================================
INSERT INTO album (album_id, album_name, album_release_date, album_type, total_tracks, album_duration)
SELECT
    'AL' || lpad((a.g * 10 + s)::text, 5, '0') AS album_id,
    (CASE
        WHEN random() < 0.3 THEN 'The Best of '
        WHEN random() < 0.6 THEN 'Live at '
        WHEN random() < 0.9 THEN 'Sessions of '
        ELSE 'Dreams of '
     END) ||
     a.artist_name || ' ' || s AS album_name,
    (DATE '2000-01-01' + (floor(random() * 9000)::int) * INTERVAL '1 day')::date AS album_release_date,
    (ARRAY['Studio','EP','Live','Compilation'])[floor(random()*4 + 1)] AS album_type,
    (5 + floor(random() * 10))::int AS total_tracks,                  -- between 5 and 15 tracks
    (30 + floor(random() * 40))::numeric(4,2) AS album_duration       -- between 30 and 70 min
FROM (
    SELECT 
        row_number() OVER () AS g,
        artist_id,
        artist_name
    FROM artist
) a
CROSS JOIN LATERAL generate_series(1, (1 + floor(random() * 4))::int) AS s;

SELECT * FROM album;
-- =============================================================
-- 11️⃣ GENRE (5 registros)
-- =============================================================
INSERT INTO genre (
    genre_id, genre_name, genre_description, genre_origin_country, creation_year, popularity
)
VALUES
('G001', 'Pop', 'A mainstream genre characterized by catchy melodies and accessible lyrics.', 'United States', 1950, 'High'),
('G002', 'Rock', 'Electric guitars, drums, and strong rhythms dominate this energetic style.', 'United Kingdom', 1950, 'High'),
('G003', 'Hip Hop', 'Characterized by rhythmic speech (rap) and DJ sampling culture.', 'United States', 1970, 'High'),
('G004', 'Reggaeton', 'Latin genre with Caribbean rhythms and urban influences.', 'Puerto Rico', 1990, 'High'),
('G005', 'Latin Pop', 'Blend of pop music with Latin rhythms and Spanish lyrics.', 'Spain', 1980, 'High'),
('G006', 'Electronic', 'Music created using synthesizers, computers, and digital effects.', 'Germany', 1970, 'High'),
('G007', 'Jazz', 'Improvisational music rooted in blues and swing traditions.', 'United States', 1920, 'Medium'),
('G008', 'Classical', 'Orchestral compositions from Baroque to Modern eras.', 'Austria', 1700, 'Medium'),
('G009', 'R&B', 'Smooth blend of soul, pop, and funk with emotional vocals.', 'United States', 1940, 'High'),
('G010', 'Country', 'American roots music with storytelling lyrics and acoustic sounds.', 'United States', 1920, 'Medium'),
('G011', 'Reggae', 'Laid-back rhythm and socially conscious lyrics from Jamaica.', 'Jamaica', 1960, 'Medium'),
('G012', 'K-Pop', 'Korean pop music blending electronic, hip hop, and dance styles.', 'South Korea', 1990, 'High'),
('G013', 'Metal', 'Loud, aggressive, and guitar-driven evolution of rock music.', 'United Kingdom', 1970, 'Medium'),
('G014', 'Indie', 'Independent music emphasizing artistic freedom and experimentation.', 'United Kingdom', 1990, 'Medium'),
('G015', 'Folk', 'Traditional storytelling songs using acoustic instruments.', 'Ireland', 1900, 'Low'),
('G016', 'Trap', 'Subgenre of hip hop with heavy bass and snare-driven beats.', 'United States', 2000, 'High'),
('G017', 'Salsa', 'Danceable Latin music mixing Cuban and Puerto Rican influences.', 'Cuba', 1960, 'Medium'),
('G018', 'Soul', 'Emotionally intense genre derived from gospel and rhythm & blues.', 'United States', 1950, 'Medium'),
('G019', 'Blues', 'Origin of many modern genres, based on expressive melodies and emotion.', 'United States', 1910, 'Medium'),
('G020', 'Dance', 'Upbeat, rhythmic music meant for clubs and festivals.', 'France', 1980, 'High');

SELECT * FROM genre;

-- =============================================================
-- 12️⃣ SONG_GENRE (300 registros)
-- =============================================================

-- Asignar géneros a canciones
INSERT INTO song_genre (song_id, genre_id)
SELECT
    s.song_id,
    g.genre_id
FROM song s
JOIN LATERAL (
    SELECT genre_id
    FROM genre
    ORDER BY random()
    LIMIT (1 + floor(random() * 2))  -- cada canción tiene 1 o 2 géneros
) g ON TRUE;
-- =============================================================
-- 13️⃣ PLAYLIST (100 registros)
-- =============================================================

-- Generate 1–5 playlists per user
INSERT INTO playlist (
    playlist_id, playlist_title, playlist_description, total_songs,
    playlist_duration, cover_photo, user_id
)
SELECT
    'PL' || lpad((u.g * 10 + p)::text, 6, '0') AS playlist_id,
    (ARRAY[
        'Morning Vibes', 'Workout Mix', 'Chill & Relax', 'Top Hits',
        'Throwback', 'Love Songs', 'Party Time', 'Focus Mode', 'Travel Tunes',
        'Acoustic Moments', 'Late Night', 'Dancefloor', 'New Discoveries',
        'Indie Essentials', 'Latin Beats', 'Soft Pop', 'Roadtrip'
    ])[floor(random() * 17 + 1)] || ' #' || p AS playlist_title,
    'A curated playlist created by user ' || u.user_nick || ' containing some of their favorite songs.' AS playlist_description,
    (10 + floor(random() * 40))::int AS total_songs,                      -- 10–50 songs
    (30 + floor(random() * 170))::numeric(6,2) AS playlist_duration,      -- 30–200 minutes
    'https://picsum.photos/300?image=' || (100 + u.g) AS cover_photo,
    u.user_id
FROM (
    SELECT 
        row_number() OVER () AS g,
        user_id,
        user_nick
    FROM users
) u
CROSS JOIN LATERAL generate_series(1, (1 + floor(random() * 5))::int) AS p; 

SELECT * FROM playlist;

-- =============================================================
-- 14️⃣ PLAY_HISTORY (500 registros)
-- =============================================================

INSERT INTO play_history (
    playback_id, user_id, song_id, device_id, playlist_id, play_date, duration_played, completed
)
SELECT
    'PH' || lpad((u.g * 100 + s)::text, 7, '0') AS playback_id,
    u.user_id,
    sg.song_id,
    d.device_id,
    CASE WHEN random() < 0.6 THEN p.playlist_id ELSE NULL END AS playlist_id,
    (current_date - (floor(random() * 365))::int) AS play_date,  -- within last year
    ROUND((sg.song_duration * (0.5 + random() * 0.5))::numeric, 2) AS duration_played,  -- 50–100% of song duration
    (random() < 0.8) AS completed
FROM (
    SELECT row_number() OVER () AS g, user_id FROM users
) u
JOIN LATERAL (
    SELECT device_id FROM device ORDER BY random() LIMIT 1
) d ON TRUE
JOIN LATERAL (
    SELECT song_id, song_duration FROM song ORDER BY random() LIMIT 1
) sg ON TRUE
LEFT JOIN LATERAL (
    SELECT playlist_id FROM playlist WHERE user_id = u.user_id ORDER BY random() LIMIT 1
) p ON TRUE
CROSS JOIN LATERAL generate_series(1, (3 + floor(random() * 8))::int) AS s;

SELECT * FROM play_history

DELETE FROM play_history;



WITH song_counts AS (
    SELECT
        song_id,
        song_duration,
        (5 + floor(random() * 11))::int AS num_reproductions
    FROM song
)
INSERT INTO play_history (
    playback_id, user_id, song_id, device_id, playlist_id, play_date, duration_played, completed
)
SELECT
    'PH' || lpad(nextval('bd030_schema21.play_history_seq')::text, 7, '0') AS playback_id,
    u.user_id,
    s.song_id,
    d.device_id,
    CASE WHEN random() < 0.6 THEN p.playlist_id ELSE NULL END AS playlist_id,
    (current_date - (floor(random() * 365))::int) AS play_date,
    ROUND((s.song_duration * (0.5 + random() * 0.5))::numeric, 2) AS duration_played,
    (random() < 0.8) AS completed
FROM song_counts s
-- Aquí sí: cada canción usa su propio número aleatorio
CROSS JOIN generate_series(1, s.num_reproductions) g
-- Usuario aleatorio
JOIN LATERAL (
    SELECT user_id FROM users ORDER BY random() LIMIT 1
) u ON TRUE
-- Dispositivo aleatorio
JOIN LATERAL (
    SELECT device_id FROM device ORDER BY random() LIMIT 1
) d ON TRUE
-- Playlist aleatoria
LEFT JOIN LATERAL (
    SELECT playlist_id FROM playlist WHERE user_id = u.user_id ORDER BY random() LIMIT 1
) p ON TRUE;



CREATE SEQUENCE bd030_schema21.play_history_seq START 1;

INSERT INTO play_history (
    playback_id, user_id, song_id, device_id, playlist_id, play_date, duration_played, completed
)
SELECT
    'PH' || lpad(nextval('play_history_seq')::text, 7, '0') AS playback_id,  -- usa una secuencia para IDs únicos
    u.user_id,
    s.song_id,
    d.device_id,
    CASE WHEN random() < 0.6 THEN p.playlist_id ELSE NULL END AS playlist_id,
    (current_date - (floor(random() * 365))::int) AS play_date,
    ROUND((s.song_duration * (0.5 + random() * 0.5))::numeric, 2) AS duration_played,
    (random() < 0.8) AS completed
FROM users u
-- Cada usuario se combina con un subconjunto aleatorio de canciones (entre 3 y 10)
JOIN LATERAL (
    SELECT song_id, song_duration
    FROM song
    ORDER BY random()
    LIMIT (3 + floor(random() * 8))::int
) s ON TRUE
-- Un dispositivo aleatorio por reproducción
JOIN LATERAL (
    SELECT device_id FROM device ORDER BY random() LIMIT 1
) d ON TRUE
-- Una playlist aleatoria del usuario (si tiene)
LEFT JOIN LATERAL (
    SELECT playlist_id FROM playlist WHERE user_id = u.user_id ORDER BY random() LIMIT 1
) p ON TRUE;



SELECT 
    s.song_id,
    s.song_title,
    COUNT(ph.playback_id) AS total_reproductions
FROM play_history ph
JOIN song s ON ph.song_id = s.song_id
GROUP BY s.song_id, s.song_title
ORDER BY total_reproductions DESC;


SELECT COUNT(*) FROM SONG;


SELECT * FROM bd030_schema21.play_history;

-- =============================================================
-- ✅ FIN DEL SCRIPT
-- =============================================================

