CREATE TYPE gender_type AS ENUM ('female', 'male', 'other');
CREATE TYPE person_type AS ENUM ('actor', 'director', 'other');
CREATE TYPE character_type AS ENUM ('leading', 'supporting', 'background');

DROP TABLE IF EXISTS "File";

CREATE TABLE File (
    file_id SERIAL PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    key VARCHAR(1024) NOT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "Country";

CREATE TABLE Country (
    country_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "Person";

CREATE TABLE Person (
    person_id SERIAL PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    biography TEXT,
    birth_date DATE,
    gender gender,
    primary_photo INT REFERENCES File(file_id) ON DELETE SET NULL,
    country INT REFERENCES Country(country_id) ON DELETE SET NULL,
    role person_type NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "PersonPhoto";

CREATE TABLE PersonPhoto (
    photo_id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES Person(person_id) ON DELETE CASCADE,
    file_id INT NOT NULL REFERENCES File(file_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "User";

CREATE TABLE "User" (
	user_id SERIAL PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE,
	password VARCHAR(100) NOT NULL,
	avatar INT REFERENCES File(file_id) ON DELETE SET NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "Genre";

CREATE TABLE Genre (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "Movie";

CREATE TABLE Movie (
    movie_id SERIAL PRIMARY KEY,
    movie_title VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    budget INT,
    release_date DATE,
    duration INT,
    poster INT REFERENCES File(file_id) ON DELETE SET NULL,
    director INT NOT NULL REFERENCES Person(person_id) ON DELETE SET NULL,
    country INT NOT NULL REFERENCES Country(country_id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "Character";

CREATE TABLE Character (
    character_id SERIAL PRIMARY KEY,
    movie_id INT NOT NULL REFERENCES Movie(movie_id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    role character_type NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "MovieGenre";

CREATE TABLE MovieGenre (
    movie_id INT NOT NULL REFERENCES Movie(movie_id) ON DELETE CASCADE,
    genre_id INT NOT NULL REFERENCES Genre(genre_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (movie_id, genre_id)
);

DROP TABLE IF EXISTS "FavoriteMovies";

CREATE TABLE FavoriteMovies (
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    movie_id INT NOT NULL REFERENCES Movie(movie_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, movie_id)
);

DROP TABLE IF EXISTS "MovieCharacterPerson";

CREATE TABLE MovieCharacterPerson (
    id SERIAL PRIMARY KEY,
    character_id INT REFERENCES Character(character_id) ON DELETE SET NULL,
    person_id INT REFERENCES Person(person_id) ON DELETE SET NULL,
    movie_id INT NOT NULL REFERENCES Movie(movie_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CHECK (
        (character_id IS NULL AND person_id IS NOT NULL) OR 
        (character_id IS NOT NULL AND person_id IS NULL) OR 
        (character_id IS NOT NULL AND person_id IS NOT NULL)
    )
);

CREATE OR REPLACE FUNCTION check_duplicate_moviecharacterperson()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM MovieCharacterPerson
        WHERE NEW.movie_id = movie_id
          AND (NEW.character_id IS NOT DISTINCT FROM character_id)
          AND (NEW.person_id IS NOT DISTINCT FROM person_id)
    ) THEN
        RAISE EXCEPTION 'Duplicate entry for movie_id, character_id, and person_id';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_MovieCharacterPerson
BEFORE INSERT OR UPDATE ON MovieCharacterPerson
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_moviecharacterperson();
