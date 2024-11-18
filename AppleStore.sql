CREATE TABLE applestore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

-- check the number of unique apps in both tablesAppleStoreAppleStore

select count(DISTINCT id) as UniqueAppIDs
from AppleStore

select count(DISTINCT id) as UniqueAppIDs
from applestore_description_combined
--Result: No missing data between 2 tables

-- Check for any missing values in key fields

SELECT COUNT(*) as MissingValues
FROM AppleStore
where track_name is null or user_rating is null or prime_genre is NULL

SELECT COUNT(*) as MissingValues
From applestore_description_combined
WHERE app_desc IS null
-- Result: No missing values

-- Find out the number of apps per genreAppleStore

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC
--Result: Games and Entertainment are leading numbers

-- Get an overview of the apps' ratingsAppleStore

Select min(user_rating) AS MinRating,
	   max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore
-- Result: Min rating = 0; Max rating = 5; Avg rating = 3.53
**DATA ANALYSIS**

-- Determine whether paid apps have higher ratings than free appsAppleStore

select CASE
			when price > 0 then 'Paid'
            else 'Free'
       end as App_Type,
       avg(user_rating) As Avg_Rating
From AppleStore
GROUP By App_Type
-- Result: Rating of paid apps higher than free apps


--Check if apps with more supported languages have higher ratings

SELECT CASE
			WHEN lang_num < 10 THEN '<10 laguages'
            when lang_num Between 10 and 30 then '10-30 languages'
            else '>30 languages'
       End AS language_bucket,
       avg(user_rating) AS Avg_Rating
from AppleStore
GROUP by language_bucket
order by Avg_Rating DESC
-- Result: Apps with more supported languages have higher ratings


-- Check genres with low ratings

SELECT prime_genre,
	   avg(user_rating) As Avg_Rating
From AppleStore
GROUP BY prime_genre
Order BY Avg_Rating ASC
Limit 10
-- Result: Catalogs, Finance, and Book genres users gave poor ratings


--Check if there is a correlation between the length of the app description and the user rating

SELECT CASE
			WHEN length(b.app_desc) <500 THEN 'Short'
            when length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
            else 'Long'
       end as description_length_bucket,
       avg(a.user_rating) As average_rating

FROM
	AppleStore as A
JOIN
	applestore_description_combined as b 
ON
	a.id = b.id

GROUP by description_length_bucket
ORDER by average_rating DESC
-- Result: Longer the description the better the rating - Long: 3.85; Medium: 3.23; Short: 2.53


-- Check the top rated apps for each genre (Using Window Function - Assigns a rank to each row winthin a window of rows

SELECT
	prime_genre,
    track_name,
    user_rating
from (
  		SELECT
  		prime_genre,
  		track_name,
  		user_rating,
  		RANK() OVER(PARTITION BY prime_genre ORDER by user_rating DESC, rating_count_tot DESC) as rank
        FROM
        applestore 
     )  AS a 
WHERE
a.rank = 1
-- Result: TurboScan (Business); CPlus for Craiglist (Catalog); Elevate (Education) are among the top rated apps for their genre
