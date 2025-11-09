CREATE SCHEMA bd030_schema21;
SET search_path TO bd030_schema21 ;



--CREATION OF THE TABLES FOLLOWING THE ER DIAGRAM


--We created the table "Users"
CREATE TABLE users (
    user_id VARCHAR(100) PRIMARY KEY, 
    user_nick VARCHAR(100) UNIQUE,
    first_name VARCHAR(100),
    surname VARCHAR(100),
    user_password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(100) UNIQUE,
    date_birth DATE,
    age INT CHECK (age>0), --Age constraint: must be greater than 0.
    country VARCHAR(100),
    profile_picture VARCHAR(200),
    user_biography TEXT
);



--We created the table "User_Free"
CREATE TABLE User_Free( 
    user_id VARCHAR(20) PRIMARY KEY,
    stream_quality VARCHAR(20),
    adverts_limits INT CHECK (adverts_limits>0), --Adverts_limits constraint: must be greater than 0.
    minutes_free INT CHECK (minutes_free>0), --Minutes_free constrainst: must be greater than 0.
    FOREIGN KEY (user_id) REFERENCES users (user_id) -- Establishes a foreign key relationship with the users table.
    -- Automatically deletes or updates related records when the referenced user is deleted or updated.
    ON DELETE CASCADE
    ON UPDATE CASCADE
);




--We created the table "User_Premium"
CREATE TABLE User_Premium (
    user_id VARCHAR(20) PRIMARY KEY,
    premium_quiality VARCHAR (20),
    download_music BOOLEAN,
    subscription_id VARCHAR(20) NOT NULL, -- Business rule: Premium users must have an active subscription.
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    -- Automatically deletes or updates related records when the referenced user_id is deleted or updated.
    ON DELETE CASCADE
    ON UPDATE CASCADE
);





--We create the table "Subscription_plan"
 CREATE TABLE subscription_plan (
    subscription_id VARCHAR(50),
    user_id VARCHAR(20),
    subscription_name VARCHAR(30) NOT NULL,
    duration_months INT CHECK (duration_months>0), -- Constraint: the subscription must last a positive number of months.
    price NUMERIC(4,2) CHECK (price>=0), -- Constraint: the price must be a positive value.
    subscription_status VARCHAR(20),
    subscription_description VARCHAR (50),
    max_devices INT CHECK (max_devices>0), --Constraint: the number of devices must be a positive value.
    PRIMARY KEY (subscription_id,user_id),
    FOREIGN KEY (user_id) REFERENCES User_Premium(user_id)
    -- Automatically deletes or updates related records when the referenced user_id is deleted or updated.
    ON DELETE CASCADE
    ON UPDATE CASCADE
 );






--We create the table "Device"
CREATE TABLE device (
    device_id VARCHAR(30) PRIMARY KEY,
    device_name VARCHAR(50),
    device_type VARCHAR(50),
    registration_date DATE
);





--We create the table "Artist"
CREATE TABLE artist (
    artist_id VARCHAR(100) PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    artist_country VARCHAR(100),
    artist_date_birth DATE,
    artist_biography TEXT,
    active_since DATE
);





--We create the table "Album"
CREATE TABLE album (
    album_id VARCHAR(20) PRIMARY KEY,
    album_name VARCHAR(50) NOT NULL,
    album_release_date DATE,
    album_type VARCHAR(30) NOT NULL,
    total_tracks INT CHECK(total_tracks>0), -- Constraint: the number of songs must be a positive value.
    album_duration NUMERIC(4,2)
);








--We create the table "Song"
CREATE TABLE song(
    song_id VARCHAR(20) PRIMARY KEY,
    song_title VARCHAR(100) NOT NULL, -- every song must have a non-null title.
    song_duration NUMERIC(4,2),
    song_release_date DATE,
    play_count INT DEFAULT 0 CHECK (play_count>=0),
    is_single BOOLEAN,
    album_id VARCHAR(20),
    FOREIGN KEY (album_id) REFERENCES album(album_id),
    --if is_single es TRUE, then it is not in the album
    CHECK ((is_single = TRUE AND album_id IS NULL) OR (is_single = FALSE AND album_id IS NOT NULL)
    )
);




