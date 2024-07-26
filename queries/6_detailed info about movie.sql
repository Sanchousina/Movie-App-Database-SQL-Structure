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
        'last_name', p.last_name,
		'photo', json_build_object (
			'file_id', pf.file_id,
        	'file_name', pf.file_name,
        	'mime_type', pf.mime_type,
        	'key', pf.key,
        	'url', pf.url
		)
    ) AS "Director",
	(
        SELECT json_agg(json_build_object(
            'id', pa.person_id,
            'first_name', pa.first_name,
            'last_name', pa.last_name,
            'photo', json_build_object(
                'file_id', af.file_id,
                'file_name', af.file_name,
                'mime_type', af.mime_type,
                'key', af.key,
                'url', af.url
            )
        ))
        FROM MovieCharacterPerson mcp
        LEFT JOIN Person pa ON mcp.person_id = pa.person_id
        LEFT JOIN File af ON p.primary_photo = af.file_id
        WHERE mcp.movie_id = m.movie_id
    ) AS "Actors",
	(
        SELECT json_agg(json_build_object(
            'id', g.genre_id,
            'name', g.name
        ))
        FROM MovieGenre mg
        LEFT JOIN Genre g ON mg.genre_id = g.genre_id
        WHERE mg.movie_id = m.movie_id
    ) AS "Genres"
FROM Movie m
LEFT JOIN File f on f.file_id = m.poster
LEFT JOIN Person p on p.person_id = m.director
LEFT JOIN File pf on p.primary_photo = pf.file_id
WHERE m.movie_id = 1
GROUP BY 
    m.movie_id, 
    m.movie_title, 
    m.release_date, 
    m.duration, 
    m.description, 
    f.file_id, 
    f.file_name, 
    f.mime_type, 
    f.key, 
    f.url, 
    p.person_id, 
    p.first_name, 
    p.last_name, 
    pf.file_id, 
    pf.file_name, 
    pf.mime_type, 
    pf.key, 
    pf.url;