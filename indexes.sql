SET search_path TO bd030_schema21 ;


--INDEXES

--Let us begin with the creation of the indexes for this database. To do so, we will follow the 
--reasons explained for each index in the PDF attached to this submission.

--We will start with the indexes related to the attributes of the Users table.


--USER

--INDEX User_nick
--Let us create an index for the user_nick attribute of the Users table. This column is used in several
-- queries that involve GROUP BY operations, text filtering, and aggregations. Since this attribute has 
--high cardinality and contains unique values for each user, we are working with a considerable variety 
--of data. For this reason, a B-Tree index significantly improves the performance of operations such as 
--grouping and sorting. Without an index, these queries would be much more costly, as the database engine 
--would need to scan all rows sequentially, making the process increasingly heavy as the number of registered
-- users grows.

--INDEX Email
--Let us now consider the email attribute, which appears in text-filtering queries using the LIKE operator. 
--Although this attribute appears less frequently in queries than the ones previously discussed, an index is
-- justified due to the high variety of values in its domain, as each user has a unique email.
--As the number of users increases, the system will need to handle a very large number of email addresses,
-- so having an index that keeps them ordered becomes advantageous. With a B-Tree index, searches based on 
--the email domain can be executed more efficiently, reducing query execution time and improving overall 
--performance.


--However, user_nick is a UNIQUE key, and this constraint automatically generates a B-Tree index on the column in PostgreSQL.
--For this reason, the columns user_id, user_nick, and email already have an automatic index, so there is no need for us to create another one.


--INDEX country
--In the same way as in the previous case, the country attribute appears in multiple queries alongside GROUP BY
-- and ORDER BY operations. Although, with the current data, there is not a high variety within the domain of 
--country, the frequent use of this attribute across several queries makes a B-Tree index a very effective way 
--to reduce query costs. This allows PostgreSQL to group and sort users by their country more quickly and 
--efficiently, reducing execution time as the number of users increases.

CREATE INDEX idx_users_country ON users(country);

--INDEX date_birth
--The date_birth attribute appears in queries that filter date ranges within a specific time interval, 
--using the BETWEEN function. A B-Tree index is very suitable for this situation, as it keeps the values 
--ordered and optimizes comparison operations (in this case, the BETWEEN query).

CREATE INDEX idx_users_date_birth ON users(date_birth);





--PLAY_HISTORY


--INDEX (User_id, Play_date)
--Now let’s move on to the play_history table, which is the one most frequently used in the queries and 
--therefore the one where we will need to create the most indexes.

--We are going to create a composite index on the attributes (user_id, play_date). We create a composite 
--index because these two attributes often appear together and would directly benefit from being indexed 
--as a pair (queries 1, 2, 8, 9, 10, 13…). Many of our queries require calculating the total listening time
-- per user, identifying the most played song, or finding users who haven’t listened to music in the last 
--30 days. Since both attributes are used together in many queries, a composite index would speed up most 
--of them. If we used two separate single-column indexes, PostgreSQL would not combine them efficiently, 
--and the performance would not be as good. It is preferable for PostgreSQL to first sort or filter by 
--user_id, and once the users are sorted, to order or filter the records by play_date. For this reason, 
--user_id should come first in the index definition, followed by play_date.

--Thanks to this composite index, most of the queries will run faster because PostgreSQL can group the 
--records by user first and then filter by dates within those records.


CREATE INDEX idx_ph_user_date ON play_history(user_id, play_date);

--INDEX (song_id)

--Let’s continue with the attributes of this table. The song_id attribute is used in many queries, 
--since a large number of them require counting song plays, filtering by song, or ordering by the number
-- of reproductions. In queries such as 1, 3, 4, 6, 7, and 11, this attribute is used in ordering and 
--grouping expressions (ORDER BY, GROUP BY), as well as in JOIN operations. Thanks to a B-tree index, 
--the database can locate the records for each song almost instantly.

CREATE INDEX idx_ph_song ON play_history(song_id);


--INDEX (device_id)
--For the device_id attribute, which is used for JOINs and filtering, it would also be advisable to create
--an index to speed up these queries. The play_history table is one of the most complex in our project, so 
--queries involving it are very costly; therefore, creating a B-tree index would be highly recommended.
CREATE INDEX idx_ph_device ON play_history(device_id);


--INDEX (playlist_id)

