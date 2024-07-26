 SELECT 
	m.movie_id as "ID",
	m.movie_title as "Title",
	m.release_date as "Release date",
	m.duration as "Duration",
	m.description as "Description",
	 json_build_object(
        'file_id', f.file_id,
        'file_name', f.file_name,
        'mime_type', f.mime_type,
        'key', f.key,
        'url', f.url
    ) AS "Poster",
	json_build_object(
        'id', p.person_id,
        'first_name', p.first_name,
        'last_name', p.last_name
    ) AS "Director"
FROM Movie m
LEFT JOIN File f on f.file_id = m.poster
LEFT JOIN MovieGenre mg on m.movie_id = mg.movie_id
LEFT JOIN Genre g on g.genre_id = mg.genre_id 
LEFT JOIN Person p on p.person_id = m.director
WHERE (
	m.country = 1 AND 
	date_part('year', m.release_date) >= '2022' 
	AND m.duration > 135
	AND g.name IN ('Action', 'Drama')
	)
GROUP BY (m.movie_id, m.movie_title, m.release_date, 
	 m.duration, m.description, p.person_id, p.first_name, 
	 p.last_name, f.file_id, f.file_name, f.mime_type, f.key, f.url); 
