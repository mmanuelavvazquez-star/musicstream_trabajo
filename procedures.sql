
SET search_path TO bd030_schema21 ;

--1
CREATE OR REPLACE FUNCTION total_minutes_user(p_user_id VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(duration_played), 0)
    INTO total
    FROM play_history
    WHERE user_id = p_user_id;

    RETURN total;
END;
$$ LANGUAGE plpgsql;


SELECT total_minutes_user('user_1');



--2
CREATE OR REPLACE FUNCTION top_5_songs()
RETURNS TABLE(song_id VARCHAR, song_title VARCHAR, reproductions BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT s.song_id, s.song_title, COUNT(ph.playback_id)
    FROM song s
    JOIN play_history ph ON s.song_id = ph.song_id
    GROUP BY s.song_id, s.song_title
    ORDER BY COUNT(ph.playback_id) DESC
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM top_5_songs();



--3
CREATE OR REPLACE FUNCTION top_genres_by_user(p_user_id VARCHAR)
RETURNS TABLE(genre_name VARCHAR, reproductions INT) AS $$
BEGIN
    RETURN QUERY
    SELECT g.genre_name, COUNT(ph.playback_id) AS reproductions
    FROM play_history ph
    JOIN song s ON ph.song_id = s.song_id
    JOIN song_genre sg ON s.song_id = sg.song_id
    JOIN genre g ON sg.genre_id = g.genre_id
    WHERE ph.user_id = p_user_id
    GROUP BY g.genre_name
    ORDER BY reproductions DESC
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;


--4
--Obtener duración total de playlists de un usuario
CREATE OR REPLACE FUNCTION total_playlist_duration(p_user_id VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    total_duration NUMERIC := 0;
BEGIN
    SELECT COALESCE(SUM(playlist_duration), 0)
    INTO total_duration
    FROM playlist
    WHERE user_id = p_user_id;

    RETURN total_duration;
END;
$$ LANGUAGE plpgsql;

SELECT total_playlist_duration('user_1');



--5
--Comprobar si un usuario es premium
CREATE OR REPLACE FUNCTION user_type(p_user_id VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    type_user VARCHAR;
BEGIN
    IF EXISTS (SELECT 1 FROM user_premium WHERE user_id = p_user_id) THEN
        type_user := 'Premium';
    ELSIF EXISTS (SELECT 1 FROM user_free WHERE user_id = p_user_id) THEN
        type_user := 'Free';
    ELSE
        type_user := 'Unknown';
    END IF;

    RETURN type_user;
END;
$$ LANGUAGE plpgsql;

Llamada a la funcion: SELECT user_type('U00010');






--VIEW 
Resumen de actividad del usuario

CREATE OR REPLACE VIEW v_user_activity_summary AS
SELECT 
    u.user_id,
    u.user_nick,
    COUNT(DISTINCT ph.playback_id) AS total_plays,
    COUNT(DISTINCT ph.song_id) AS unique_songs,
    ROUND(SUM(ph.duration_played), 2) AS total_minutes,
    ROUND(AVG(ph.duration_played), 2) AS avg_minutes_per_song,
    MAX(ph.play_date) AS last_play_date
FROM users u
LEFT JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.user_id, u.user_nick;

SELECT * FROM v_user_activity_summary ORDER BY total_plays DESC LIMIT 10;