--In several cases, filtering is done by playlist in the queries (counting how many songs have appeared in 
--playlists, summing total duration, etc.). Since it is a foreign key and is heavily used in JOINs, as well
--as in grouping and filtering operations, a B-Tree index is also very useful in this case.
CREATE INDEX idx_play_history_playlist_id ON play_history(playlist_id);



--INDEX (User_id,song_id)
--As we explained earlier, although playback_id also needs a B-Tree index, the system automatically creates 
--one since it is a primary key. Therefore, we can now focus on another composite index that is very useful due
--to how often the two columns appear together in queries: user_id and song_id. In queries like 5, 8, 13, 15, 
--or 20, they appear together in JOINs or require grouping records by both attributes at the same time. Although
--we already have a composite index on other attributes of this table, it does not include song_id, so it does 
--not improve the efficiency of these queries. Therefore, creating a B-Tree index on (user_id, song_id) would 
--reduce the cost of all these queries.
CREATE INDEX idx_ph_user_song ON play_history(user_id, song_id);


--SONG
--Let's move on the table SONG

--INDEX(album_id)
--From this table, we would need two indexes: one for song_id (the system automatically creates it because it 
--is a primary key) and another for album_id, which is a foreign key and is used in JOINs in several of our 
--queries. To speed up this process, we use a B-Tree index that reduces the cost of this operation
CREATE INDEX idx_song_album ON song(album_id);

--INDEX(play_count)
--For attributes such as play_count, it is also worthwhile to create a B-Tree index, since the data is ordered
--and filtered by this column on several occasions
CREATE INDEX idx_song_playcount ON song(play_count);


--For tables such as Artist or Song, we should indeed take into account that there must be an index for 
--attributes like artist_id and song_id, but they are already created.


--SONG_GENRE
--Index(genre_id)
--Although the primary key is (song_id, genre_id), there is no individual index on genre, which is necessary
-- for filters and JOINs involving this attribute. Therefore, creating a B-Tree index would be a good option.
CREATE INDEX idx_song_genre_genre ON song_genre(genre_id);



--In our Song_Artist table, we know that both song_id and artist_id are part of the composite primary key, 
--but there is no index on artist_id alone. This attribute is specifically used in JOINs in some queries, 
--such as 22 and 24; therefore, an index should be created to reduce the cost of these queries.
CREATE INDEX idx_song_artist_artist ON song_artist(artist_id);


--Now, the only thing left to examine is the benefits of indexes and how each type of index works best
-- for certain queries. To do this, let's take the composite index (user_id, song_id) as an example, since
-- it optimizes several of our queries. Let's take one of those queries and see which parts of the tables it optimizes.



EXPLAIN ANALYZE
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

--As we can see in the table generated when we run our EXPLAIN code, this query does indeed make
-- use of our index. This is why we can find the following statements inside the table: Index Only
-- Scan using idx_ph_user_song on play_history.


--To compare the benefits between different types of indexes, we will take the country attribute 
--from the users table as an example, and we will create two indexes on it: one B-Tree index and 
--one Hash index. Then, we will select a query that involves the country attribute, and by analyzing
-- its execution cost, we will see which indexes are used and which one provides the most benefit 
--for this query.

-- Índice B-Tree (por defecto)


-- Índice Hash
CREATE INDEX idx_users_country_hash
ON users USING HASH(country);

EXPLAIN ANALYZE
SELECT u.country, COUNT(p.playlist_id) AS total_playlists
FROM playlist p
-- Join with users to get the country of each playlist creator
JOIN users u ON u.user_id = p.user_id
-- Group results by country to count playlists per country
GROUP BY u.country
-- Order the results by total number of playlists in descending order
ORDER BY total_playlists DESC;

--In the table itself, we can come across statements like this:
--Index Scan using idx_users_country on users u  (cost=0.14..30.92 rows=204 width=15) (actual time=0.076..0.183 rows=204 loops=1)
--This indicates that the index the table is using is a B-Tree, which makes sense, since country is used in a grouping.



--Let’s continue testing our indexes. Now let’s take, for example, the album_id attribute from the song table and create different types of indexes.
-- In this case, for example, it wouldn’t be optimal in any way to consider using a GIN index, since it’s intended for arrays and text, while the domain
-- of album_id is purely integer. Let’s use B-Tree and Hash, create those indexes, and take a test query to see which index performs better.
-- Índice B-Tree para album_id


-- Índice Hash para album_id
CREATE INDEX idx_song_album_hash
ON song USING HASH(album_id);

EXPLAIN ANALYZE
SELECT 
    a.album_type,
    ROUND(AVG(s.song_duration), 2) AS avg_duration
