 CREATE SCHEMA bd030_schema21;
 SET search_path TO bd030_schema21, public;

SELECT current_user
GRANT CREATE ON SCHEMA public TO public;

CREATE TABLE users (
    user_id VARCHAR(20) PRIMARY KEY,
    user_nick VARCHAR(30) UNIQUE,
    first_name VARCHAR(20),
    surname VARCHAR(20),
    user_password VARCHAR(50) NOT NULL,
    email VARCHAR(20) UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    date_birth DATE,
    age INT CHECK (age>0),
    country VARCHAR(20),
    profile_picture VARCHAR(200),
    user_biography TEXT
);

CREATE TABLE User_Free( 
    user_id VARCHAR(20) PRIMARY KEY,
    stream_quality VARCHAR(20),
    adverts_limits INT CHECK (adverts_limits>0),
    minutes_free INT CHECK (minutes_free>0),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE User_Premium (
    user_id VARCHAR(20) PRIMARY KEY,
    premium_quiality VARCHAR (20),
    download_music BOOLEAN,
    subscription_id VARCHAR(20) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE

);

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

CREATE TABLE device (
    device_id VARCHAR(30) PRIMARY KEY,
    device_name VARCHAR(50),
    device_type VARCHAR(50),
    registration_date DATE
);

CREATE TABLE artist (
    artist_id VARCHAR(20) PRIMARY KEY,
    artist_name VARCHAR(20) NOT NULL,
    artist_country VARCHAR(20),
    artist_date_birth DATE,
    artist_biography TEXT,
    active_since DATE
);

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




CREATE OR REPLACE FUNCTION validar_nombre_playlist()
RETURNS TRIGGER
AS $$
BEGIN
    IF EXISTS (
        SELECT * 
        FROM playlist
        WHERE nombre = NEW.nombre
        AND id_usuario = NEW.id_usuario
    ) THEN
        RAISE EXCEPTION 'Ya existe una playlist con ese nombre para este usuario';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_playlist_unica
BEFORE INSERT ON playlists
FOR EACH ROW
EXECUTE FUNCTION validar_nombre_playlist();



















