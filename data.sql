
SET search_path TO bd030_schema21, public;


---------------------INSERT 200 DATAS USERS----------------------------------
BEGIN; --A transaction is started

INSERT INTO users ( --We insert data into the attributes
    user_id,
    user_nick,
    first_name,
    surname,
    user_password,
    email,
    phone_number,
    date_birth,
    age,
    country,
    profile_picture,
    user_biography
)
SELECT
    'user_' || i AS user_id, --Concatenate 'user_' with the number → user_1, user_2, …"
    'nick_' || i AS user_nick, --Concatenate 'nick_' with the number → nick_1, nick_2, …"
    --Define an array of first names and an array of last names
    (ARRAY['Ana','Luis','María','Pedro','Lucía','Carlos','Sofía','Miguel','Laura','Andrés'])
        [(random()*9)::int + 1] AS first_name,
    (ARRAY['García','Pérez','Silva','Rodríguez','Fernández','López','Martínez','Santos','Torres','Morales'])
        [(random()*9)::int + 1] AS surname,
    --Then that number is used as an index of the array to select a random first name and last name."
    'pass' || i AS user_password,
    'user' || i || '@mail.com' AS email,

    CASE (i % 8)
        WHEN 0 THEN '+34'  -- España
        WHEN 1 THEN '+351' -- Portugal
        WHEN 2 THEN '+55'  -- Brasil
        WHEN 3 THEN '+52'  -- México
        WHEN 4 THEN '+54'  -- Argentina
        WHEN 5 THEN '+56'  -- Chile
        WHEN 6 THEN '+51'  -- Perú
        ELSE '+57'         -- Colombia
    END || (600000000 + i)::text AS phone_number, --Ensure that all phone numbers are unique

    -- Fecha de nacimiento y edad coherente
    (CURRENT_DATE - ((i % 80 + 18) * 365) * INTERVAL '1 day')::date AS date_birth,
    (i % 80 + 18) AS age,

    CASE (i % 8)
        WHEN 0 THEN 'España'
        WHEN 1 THEN 'Portugal'
        WHEN 2 THEN 'Brasil'
        WHEN 3 THEN 'México'
        WHEN 4 THEN 'Argentina'
        WHEN 5 THEN 'Chile'
        WHEN 6 THEN 'Perú'
        ELSE 'Colombia'
    END AS country,

    'https://picsum.photos/200?random=' || i AS profile_picture,
    'Hola, soy el usuario número ' || i || '.' AS user_biography

FROM generate_series(1,200) AS s(i);

COMMIT; --A transaction is finished


SELECT * FROM users
-------------------------------------------------------------------------------------



INSERT INTO users (user_id, user_nick, first_name, surname, user_password, email, phone_number, date_birth, age, country, profile_picture, user_biography) 
VALUES ('user_extreme_1','nick_bebe','Bebé','RecienNacido','pass1234','bebe@mail.com','+34' || '600000001',CURRENT_DATE - INTERVAL '1 year',1,'España','https://picsum.photos/200?random=1','Usuario recién nacido para probar edad mínima.');

INSERT INTO users (user_id, user_nick, first_name, surname, user_password, email, phone_number, date_birth, age, country, profile_picture, user_biography) 
VALUES ('user_extreme_2','nick_abuelito','Abuelo','Centenario','pass1234','abuelo@mail.com','+52' || '600000002',CURRENT_DATE - INTERVAL '100 years',100,'México','https://picsum.photos/200?random=2','Usuario de 100 años para probar edad máxima.');

INSERT INTO users (user_id, user_nick, first_name, surname, user_password, email, phone_number, date_birth, age, country, profile_picture, user_biography) 
VALUES ('user_extreme_6','nick_internacional','John','Doe','pass1234','john.doe@mail.com','+1' || '600000006',CURRENT_DATE - INTERVAL '40 years',40,'Estados Unidos','https://picsum.photos/200?random=6','Usuario internacional para probar prefijo de teléfono y país.');






