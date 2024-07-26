SELECT 
	m.movie_id as "ID", 
	m.movie_title as "Title",
	COUNT(DISTINCT mcp.person_id) as "Actors count"
FROM Movie m
LEFT JOIN MovieCharacterPerson mcp on mcp.movie_id = m.movie_id
WHERE date_part('year', CURRENT_DATE) - date_part('year', release_date) < 5
GROUP BY m.movie_id, m.movie_title;