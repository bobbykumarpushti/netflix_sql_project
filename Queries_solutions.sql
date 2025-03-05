-- NETFLIX PROJECT
CREATE DATABASE netflix;
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(210),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(150),
descriptions VARCHAR(250)
); 

SELECT * FROM netflix;


SELECT COUNT(*) AS total_content
FROM netflix;


SELECT DISTINCT(type) 
FROM netflix;


-- 15 BUSINESS PROBLEMS 

-- 1. COUNT THE NUMBER OF MOVIES VS TV SHOWS
SELECT 
	type, 
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;


-- 2.FIND THE MOST COMMNON RATING FOR MOVIES AND TV SHOWS
SELECT 
	type,
	rating
FROM
(
	SELECT 
		type,
		rating, 
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
) AS t1
	WHERE ranking=1;


-- 3. LIST ALL MOVIES RALEASED IN A SPECIFIC YEAR(E.G., 2020)
SELECT * 
	FROM netflix
	WHERE type='Movie'
	AND
	release_year=2020;


-- 4. FIND THE TOP 5 COUNTRIES WITH THE MOST CONTENT ON NETFLIX
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--5. IDENTIFY THE LONGEST MOVIE
SELECT *
FROM netflix 
WHERE 
	type='Movie'
	AND 
	duration=(SELECT 
				MAX(duration)
			  FROM netflix);


-- 6. FIND CONTENT ADDED IN THE LAST 5 YEARS
SELECT 
	*
FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY')>=(SELECT  CURRENT_DATE - INTERVAL '5 years');



-- 7. FIND ALL THE MOVIES/TV SHOWS BY DIRECTOR "RAJIV CHILAKA"	
SELECT 
	*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. LIST ALL TV SHOWS WITH MORE THAN 5 SEASONS
SELECT
	*
FROM netflix 
WHERE type='TV Show'
	  AND
	  SPLIT_PART(duration,' ',1)::NUMERIC>5;


-- 9. COUNT THE NUMBER OF CONTENT ITEMS IN EACH GENRE	  
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
	COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;


-- 10. FIND EACH YEAR AND THE AVERAGE NUMBERS OF CONTENT RELEASE BY INDIA ON NETFLIX
--     RETURN TOP 5 YEAR WITH HIGHEST AVG CONTENT RELEASE
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country='India')::NUMERIC*100,2) AS avg
FROM netflix
WHERE 
	country='India'
GROUP BY 1	
ORDER BY 1 DESC;


-- 11, LIST ALL MOVIES THAT ARE DOCUMENTARIES
SELECT 
	*
FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%';


-- 12. FIND ALL CONTENT WOTHOUT A DIRECTOR
SELECT 
	*
FROM netflix
WHERE director IS NULL;


-- 13. FIND HOW MANY MOVIES ACTOR "SALMAN KHAN " APPEARED IN LAST 10 YEAR
SELECT 
	*
FROM netflix
WHERE casts ILIKE'%SALMAN KHAN%'
	AND 
		release_year> EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14, FIND THE TOP 10 ACTORS WHO HAVE APPEARED IN THE HIGHESTNUMBER OF MOVIES PRODUCED IN INDIA
SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) AS actors,
COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10;


-- 15. CATEGORIZE THE CONTENT BASED ON THE PRESENCE OF THE KEYWORDS 'KILL' AND 'VIOLENCE' IN 
-- 		THE DESCRIPTION FIELD. LABEL CONTENT CONTAINING THESE KEYWORDS AS 'BAD' AND ALL OTHER
-- 		CONTENT AS 'GOOD'. COUNT HOW MANY ITEMS FALL INTO EACH CATEGORY
WITH new_table
AS 
(
SELECT
*,
CASE 
	WHEN
		descriptions ILIKE '%KILL%'
		OR
		descriptionS ILIKE '%VIOLENCE%'
	THEN 'Bad_Content'
ELSE 'Good_Content'
END category
FROM netflix
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;
 