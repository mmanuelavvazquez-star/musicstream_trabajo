CREATE SCHEMA bd030_schema21;
SET search_path TO bd030_schema21 ;




GRANT CREATE ON SCHEMA public TO public;

--TABLE Users
CREATE TABLE users (
    user_id VARCHAR(100) PRIMARY KEY,
    user_nick VARCHAR(100) UNIQUE,
    first_name VARCHAR(100),
    surname VARCHAR(100),
    user_password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(100) UNIQUE,
    date_birth DATE,
    age INT CHECK (age>0),
    country VARCHAR(100),
    profile_picture VARCHAR(200),
    user_biography TEXT
);


--TABLE User_Free
CREATE TABLE User_Free( 
    user_id VARCHAR(20) PRIMARY KEY,
    stream_quality VARCHAR(20),
    adverts_limits INT CHECK (adverts_limits>0),
    minutes_free INT CHECK (minutes_free>0),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

--TABLE User_Premium
CREATE TABLE User_Premium (
    user_id VARCHAR(20) PRIMARY KEY,
    premium_quiality VARCHAR (20),
    download_music BOOLEAN,
    subscription_id VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

--TABLE subscription_plan
 CREATE TABLE subscription_plan (
    subscription_id VARCHAR(50),
    user_id VARCHAR(20),
    subscription_name VARCHAR(30) NOT NULL,
    duration_months INT CHECK (duration_months>0),
    price NUMERIC(4,2) CHECK (price>=0),
    subscription_status VARCHAR(20),
    subscription_description VARCHAR (50),
    max_devices INT CHECK (max_devices>0),
    PRIMARY KEY (subscription_id,user_id),
    FOREIGN KEY (user_id) REFERENCES User_Premium(user_id)
    ON DELETE CASCADE
 );


--TABLE device
CREATE TABLE device (
    device_id VARCHAR(30) PRIMARY KEY,
    device_name VARCHAR(50),
    device_type VARCHAR(50),
    registration_date DATE
);

--TABLE artist
CREATE TABLE artist (
    artist_id VARCHAR(100) PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    artist_country VARCHAR(100),
    artist_date_birth DATE,
    artist_biography TEXT,
    active_since DATE
);

--TABLE album
CREATE TABLE album (
    album_id VARCHAR(20) PRIMARY KEY,
    album_name VARCHAR(50) NOT NULL,
    album_release_date DATE,
    album_type VARCHAR(30) NOT NULL,
    total_tracks INT CHECK(total_tracks>0),
    album_duration NUMERIC(4,2)
);

CREATE TABLE song(
    song_id VARCHAR(20) PRIMARY KEY,
    song_title VARCHAR(100) NOT NULL,
    song_duration NUMERIC(4,2),
    song_release_date DATE,
    play_count INT DEFAULT 0 CHECK (play_count>=0),
    is_single BOOLEAN,
    album_id VARCHAR(20),
    FOREIGN KEY (album_id) REFERENCES album(album_id)
)


CREATE TABLE song_artist (
    song_id   VARCHAR(20),
    artist_id VARCHAR(20),
    PRIMARY KEY (song_id, artist_id),
    FOREIGN KEY (song_id) REFERENCES song(song_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

CREATE TABLE album_artist (
    album_id  VARCHAR(20),
    artist_id VARCHAR(20),
    PRIMARY KEY (album_id, artist_id),
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

CREATE TABLE genre (
    genre_id VARCHAR(20) PRIMARY KEY,
    genre_name VARCHAR(50),
    genre_description TEXT,
    genre_origin_country VARCHAR(50),
    creation_year INT CHECK(creation_year>0),
    popularity VARCHAR(20)
);


CREATE TABLE song_genre (
    song_id  VARCHAR(20),
    genre_id VARCHAR(20),
    PRIMARY KEY (song_id, genre_id),
    FOREIGN KEY (song_id) REFERENCES song(song_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE play_history (
    playback_id  VARCHAR(20) PRIMARY KEY,
    user_id  VARCHAR(20) NOT NULL,
    song_id  VARCHAR(20) NOT NULL,
    device_id  VARCHAR(20),
    playlist_id VARCHAR(20),     
    play_date  DATE,
    duration_played DECIMAL(6,2),
    completed BOOLEAN,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE,
    FOREIGN KEY (song_id) REFERENCES song(song_id),
    FOREIGN KEY (device_id) REFERENCES device(device_id)
);

SELECT * FROM play_history

CREATE TABLE playlist (
    playlist_id VARCHAR(20) PRIMARY KEY,
    playlist_title VARCHAR(100),
    playlist_description TEXT,
    total_songs INT CHECK (total_songs>0),
    playlist_duration DECIMAL(6,2) CHECK (playlist_duration>0),
    cover_photo  VARCHAR(200),
    user_id  VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);






CREATE OR REPLACE FUNCTION update_album_duration()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE album
    SET album_duration = (
        SELECT COALESCE(SUM(song_duration), 0)
        FROM song
        WHERE album_id = NEW.album_id
    )
    WHERE album_id = NEW.album_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2️⃣ Crear trigger tras INSERT o DELETE
CREATE TRIGGER trg_update_album_duration
AFTER INSERT OR DELETE ON song
FOR EACH ROW
EXECUTE FUNCTION update_album_duration();



-- 1️⃣ Función del trigger
CREATE OR REPLACE FUNCTION check_user_exclusivity()
RETURNS TRIGGER AS $$
DECLARE
    is_premium BOOLEAN;
    is_free BOOLEAN;
BEGIN
    -- Verifica si el usuario ya existe en user_free
    SELECT EXISTS (SELECT 1 FROM user_free WHERE user_id = NEW.user_id) INTO is_free;

    -- Verifica si el usuario ya existe en user_premium
    SELECT EXISTS (SELECT 1 FROM user_premium WHERE user_id = NEW.user_id) INTO is_premium;

    -- Si el usuario ya está en una tabla, impedir que esté en la otra
    IF (TG_TABLE_NAME = 'user_free' AND is_premium) THEN
        RAISE EXCEPTION 'El usuario % ya es Premium, no puede ser Free.', NEW.user_id;
    ELSIF (TG_TABLE_NAME = 'user_premium' AND is_free) THEN
        RAISE EXCEPTION 'El usuario % ya es Free, no puede ser Premium.', NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger sobre user_free
CREATE TRIGGER trg_check_exclusivity_free
BEFORE INSERT ON user_free
FOR EACH ROW
EXECUTE FUNCTION check_user_exclusivity();

-- Trigger sobre user_premium
CREATE TRIGGER trg_check_exclusivity_premium
BEFORE INSERT ON user_premium
FOR EACH ROW
EXECUTE FUNCTION check_user_exclusivity();





CREATE OR REPLACE FUNCTION delete_subscription_when_premium_removed()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM subscription_plan WHERE user_id = OLD.user_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_subscription_on_premium_remove
AFTER DELETE ON user_premium
FOR EACH ROW
EXECUTE FUNCTION delete_subscription_when_premium_removed();


CREATE OR REPLACE FUNCTION mark_song_as_single()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.album_id IS NULL THEN
        NEW.is_single := TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mark_single_song
BEFORE INSERT ON song
FOR EACH ROW
EXECUTE FUNCTION mark_song_as_single();


CREATE OR REPLACE FUNCTION validate_song_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.song_duration < 0.10 OR NEW.song_duration > 20.00 THEN
        RAISE EXCEPTION 'Duración inválida (%. Debe estar entre 0.10 y 20.00 minutos).', NEW.song_duration;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_song_duration
BEFORE INSERT OR UPDATE ON song
FOR EACH ROW
EXECUTE FUNCTION validate_song_duration();



INSERT INTO song (song_id, song_title, song_duration, song_release_date, play_count, is_single)
VALUES ('S_ERR1', 'Canción muy corta', 0.05, '2023-01-01', 0, TRUE);



-- NORA: Trigger para actualizar play_count al reproducir una cancion

CREATE OR REPLACE FUNCTION update_song_play_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE song 
    SET play_count = play_count + 1 --Incrementamos contador de repros de la cancion
    WHERE song_id = NEW.song_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creamos trigger después de que se inserten datos en play_history (cada vez q se actualiza el historial de reproduccion, el atributo play_count de dicha cancion aumenta por 1)
CREATE TRIGGER trg_update_song_play_count
AFTER INSERT ON play_history 
FOR EACH ROW
EXECUTE FUNCTION update_song_play_count();

-- NORA: mi switch 
CREATE VIEW top_10_songs AS
SELECT 
    s.song_id,
    s.song_title,
    s.play_count,
    a.artist_name,
    s.song_duration
FROM song s
JOIN song_artist sa ON s.song_id = sa.song_id
JOIN artist a ON sa.artist_id = a.artist_id
ORDER BY s.play_count DESC
LIMIT 10;