-----------------------INSERT 100 DATOS USER_FREE--------------------------------------------
INSERT INTO User_Free (user_id, stream_quality, adverts_limits, minutes_free)
SELECT
    user_id,  -- Take the user_id from the users table
    CASE
        -- Assign a random stream quality based on probabilities
        WHEN random() < 0.4 THEN 'Low'       -- 40% chance of 'Low' quality
        WHEN random() < 0.8 THEN 'Medium'    -- 40% chance of 'Medium' quality
        ELSE 'High'                          -- 20% chance of 'High' quality
    END AS stream_quality,
    -- Generate a random number of adverts between 3 and 14
    (3 + floor(random() * 12))::int AS adverts_limits,
    -- Generate a random number of free minutes between 60 and 599
    (60 + floor(random() * 540))::int AS minutes_free
FROM users
ORDER BY random()  -- Randomize the order of users
LIMIT 100;         -- Only insert 100 users



INSERT INTO User_Free (user_id, stream_quality, adverts_limits, minutes_free)
VALUES ('user_limit1', 'Low', 3, 60);

INSERT INTO User_Free (user_id, stream_quality, adverts_limits, minutes_free)
VALUES ('user_limit3', 'Medium', 8, 300);

SELECT * FROM User_Free

---------------------------------------------------------------------------------------





-----------------------INSERT DATOS USER_PREMIUM-------------------------------------------
INSERT INTO User_Premium (user_id, premium_quiality, download_music, subscription_id)
SELECT
    u.user_id,  -- Take the user_id from the users table
    CASE
        WHEN random() < 0.8 THEN 'High'  -- 80% chance to assign 'High' premium quality
        ELSE 'Ultra'                     -- 20% chance to assign 'Ultra' premium quality
    END AS premium_quiality,
    (random() < 0.9) AS download_music,  -- Boolean: 90% of users can download music
    'S' || lpad(row_number() OVER (ORDER BY u.user_id)::text, 5, '0') AS subscription_id
    -- Create a unique subscription_id by prefixing 'S' and adding a 5-digit padded number
FROM users u
WHERE u.user_id NOT IN (SELECT user_id FROM User_Free);
-- Only select users who are NOT already in the User_Free table


INSERT INTO User_Premium (user_id, premium_quiality, download_music, subscription_id)
VALUES ('user_premium2', 'Ultra', FALSE, 'S99997');

SELECT * FROM User_Premium
-----------------------------------------------------------------------------------------------





-------------------------------INSERT SUBSCRIPTION PLAN DATOS---------------------------------
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
    up.subscription_id,  -- Use subscription_id from User_Premium
    up.user_id,          -- Use user_id from User_Premium

    -- Randomly assign subscription type with probabilities
    CASE
        WHEN random() < 0.4 THEN 'Individual'  -- 40% chance
        WHEN random() < 0.7 THEN 'Family'      -- 30% chance (0.7-0.4)
        ELSE 'Student'                         -- 30% chance (remaining)
    END AS subscription_name,

    -- Randomly assign subscription duration in months
    CASE
        WHEN random() < 0.5 THEN 1             -- 50% chance for 1 month
        WHEN random() < 0.8 THEN 6             -- 30% chance for 6 months (0.8-0.5)
        ELSE 12                                -- 20% chance for 12 months
    END AS duration_months,

    -- Randomly assign price
    CASE
        WHEN random() < 0.4 THEN 9.99          -- 40% chance
        WHEN random() < 0.7 THEN 14.99         -- 30% chance
        ELSE 4.99                               -- 30% chance
    END AS price,

    -- Randomly assign subscription status
    CASE
        WHEN random() < 0.9 THEN 'Active'      -- 90% chance to be Active
        ELSE 'Expired'                          -- 10% chance to be Expired
    END AS subscription_status,

    -- Description for the subscription
    'Subscription plan for user ' || up.user_id AS subscription_description,

    -- Randomly assign maximum allowed devices
    CASE
        WHEN random() < 0.5 THEN 1             -- 50% chance
        WHEN random() < 0.8 THEN 3             -- 30% chance
        ELSE 5                                  -- 20% chance
    END AS max_devices
