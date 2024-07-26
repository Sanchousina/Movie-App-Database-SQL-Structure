SELECT 
	p.person_id as "ID",
	p.first_name as "First name",
	p.last_name as "Last name",
	SUM(m.budget) as "Total movies budget"
	FROM Person p    
LEFT JOIN (
	SELECT DISTINCT person_id, movie_id from MovieCharacterPerson
	) mcp on p.person_id = mcp.person_id
LEFT JOIN Movie m on mcp.movie_id = m.movie_id
WHERE p.role = 'actor'
GROUP BY p.person_id, p.first_name, p.last_name;