FROM song s
JOIN album a ON s.album_id = a.album_id
GROUP BY a.album_type
HAVING AVG(s.song_duration) IS NOT NULL
ORDER BY avg_duration DESC;

--Although a B-tree index was created on song.album_id, the query that groups by album type does not
--use it. This is because the tables involved are very small, and PostgreSQL considers a sequential
-- scan combined with a Hash Join and HashAggregate more efficient. The index would be useful for queries filtered
-- by a specific album_id or in databases with a large volume of records.



EXPLAIN ANALYZE
SELECT 
    u.user_id, 
    u.user_nick,
    CASE 
        WHEN up.user_id IS NOT NULL THEN 'Premium'
        WHEN uf.user_id IS NOT NULL THEN 'Free'
        ELSE 'Unknown'
    END AS user_type
FROM users u
LEFT JOIN user_premium up ON u.user_id = up.user_id
LEFT JOIN user_free uf ON u.user_id = uf.user_id
WHERE u.user_nick = 'nick_12';





CREATE INDEX idx_subs_active_partial ON subscription_plan(subscription_id, user_id)
WHERE subscription_status = 'Active';

-- Índice BRIN para fechas (tabla grande y secuencial)
CREATE INDEX idx_ph_date_brin ON play_history
USING BRIN(play_date);




--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\º
--TESTEAR INDICES

SET enable_seqscan = OFF;
ANALYZE play_history;

--Insertamos mas regustros en la tabla playhistory para que los índices se usen
INSERT INTO play_history (playback_id, user_id, song_id, play_date)
SELECT
    'PB_' || generate_series(1,10000),
    (SELECT user_id FROM users ORDER BY random() LIMIT 1),
    (SELECT song_id FROM song  ORDER BY random() LIMIT 1),
    CURRENT_DATE - (random() * INTERVAL '365 days')
ON CONFLICT DO NOTHING;

SELECT * FROM play_history


--QUERY 1
--without index
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
EXPLAIN ANALYZE
SELECT s.song_title, COUNT(ph.playback_id)
FROM play_history ph
JOIN song s ON ph.song_id = s.song_id
WHERE ph.play_date >= DATE_TRUNC('month', CURRENT_DATE)
  AND ph.play_date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY s.song_title
ORDER BY 2 DESC
LIMIT 5;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

--with index
EXPLAIN ANALYZE
SELECT s.song_title, COUNT(ph.playback_id)
FROM play_history ph
JOIN song s ON ph.song_id = s.song_id
WHERE ph.play_date >= DATE_TRUNC('month', CURRENT_DATE)
  AND ph.play_date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY s.song_title
ORDER BY 2 DESC
LIMIT 5;


--QUERY 13
ANALYZE play_history
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
EXPLAIN ANALYZE
-- Find who has listened to the song "Selena Gomez 44"
SELECT DISTINCT
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
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
-- Find who has listened to the song "Selena Gomez 44"
SELECT DISTINCT
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


--QUERY 17
ANALYZE users
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
EXPLAIN ANALYZE
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


SET enable_indexscan = ON;
SET enable_bitmapscan = ON;
EXPLAIN ANALYZE
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



--QUERY 16
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;
EXPLAIN ANALYZE
--16
-- Select users whose nickname contains 'a', email ends with '.com', and date of birth is within a range
SELECT user_id, user_nick, first_name, surname, email, country, date_birth
FROM users
WHERE 
    -- User nickname contains the letter 'a'
    user_nick LIKE '%i%'                   
    -- Email ends with '.com'
    AND email LIKE '%.com'                  
    -- Date of birth between January 1, 1990 and December 31, 2000
    AND date_birth BETWEEN '1990-01-01' AND '2000-12-31'  
-- Order results by date of birth in ascending order
ORDER BY date_birth;

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;
EXPLAIN ANALYZE

--16
-- Select users whose nickname contains 'a', email ends with '.com', and date of birth is within a range
SELECT user_id, user_nick, first_name, surname, email, country, date_birth
FROM users
WHERE 
    -- User nickname contains the letter 'a'
    user_nick LIKE '%i%'                   
    -- Email ends with '.com'
    AND email LIKE '%.com'                  
    -- Date of birth between January 1, 1990 and December 31, 2000
    AND date_birth BETWEEN '1990-01-01' AND '2000-12-31'  
-- Order results by date of birth in ascending order
ORDER BY date_birth;