FROM User_Premium up;

-- Display all inserted subscription plans
-----------------------------------------------------------------------------------------



NSERT INTO subscription_plan (subscription_id, user_id, subscription_name, duration_months, price, subscription_status, subscription_description, max_devices)
VALUES
('S99998', 'user_edge3', 'Student', 1, 4.99, 'Expired', 'Subscription plan for user user_edge3', 1),
('S99999', 'user_edge4', 'Family', 12, 14.99, 'Active', 'Subscription plan for user user_edge4', 5);



SELECT * FROM subscription_plan;









----------------------------INSERT DEVICE--------------------------------------------
INSERT INTO device (device_id, device_name, device_type, registration_date)
VALUES
('D000001', 'Smart Speaker 993', 'Smart Speaker', '2024-01-27'),
('D000002', 'Phone 800', 'Phone', '2023-08-27'),
('D000003', 'TV 660', 'TV', '2025-03-17'),
('D000004', 'TV 182', 'TV', '2023-04-07'),
('D000005', 'Phone 265', 'Phone', '2024-05-04'),
('D000006', 'Tablet 589', 'Tablet', '2025-05-18'),
('D000007', 'PC 489', 'PC', '2024-08-29'),
('D000008', 'PC 196', 'PC', '2025-09-18'),
('D000009', 'PC 705', 'PC', '2024-03-31'),
('D000010', 'Smart Speaker 319', 'Smart Speaker', '2025-05-02'),
('D000011', 'Phone 592', 'Phone', '2024-02-10'),
('D000012', 'TV 671', 'TV', '2025-05-29'),
('D000013', 'TV 578', 'TV', '2023-06-28'),
('D000014', 'Phone 241', 'Phone', '2025-03-22'),
('D000015', 'Smart Speaker 501', 'Smart Speaker', '2023-05-26'),
('D000016', 'Smart Speaker 917', 'Smart Speaker', '2024-04-30'),
('D000017', 'PC 894', 'PC', '2025-01-11'),
('D000018', 'PC 955', 'PC', '2024-12-09'),
('D000019', 'Phone 969', 'Phone', '2025-02-16'),
('D000020', 'Phone 112', 'Phone', '2025-05-02'),
('D000021', 'TV 618', 'TV', '2025-08-12'),
('D000022', 'Phone 551', 'Phone', '2025-09-01'),
('D000023', 'PC 290', 'PC', '2025-10-19'),
('D000024', 'PC 770', 'PC', '2025-02-12'),
('D000025', 'Tablet 646', 'Tablet', '2025-10-10'),
('D000026', 'PC 139', 'PC', '2023-04-28'),
('D000027', 'Phone 211', 'Phone', '2025-05-25'),
('D000028', 'Tablet 936', 'Tablet', '2025-01-01'),
('D000029', 'Smart Speaker 733', 'Smart Speaker', '2025-04-04'),
('D000030', 'Phone 274', 'Phone', '2024-11-18'),
('D000031', 'PC 932', 'PC', '2024-09-03'),
('D000032', 'Phone 957', 'Phone', '2025-01-16'),
('D000033', 'TV 692', 'TV', '2025-06-15'),
('D000034', 'Smart Speaker 800', 'Smart Speaker', '2023-12-06'),
('D000035', 'Smart Speaker 878', 'Smart Speaker', '2025-02-24'),
('D000036', 'Phone 499', 'Phone', '2024-11-17'),
('D000037', 'Tablet 510', 'Tablet', '2025-06-23'),
('D000038', 'Tablet 375', 'Tablet', '2025-09-27'),
('D000039', 'TV 742', 'TV', '2024-06-22'),
('D000040', 'Smart Speaker 727', 'Smart Speaker', '2023-02-01'),
('D000041', 'Tablet 324', 'Tablet', '2025-06-18'),
('D000042', 'Smart Speaker 661', 'Smart Speaker', '2024-04-23'),
('D000043', 'PC 853', 'PC', '2023-12-07'),
('D000044', 'Smart Speaker 252', 'Smart Speaker', '2025-01-07'),
('D000045', 'Smart Speaker 334', 'Smart Speaker', '2025-08-12'),
('D000046', 'PC 729', 'PC', '2024-11-26'),
('D000047', 'TV 507', 'TV', '2025-03-09'),
('D000048', 'PC 398', 'PC', '2025-06-15'),
('D000049', 'TV 479', 'TV', '2024-07-29'),
('D000050', 'PC 271', 'PC', '2023-03-09')