-- We create the relation "Song_Artist"
CREATE TABLE song_artist (
    song_id   VARCHAR NOT NULL,
    artist_id VARCHAR NOT NULL,
    PRIMARY KEY (song_id, artist_id),
    FOREIGN KEY (song_id) REFERENCES song(song_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);





-- We create the relation "Album_Artist"
CREATE TABLE album_artist ( 
    album_id VARCHAR NOT NULL, 
    artist_id VARCHAR NOT NULL, 
    PRIMARY KEY (album_id, artist_id), 
    FOREIGN KEY (album_id) 
    REFERENCES album(album_id), 
    FOREIGN KEY (artist_id) 
    REFERENCES artist(artist_id) 
    );







--We create the table "Genre"
CREATE TABLE genre (
    genre_id VARCHAR(20) PRIMARY KEY,
    genre_name VARCHAR(50),
    genre_description TEXT,
    genre_origin_country VARCHAR(50),
    creation_year INT CHECK(creation_year>0), -- Constraint: the year of origin must be a valid and coherent year.
    popularity VARCHAR(20)
);



--We create the table "Song_genre"
CREATE TABLE song_genre (
    song_id  VARCHAR(20),
    genre_id VARCHAR(20),
    PRIMARY KEY (song_id, genre_id),
    FOREIGN KEY (song_id) REFERENCES song(song_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);



--We create the table "Play_History"
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






--We create the table "Playlist"
CREATE TABLE playlist (
    playlist_id VARCHAR(20) PRIMARY KEY,
    playlist_title VARCHAR(100),
    playlist_description TEXT,
    total_songs INT CHECK (total_songs>0),
    playlist_duration DECIMAL(6,2) CHECK (playlist_duration>0),
    cover_photo  VARCHAR(200),
    user_id  VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
























--TRIGGER 1

-- Updates the duration of an album every time a song is inserted
CREATE OR REPLACE FUNCTION update_album_duration()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE album
    SET album_duration = (
        -- Calculates the total duration of the songs; if there are no songs in the album, returns 0
        SELECT COALESCE(SUM(song_duration), 0)
        FROM song

        WHERE album_id = NEW.album_id
    )
    WHERE album_id = NEW.album_id;
    -- Return the newly inserted or updated song row
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--Create the trigger that will run after an insert or delete
CREATE TRIGGER trg_update_album_duration
AFTER INSERT OR DELETE ON song
FOR EACH ROW
EXECUTE FUNCTION update_album_duration();












--TRIGGER 2
--A user cannot be Free and Premium at the same time
CREATE OR REPLACE FUNCTION check_user_exclusivity()
RETURNS TRIGGER AS $$
DECLARE
    --We create two boolean variables that will help us determine which user is free and which is premium.
    is_premium BOOLEAN;
    is_free BOOLEAN;
BEGIN
    --Check if the user already exists in user_free.
    SELECT EXISTS (SELECT 1 FROM user_free WHERE user_id = NEW.user_id) INTO is_free;

    -- Check if the user already exists in user_premium.
    SELECT EXISTS (SELECT 1 FROM user_premium WHERE user_id = NEW.user_id) INTO is_premium;

    -- If the user is already in one table, prevent them from being in the other.
    IF (TG_TABLE_NAME = 'user_free' AND is_premium) THEN
        RAISE EXCEPTION 'El usuario % ya es Premium, no puede ser Free.', NEW.user_id;
    ELSIF (TG_TABLE_NAME = 'user_premium' AND is_free) THEN
        RAISE EXCEPTION 'El usuario % ya es Free, no puede ser Premium.', NEW.user_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger that checks the condition before adding a free user.
CREATE TRIGGER trg_check_exclusivity_free
BEFORE INSERT ON user_free
FOR EACH ROW
EXECUTE FUNCTION check_user_exclusivity();

-- Create the trigger that checks the condition before adding a premium user.
CREATE TRIGGER trg_check_exclusivity_premium
BEFORE INSERT ON user_premium
FOR EACH ROW
EXECUTE FUNCTION check_user_exclusivity();








--TRIGGER 3 
--Make the subscription cancel when a premium user is deleted.
CREATE OR REPLACE FUNCTION delete_subscription_when_premium_removed()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete the corresponding row in the subscription_plan table where the user_id matches the deleted user
    DELETE FROM subscription_plan WHERE user_id = OLD.user_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger that calls the above function after a premium user is deleted
CREATE TRIGGER trg_delete_subscription_on_premium_remove
AFTER DELETE ON user_premium
FOR EACH ROW
EXECUTE FUNCTION delete_subscription_when_premium_removed();




--TRIGGER 4
-- Function that marks a song as a single if it is not associated with an album
CREATE OR REPLACE FUNCTION mark_song_as_single()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the new song being inserted has no album_id
    IF NEW.album_id IS NULL THEN
    -- If no album is assigned, mark the song as a single
        NEW.is_single := TRUE;
    END IF;
    -- Return the new row with the updated is_single value
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger that calls the above function before inserting a song
CREATE TRIGGER trg_mark_single_song
BEFORE INSERT ON song
FOR EACH ROW
EXECUTE FUNCTION mark_song_as_single();



--TRIGGER 5
-- Function that validates the duration of a song
CREATE OR REPLACE FUNCTION validate_song_duration()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if the new song duration is outside the allowed range
    IF NEW.song_duration < 0.10 OR NEW.song_duration > 20.00 THEN
         -- Raise an exception if the duration is invalid
        RAISE EXCEPTION 'Duración inválida (%. Debe estar entre 0.10 y 20.00 minutos).', NEW.song_duration;
    END IF;
    -- Return the new row if duration is valid
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger that calls the above function before inserting or updating a song
CREATE TRIGGER trg_validate_song_duration
BEFORE INSERT OR UPDATE ON song
FOR EACH ROW
EXECUTE FUNCTION validate_song_duration();



INSERT INTO song (song_id, song_title, song_duration, song_release_date, play_count, is_single)
VALUES ('S_ERR1', 'Canción muy corta', 0.05, '2023-01-01', 0, TRUE);





--TRIGGER 6
-- Trigger to update play_count when a song is played
CREATE OR REPLACE FUNCTION update_song_play_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment the play_count of the song being played
    UPDATE song 
    SET play_count = play_count + 1
    WHERE song_id = NEW.song_id;
    
    -- Return the new row (required for AFTER INSERT triggers)
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger that runs after a new entry is inserted into play_history
CREATE TRIGGER trg_update_song_play_count
AFTER INSERT ON play_history        
FOR EACH ROW                        
EXECUTE FUNCTION update_song_play_count();  -- Calls the function to update play_count







--TRIGGER 7
CREATE OR REPLACE FUNCTION check_single_song_association()
RETURNS TRIGGER AS $$
DECLARE
    is_single_value BOOLEAN;
BEGIN
    -- Check if the song is a single
    SELECT is_single INTO is_single_value
    FROM song
    WHERE song_id = NEW.song_id;

    -- If the song is a single, it cannot be associated with any album
    IF is_single_value THEN
        RAISE EXCEPTION 'The song % is a single and cannot be associated with an album.', NEW.song_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_single_song_association
BEFORE INSERT OR UPDATE ON song_album_artist
FOR EACH ROW
EXECUTE FUNCTION check_single_song_association





--TRIGGER 8
-- Prevent a Free User from listening more minutes than allowed
SELECT * FROM User_Free;

CREATE OR REPLACE FUNCTION check_minutes()
-- This function is designed to be executed within a trigger
RETURNS TRIGGER
AS $$
DECLARE
    total_minutes INT;      -- Maximum number of allowed minutes
    total_played INT;       -- Number of minutes already played
BEGIN
    -- Check if the user is Free; if not (Premium), the trigger does nothing
    IF EXISTS (
        SELECT *
        FROM User_Free
        WHERE user_id = NEW.user_id  -- Check if the user being inserted is Free
    ) THEN
        -- Store the total allowed minutes for this user in total_minutes
        SELECT minutes_free INTO total_minutes 
        FROM User_Free 
        WHERE user_id = NEW.user_id;

        -- Calculate how many minutes the user has already listened to
        -- COALESCE returns 0 instead of NULL if no play history exists
        SELECT COALESCE(SUM(duration_played), 0)
        INTO total_played
        FROM play_history
        WHERE user_id = NEW.user_id;

        -- If the minutes being added plus already played exceed the limit, raise an error
        IF (total_played + NEW.duration_played) > total_minutes THEN
            RAISE EXCEPTION 'User % has exceeded their free minutes limit (% minutes)', NEW.user_id, total_minutes;
        END IF;

    END IF;

    -- If the user is not Free or has not exceeded the limit, allow the insert/update
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger that runs before inserting or updating play history
CREATE TRIGGER trg_check_minutes
BEFORE INSERT OR UPDATE ON play_history
FOR EACH ROW
EXECUTE FUNCTION check_minutes();

-- View current data
SELECT * FROM play_history;
SELECT * FROM song;


INSERT INTO play_history (playback_id, user_id, song_id, play_date, duration_played, completed)
VALUES ('PH0000901', 'U00009','S006712', CURRENT_DATE, 2, TRUE);


--TRIGGER 9 
--Automatically record the last playback date in the users table when a song is played.

ALTER TABLE users ADD COLUMN last_play_date DATE;

CREATE OR REPLACE FUNCTION update_last_play_date()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE users
    SET last_play_date = NEW.play_date
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_last_play_date
AFTER INSERT ON play_history
FOR EACH ROW
EXECUTE FUNCTION update_last_play_date();
