SELECT 
	p.person_id as "Director ID",
	p.first_name || ' ' || p.last_name as "Director name",
	AVG(m.budget) as "Average budget"
FROM Person p
LEFT JOIN Movie m on m.director = p.person_id
WHERE p.role = 'director'
GROUP BY p.person_id, p.first_name, p.last_name;