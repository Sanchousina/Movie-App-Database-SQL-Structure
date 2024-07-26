SELECT 
	u.user_id as "ID",
	u.username as "Username",
	array_agg(fm.movie_id) as "Favorite movie IDs"
FROM "User" u
LEFT JOIN FavoriteMovies fm on fm.user_id = u.user_id
GROUP BY u.user_id, u.username;