CREATE INDEX idx_users_nick_hash ON users USING HASH(user_nick);
ANALYZE users;
-- Medición SIN índice HASH
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN ANALYZE
UPDATE users
SET country = 'Italy'
WHERE user_nick = 'nick_50';

-- Medición CON índice HASH (si existe)
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
UPDATE users
SET country = 'Italy'
WHERE user_nick = 'nick_50';


--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

    --INSERT
    -- Apagar planes basados en índices para medir SIN índice
    SET enable_indexscan = OFF;
    SET enable_bitmapscan = OFF;

    EXPLAIN ANALYZE
    INSERT INTO play_history (playback_id, user_id, song_id, play_date)
    SELECT
        'PB12_' || generate_series(1, 10000),
        (SELECT user_id FROM users ORDER BY random() LIMIT 1),
        (SELECT song_id FROM song ORDER BY random() LIMIT 1),
        CURRENT_DATE - (random() * INTERVAL '365 days');

    -- Reactivar índices
    SET enable_indexscan = ON;
    SET enable_bitmapscan = ON;

    EXPLAIN ANALYZE
    INSERT INTO play_history (playback_id, user_id, song_id, play_date)
    SELECT
        'PB11_' || generate_series(1, 10000),
        (SELECT user_id FROM users ORDER BY random() LIMIT 1),
        (SELECT song_id FROM song ORDER BY random() LIMIT 1),
        CURRENT_DATE - (random() * INTERVAL '365 days');




-- Desactivar índices para medir SIN índice
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN ANALYZE
UPDATE users
SET country = 'Spain'
WHERE user_id LIKE 'U_%';

-- Reactivar índices
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

-- Medición CON índice disponible
EXPLAIN ANALYZE
UPDATE users
SET country = 'Spain'
WHERE user_id LIKE 'U_%';





CREATE INDEX idx_users_nick_hash ON users USING HASH(user_nick);
ANALYZE users;
-- Medición SIN índice HASH
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN ANALYZE
UPDATE users
SET country = 'Italy'
WHERE user_nick = 'nick_50';

-- Medición CON índice HASH (si existe)
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN ANALYZE
UPDATE users
SET country = 'Italy'
WHERE user_nick = 'nick_50';


-- Experiência 1: SEM índices (users)
DO $$
DECLARE
    inicio timestamp;
    fim timestamp;
    duracao interval;
BEGIN
    inicio := clock_timestamp();
    
    INSERT INTO users (user_id, user_nick, first_name, surname, user_password, email, phone_number, date_birth, age, country)
    SELECT 
        'U1_' || i,
        'nick1_' || i,
        'Name1_' || i,
        'Surname1_' || i,
        'pass1_' || i,
        'user1_' || i || '@example.com',
        '600001' || (100 + i),
        CURRENT_DATE - (random()*INTERVAL '10000 days'),
        (random()*60+1)::integer,
        (ARRAY['Spain','USA','UK','Canada','Mexico','France','Italy'])[floor(random()*7+1)]::text
    FROM generate_series(1, 50000) AS i
    ON CONFLICT DO NOTHING;

    fim := clock_timestamp();
    duracao := fim - inicio;
    
    RAISE NOTICE 'Tempo SEM índices (users): %', duracao;
END $$;

-- Crear índices útiles antes del test
CREATE INDEX idx_users_nick_hash ON users USING HASH(user_nick);
CREATE INDEX idx_users_id_btree ON users USING BTREE(user_id);

ANALYZE users;

-- Experiência 2: COM índices (users)
DO $$
DECLARE
    inicio timestamp;
    fim timestamp;
    duracao interval;
BEGIN
    inicio := clock_timestamp();
    
    INSERT INTO users (user_id, user_nick, first_name, surname, user_password, email, phone_number, date_birth, age, country)
    SELECT 
        'U2_' || i,
        'nick2_' || i,
        'Auto_' || i,
        'User_' || i,
        'pass2_' || i,
        'auto_' || i || '@example.com',
        '61111' || (200 + i),
        CURRENT_DATE - (random()*INTERVAL '10000 days'),
        (random()*60+1)::integer,
        (ARRAY['Spain','USA','UK','Canada','Mexico','France','Italy'])[floor(random()*7+1)]::text
    FROM generate_series(1, 10000) AS i
    ON CONFLICT DO NOTHING;

    fim := clock_timestamp();
    duracao := fim - inicio;
    
    RAISE NOTICE 'Tempo COM índices (users): %', duracao;
END $$;