SELECT * FROM device
------------------------------------------------------------------------------








-----------------------------INSERT ARTIST-----------------------------------------
INSERT INTO artist (
    artist_id,           -- Unique ID for each artist
    artist_name,         -- Name of the artist
    artist_country,      -- Country of origin
    artist_date_birth,   -- Date of birth
    artist_biography,    -- Short biography
    active_since         -- Date the artist became active
)
SELECT
    'A' || lpad(g::text, 4, '0') AS artist_id,  -- Generate ID like A0001, A0002, etc.

    -- Randomly select a name from a predefined array of 50 popular artists
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
    ])[floor(random() * 50 + 1)] AS artist_name,  -- Randomly pick an index between 1 and 50

    -- Randomly select a country from an array of 9 countries
    (ARRAY['Spain', 'Mexico', 'Argentina', 'Colombia', 'United States', 'United Kingdom', 'Puerto Rico', 'Chile', 'Brazil'])
        [floor(random() * 9 + 1)] AS artist_country,

    -- Generate a random birth date between 1960-01-01 and ~2000
    (DATE '1960-01-01' + (floor(random() * 15000)::int) * INTERVAL '1 day')::date AS artist_date_birth,

    -- Generate a simple biography for each artist
    'Biography of the artist ' || g || ', known for their diverse musical style and international presence.' AS artist_biography,

    -- Generate a random active_since date between 1995-01-01 and ~2020
    (DATE '1995-01-01' + (floor(random() * 9000)::int) * INTERVAL '1 day')::date AS active_since

FROM generate_series(1, 100) AS g;  -- Generate 100 rows

-- Retrieve all inserted artists
SELECT * FROM artist;
-----------------------------------------------------------------------------------------



-------------------------------INSERT ALBUM-----------------------------------------------
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
---------------------------------------------------------------------------------







