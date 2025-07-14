-- Netfilx_Analysis

select*
from netflix_titles;


-- Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix_titles
GROUP BY 1;

-- Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS Rank_
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank_ = 1;


-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix_titles
WHERE release_year = 2020;



-- Find the Top 5 Countries with the Most Content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix_titles
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- Identify the Longest Movie
SELECT *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- Find Content Added in the Last 5 Years
SELECT *
FROM netflix_titles
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM netflix_titles
WHERE FIND_IN_SET('Rajiv Chilaka', director) > 0;

-- List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix_titles
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
  
  -- Count the Number of Content Items in Each Genre
 WITH RECURSIVE numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 10  -- adjust 10 based on max number of genres
)
SELECT 
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre,
  COUNT(*) AS total_content
FROM 
  netflix_titles, numbers
WHERE 
  n <= LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', '')) + 1
GROUP BY genre
ORDER BY total_content DESC;

-- Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / 
        (SELECT COUNT(show_id) FROM netflix_titles WHERE country = 'India') * 100, 2
    ) AS avg_release
FROM netflix_titles
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- List All Movies that are Documentaries

SELECT * 
FROM netflix_titles
WHERE listed_in LIKE '%Documentaries';

-- Find All Content Without a Director
SELECT * 
FROM netflix_titles
WHERE director IS NULL;

-- Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
  
  -- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
  WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10  -- Increase 10 if you expect more actors per row
)
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n), ',', -1)) AS actor,
    COUNT(*) AS appearances
FROM 
    netflix_titles, numbers
WHERE 
    country = 'India'
    AND cast IS NOT NULL
    AND n <= LENGTH(cast) - LENGTH(REPLACE(cast, ',', '')) + 1
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category;

-- 