-------------------------INSERT SONG--------------------------------------
INSERT INTO song (song_id, song_title, song_duration, song_release_date, play_count, is_single, album_id)
VALUES
('SNG0001', 'Love Story 1', 3.45, '2010-05-14', 1200, TRUE, NULL),
('SNG0002', 'Blinding Lights 2', 3.98, '2019-11-23', 5400, FALSE, 'AL1'),
('SNG0003', 'Shape of You 3', 4.12, '2017-01-15', 7800, TRUE, NULL),
('SNG0004', 'Bad Guy 4', 2.95, '2019-03-10', 2300, FALSE, 'AL2'),
('SNG0005', 'Levitating 5', 3.50, '2020-06-20', 9100, TRUE, NULL),
('SNG0006', 'Senorita 6', 3.72, '2019-07-18', 4500, FALSE, 'AL3'),
('SNG0007', 'Peaches 7', 4.05, '2021-03-12', 3200, TRUE, NULL),
('SNG0008', 'Watermelon Sugar 8', 3.30, '2020-08-25', 4100, FALSE, 'AL4'),
('SNG0009', 'Drivers License 9', 3.89, '2021-01-08', 8700, TRUE, NULL),
('SNG0010', 'Stay 10', 2.95, '2021-05-30', 2200, FALSE, 'AL5'),
('SNG0011', 'Happier 11', 3.15, '2018-04-22', 3100, TRUE, NULL),
('SNG0012', 'Shivers 12', 3.88, '2021-09-01', 5400, FALSE, 'AL6'),
('SNG0013', 'Easy on Me 13', 3.75, '2021-10-20', 6200, TRUE, NULL),
('SNG0014', 'Industry Baby 14', 3.40, '2021-07-16', 2800, FALSE, 'AL7'),
('SNG0015', 'Good 4 U 15', 3.10, '2021-06-12', 3300, TRUE, NULL),
('SNG0016', 'Montero 16', 3.55, '2021-03-26', 2900, FALSE, 'AL8'),
('SNG0017', 'Butter 17', 2.98, '2021-05-01', 4100, TRUE, NULL),
('SNG0018', 'As It Was 18', 3.22, '2022-03-18', 3500, FALSE, 'AL9'),
('SNG0019', 'Someone You Loved 19', 3.85, '2019-02-14', 2500, TRUE, NULL),
('SNG0020', 'Ozuna 20', 3.60, '2020-11-02', 4200, FALSE, 'AL10'),
('SNG0021', 'J Balvin 21', 3.70, '2021-02-14', 3800, TRUE, NULL),
('SNG0022', 'Anitta 22', 3.90, '2020-10-18', 4500, FALSE, 'AL11'),
('SNG0023', 'Lali Espósito 23', 3.33, '2019-08-24', 3100, TRUE, NULL),
('SNG0024', 'TINI 24', 3.48, '2021-01-12', 2700, FALSE, 'AL12'),
('SNG0025', 'C. Tangana 25', 4.10, '2020-12-10', 3600, TRUE, NULL),
('SNG0026', 'Nathy Peluso 26', 3.25, '2021-05-05', 3200, FALSE, 'AL13'),
('SNG0027', 'Pablo Alborán 27', 3.90, '2019-06-20', 2800, TRUE, NULL),
('SNG0028', 'Lola Índigo 28', 3.65, '2020-04-17', 3500, FALSE, 'AL14'),
('SNG0029', 'Måneskin 29', 3.88, '2021-03-12', 4000, TRUE, NULL),
('SNG0030', 'Post Malone 30', 3.55, '2020-08-14', 3300, FALSE, 'AL15'),
('SNG0031', 'Sia 31', 3.72, '2019-12-22', 3600, TRUE, NULL),
('SNG0032', 'Shawn Mendes 32', 3.50, '2021-06-05', 2800, FALSE, 'AL16'),
('SNG0033', 'Rauw Alejandro 33', 3.85, '2021-02-25', 3200, TRUE, NULL),
('SNG0034', 'Feid 34', 3.33, '2020-11-11', 3000, FALSE, 'AL17'),
('SNG0035', 'Becky G 35', 3.60, '2021-05-20', 3600, TRUE, NULL),
('SNG0036', 'Nicki Nicole 36', 3.25, '2021-01-08', 3100, FALSE, 'AL18'),
('SNG0037', 'Myke Towers 37', 3.55, '2020-10-19', 2700, TRUE, NULL),
('SNG0038', 'Manuel Turizo 38', 3.72, '2021-06-22', 3500, FALSE, 'AL19'),
('SNG0039', 'Morat 39', 3.48, '2021-03-08', 3800, TRUE, NULL),
('SNG0040', 'Coldplay 40', 4.10, '2019-11-15', 4200, FALSE, 'AL20'),
('SNG0041', 'Imagine Dragons 41', 3.90, '2020-07-20', 3900, TRUE, NULL),
('SNG0042', 'Linkin Park 42', 3.65, '2021-01-28', 3600, FALSE, 'AL21'),
('SNG0043', 'Ariana Grande 43', 3.33, '2021-05-14', 3400, TRUE, NULL),
('SNG0044', 'Selena Gomez 44', 3.50, '2020-12-05', 3000, FALSE, 'AL22'),
('SNG0045', 'Harry Styles 45', 3.72, '2021-03-17', 3700, TRUE, NULL),
('SNG0046', 'Lana Del Rey 46', 3.60, '2020-08-25', 3300, FALSE, 'AL23'),
('SNG0047', 'Sam Smith 47', 3.85, '2019-09-12', 3100, TRUE, NULL),
('SNG0048', 'BTS 48', 3.48, '2020-12-30', 3500, FALSE, 'AL24'),
('SNG0049', 'BLACKPINK 49', 3.33, '2021-06-08', 4000, TRUE, NULL),
('SNG0050', 'Carlos Vives 50', 3.90, '2020-07-14', 3200, FALSE, 'AL25')

SELECT * FROM song
----------------------------------------------------------------------------------------














-----------------------INSERT GENRE---------------------------------------------
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
---------------------------------------------------------------------------




----------------------------INSERT SONG_ARTIST-------------------------------
DO
$$
DECLARE
    v_song RECORD;
    v_artist RECORD;
    v_num_artists INT;
BEGIN
    FOR v_song IN SELECT song_id FROM song LOOP
        -- Entre 1 y 3 artistas por canción
        v_num_artists := floor(random() * 3 + 1);

        FOR v_artist IN
            SELECT artist_id
            FROM artist
            ORDER BY random()
            LIMIT v_num_artists
        LOOP
            INSERT INTO song_artist (song_id, artist_id)
            VALUES (v_song.song_id, v_artist.artist_id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Tabla song_artist rellenada con datos aleatorios.';
END;
$$;
SELECT * FROM bd030_schema21.song_artist;
-------------------------------------------------------------------------------------









---------------------INSERT ALBUM_ARTIST----------------------------------
DO
$$
DECLARE
    v_album RECORD;
    v_artist RECORD;
    v_num_artists INT;
BEGIN
    FOR v_album IN SELECT album_id FROM album LOOP
        -- Asignar entre 1 y 3 artistas por álbum
        v_num_artists := floor(random() * 3 + 1);

        FOR v_artist IN
            SELECT artist_id
            FROM artist
            ORDER BY random()
            LIMIT v_num_artists
        LOOP
            INSERT INTO album_artist (album_id, artist_id)
            VALUES (v_album.album_id, v_artist.artist_id)
            ON CONFLICT DO NOTHING;  -- evita duplicados por la PK compuesta
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Tabla album_artist rellenada con datos aleatorios.';
END;
$$;

-- Verificar los datos generados
SELECT * FROM album_artist;
-------------------------------------------------------------------------------








------------------------INSERT SONG_GENRE------------------------------------
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

SELECT * FROM song_genre

--------------------------------------------------------------------------------


















-- -----------------------------INSERT PLAYLIST---------------------------------------
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
------------------------------------------------------------------








----------------------------INSERT PLAY_HISTORY--------------------------------
DO $$
DECLARE
    r_user RECORD;
    r_song RECORD;
    r_device RECORD;
    r_playlist RECORD;
    v_count INT;
BEGIN
    -- Recorremos todos los usuarios
    FOR r_user IN SELECT user_id FROM users LOOP

        -- Cada usuario genera entre 3 y 10 reproducciones
        v_count := 3 + floor(random() * 8);

        FOR i IN 1..v_count LOOP
            -- Escoge una canción aleatoria distinta
            SELECT song_id, song_duration
            INTO r_song
            FROM song
            ORDER BY random()
            LIMIT 1;

            -- Escoge un dispositivo aleatorio
            SELECT device_id
            INTO r_device
            FROM device
            ORDER BY random()
            LIMIT 1;

            -- Escoge una playlist del usuario (si tiene)
            SELECT playlist_id
            INTO r_playlist
            FROM playlist
            WHERE user_id = r_user.user_id
            ORDER BY random()
            LIMIT 1;

            -- Inserta la reproducción
            INSERT INTO play_history (
                playback_id, user_id, song_id, device_id, playlist_id, 
                play_date, duration_played, completed
            )
            VALUES (
                'PH' || lpad(nextval('play_history_seq')::text, 7, '0'),
                r_user.user_id,
                r_song.song_id,
                r_device.device_id,
                CASE WHEN random() < 0.5 THEN r_playlist.playlist_id ELSE NULL END,
                current_date - (floor(random() * 365))::int,
                ROUND((r_song.song_duration * (0.5 + random() * 0.5))::numeric, 2),
                (random() < 0.8)
            );
        END LOOP;
    END LOOP;
END $$;

SELECT * FROM play_history
---------------------------------------------------------------------------------------


