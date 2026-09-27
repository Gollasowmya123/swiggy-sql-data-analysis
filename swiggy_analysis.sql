SELECT VERSION();
CREATE DATABASE swiggy_db;
DESCRIBE swiggy;
SELECT DATABASE();
USE swiggy_db;
SELECT DATABASE();
SHOW TABLES;
DESCRIBE swiggy;
ALTER TABLE swiggy
MODIFY lic_no TEXT;
DESCRIBE swiggy;
SELECT COUNT(*) FROM swiggy;
SELECT * FROM swiggy LIMIT 10;
USE swiggy_db;

-- 1. Check total records in original table
SELECT COUNT(*) AS total_records
FROM swiggy;


-- 2. Check NULL values in important columns
SELECT
    SUM(CASE WHEN name IS NULL OR TRIM(name) = '' THEN 1 ELSE 0 END) AS null_names,
    SUM(CASE WHEN rating IS NULL OR TRIM(rating) = '' THEN 1 ELSE 0 END) AS null_ratings,
    SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) AS null_cities
FROM swiggy;


-- 3. Check restaurants with NEW or -- rating
SELECT
    id,
    name,
    city,
    rating
FROM swiggy
WHERE TRIM(rating) IN ('NEW', '--');


-- 4. Remove old cleaned table if it already exists
DROP TABLE IF EXISTS swiggy_cleaned;


-- 5. Create cleaned table
CREATE TABLE swiggy_cleaned AS
SELECT
    id,

    -- Clean restaurant name
    NULLIF(TRIM(name), '') AS name,

    -- Clean city
    NULLIF(TRIM(city), '') AS city,

    -- Convert valid ratings to numbers
    CASE
        WHEN TRIM(rating) REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(TRIM(rating) AS DECIMAL(3,1))
        ELSE NULL
    END AS rating,

    -- Keep rating_count for now
    NULLIF(TRIM(rating_count), '') AS rating_count,

    -- Clean cost
    NULLIF(TRIM(cost), '') AS cost,

    -- Clean cuisine
    NULLIF(TRIM(cuisine), '') AS cuisine,

    -- Keep license number as text
    CAST(lic_no AS CHAR) AS lic_no,

    -- Clean remaining columns
    NULLIF(TRIM(link), '') AS link,
    NULLIF(TRIM(address), '') AS address,
    NULLIF(TRIM(menu), '') AS menu

FROM swiggy;


-- 6. Check cleaned table record count
SELECT COUNT(*) AS cleaned_records
FROM swiggy_cleaned;


-- 7. View cleaned data
SELECT *
FROM swiggy_cleaned
LIMIT 10;


-- 8. Check NULL values after cleaning
SELECT
    SUM(name IS NULL) AS null_names,
    SUM(city IS NULL) AS null_cities,
    SUM(rating IS NULL) AS null_ratings,
    SUM(rating_count IS NULL) AS null_rating_count,
    SUM(cost IS NULL) AS null_cost,
    SUM(cuisine IS NULL) AS null_cuisine
FROM swiggy_cleaned;
USE swiggy_db;
DROP TABLE IF EXISTS swiggy_cleaned;

CREATE TABLE swiggy_cleaned AS
SELECT
    id,
    NULLIF(TRIM(name), '') AS name,
    NULLIF(TRIM(city), '') AS city,

    CASE
        WHEN TRIM(rating) REGEXP '^[0-9]+(\\.[0-9]+)?$'
        THEN CAST(TRIM(rating) AS DECIMAL(3,1))
        ELSE NULL
    END AS rating,

    NULLIF(TRIM(rating_count), '') AS rating_count,
    NULLIF(TRIM(cost), '') AS cost,
    NULLIF(TRIM(cuisine), '') AS cuisine,

    CAST(lic_no AS CHAR) AS lic_no,

    NULLIF(TRIM(link), '') AS link,
    NULLIF(TRIM(address), '') AS address,
    NULLIF(TRIM(menu), '') AS menu

FROM swiggy;
SELECT COUNT(*) AS cleaned_records
FROM swiggy_cleaned;
SELECT *
FROM swiggy_cleaned
LIMIT 10;
SELECT
    SUM(name IS NULL) AS missing_name,
    SUM(city IS NULL) AS missing_city,
    SUM(rating IS NULL) AS missing_rating,
    SUM(rating_count IS NULL) AS missing_rating_count,
    SUM(cost IS NULL) AS missing_cost,
    SUM(cuisine IS NULL) AS missing_cuisine
FROM swiggy_cleaned;
SELECT
    rating,
    COUNT(*) AS total
FROM swiggy_cleaned
GROUP BY rating
ORDER BY rating;
SELECT
    rating_count,
    COUNT(*) AS total
FROM swiggy_cleaned
GROUP BY rating_count
ORDER BY total DESC
LIMIT 20;
USE swiggy_db;

DROP TABLE IF EXISTS swiggy_final;

CREATE TABLE swiggy_final AS
SELECT
    id,
    name,
    city,
    rating,

    CASE
        WHEN rating_count = 'Too Few Ratings' THEN NULL
        WHEN rating_count LIKE '1K%' THEN 1000
        WHEN rating_count LIKE '500+%' THEN 500
        WHEN rating_count LIKE '100+%' THEN 100
        WHEN rating_count LIKE '50+%' THEN 50
        WHEN rating_count LIKE '20+%' THEN 20
        ELSE NULL
    END AS rating_count,

    cost,
    cuisine,
    lic_no,
    link,
    address,
    menu

FROM swiggy_cleaned;
SELECT
    rating_count,
    COUNT(*) AS total
FROM swiggy_final
GROUP BY rating_count
ORDER BY rating_count;
SELECT
    cost,
    COUNT(*) AS total
FROM swiggy_final
GROUP BY cost
ORDER BY total DESC
LIMIT 20;
USE swiggy_db;

DROP TABLE IF EXISTS swiggy_final_cleaned;

CREATE TABLE swiggy_final_cleaned AS
SELECT
    id,
    name,
    city,
    rating,
    rating_count,

    CASE
        WHEN cost REGEXP '[0-9]+'
        THEN CAST(REGEXP_SUBSTR(cost, '[0-9]+') AS UNSIGNED)
        ELSE NULL
    END AS cost,

    cuisine,
    lic_no,
    link,
    address,
    menu

FROM swiggy_final;
SELECT
    cost,
    COUNT(*) AS total
FROM swiggy_final_cleaned
GROUP BY cost
ORDER BY cost;
SELECT COUNT(*) AS total_records
FROM swiggy_final_cleaned;
SELECT COUNT(*) AS total_records
FROM swiggy_final_cleaned;
SELECT
    id,
    COUNT(*) AS duplicate_count
FROM swiggy_final_cleaned
GROUP BY id
HAVING COUNT(*) > 1;
SELECT
    SUM(name IS NULL) AS missing_name,
    SUM(city IS NULL) AS missing_city,
    SUM(rating IS NULL) AS missing_rating,
    SUM(rating_count IS NULL) AS missing_rating_count,
    SUM(cost IS NULL) AS missing_cost,
    SUM(cuisine IS NULL) AS missing_cuisine
FROM swiggy_final_cleaned;
SELECT
    MIN(rating) AS minimum_rating,
    MAX(rating) AS maximum_rating
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL;
SELECT
    MIN(cost) AS minimum_cost,
    MAX(cost) AS maximum_cost
FROM swiggy_final_cleaned
WHERE cost IS NOT NULL;
SELECT
    rating_count,
    COUNT(*) AS total
FROM swiggy_final_cleaned
GROUP BY rating_count
ORDER BY rating_count;
SELECT COUNT(*) AS invalid_ratings
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
  AND (rating < 0 OR rating > 5);
  SELECT COUNT(*) AS invalid_records
FROM swiggy_final_cleaned
WHERE TRIM(name) = ''
   OR TRIM(city) = '';
   SELECT *
FROM swiggy_final_cleaned
LIMIT 10;
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT id) AS unique_ids,
    SUM(rating IS NULL) AS missing_ratings,
    SUM(rating_count IS NULL) AS missing_rating_counts,
    SUM(cost IS NULL) AS missing_costs
FROM swiggy_final_cleaned;


USE swiggy_db;




 -- Q1: How many restaurants are listed per city?
SELECT
    city,
    COUNT(*) AS total_restaurants
FROM swiggy_final_cleaned
GROUP BY city
ORDER BY total_restaurants DESC
LIMIT 10;


-- Q2: What are the most popular cuisines across India?
SELECT
    cuisine,
    COUNT(*) AS total_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
GROUP BY cuisine
ORDER BY total_restaurants DESC
LIMIT 10;


-- Q3: Which restaurant names have the most branches?
SELECT
    name,
    COUNT(*) AS branches
FROM swiggy_final_cleaned
WHERE name IS NOT NULL
GROUP BY name
ORDER BY branches DESC
LIMIT 10;


-- Q4: Top 5 cities with highest average restaurant rating
SELECT
    city,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
GROUP BY city
HAVING COUNT(rating) > 50
ORDER BY avg_rating DESC
LIMIT 5;


-- Q5: What is the average cost for two across cities?
SELECT
    city,
    ROUND(AVG(cost), 0) AS avg_cost
FROM swiggy_final_cleaned
WHERE cost IS NOT NULL
GROUP BY city
ORDER BY avg_cost DESC
LIMIT 10;


-- Q6: Which cuisines have the highest average rating?
SELECT
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
  AND rating IS NOT NULL
GROUP BY cuisine
HAVING COUNT(rating) > 100
ORDER BY avg_rating DESC
LIMIT 10;


-- Q7: Restaurants with rating >= 4.5
-- and rating_count >= 1000
SELECT
    name,
    city,
    rating,
    rating_count,
    cost
FROM swiggy_final_cleaned
WHERE rating >= 4.5
  AND rating_count >= 1000
ORDER BY rating DESC, rating_count DESC
LIMIT 20;


-- Q8: City-level value indicator
-- Higher average rating + lower average cost
SELECT
    city,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(cost), 0) AS avg_cost,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
  AND cost IS NOT NULL
GROUP BY city
HAVING COUNT(rating) > 30
ORDER BY avg_rating DESC, avg_cost ASC
LIMIT 10;
SELECT DATABASE();
SELECT
    city,
    COUNT(*) AS total_restaurants
FROM swiggy_final_cleaned
GROUP BY city
ORDER BY total_restaurants DESC
LIMIT 10;


SELECT
    cuisine,
    COUNT(*) AS total_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
GROUP BY cuisine
ORDER BY total_restaurants DESC
LIMIT 10;
SELECT
    name,
    COUNT(*) AS branches
FROM swiggy_final_cleaned
WHERE name IS NOT NULL
GROUP BY name
ORDER BY branches DESC
LIMIT 10;
SELECT
    city,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
GROUP BY city
HAVING COUNT(rating) > 50
ORDER BY avg_rating DESC
LIMIT 5;
SELECT
    city,
    ROUND(AVG(cost), 0) AS avg_cost
FROM swiggy_final_cleaned
WHERE cost IS NOT NULL
GROUP BY city
ORDER BY avg_cost DESC
LIMIT 10;
SELECT
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
  AND rating IS NOT NULL
GROUP BY cuisine
HAVING COUNT(rating) > 100
ORDER BY avg_rating DESC
LIMIT 10;
SELECT
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
  AND rating IS NOT NULL
GROUP BY cuisine
HAVING COUNT(rating) > 100
ORDER BY avg_rating DESC
LIMIT 10;
SELECT
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
  AND rating IS NOT NULL
GROUP BY cuisine
ORDER BY avg_rating DESC
LIMIT 10;
SELECT
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
  AND rating IS NOT NULL
GROUP BY cuisine
HAVING COUNT(rating) >= 10
ORDER BY avg_rating DESC
LIMIT 10;
SELECT
    name,
    city,
    rating,
    rating_count,
    cost
FROM swiggy_final_cleaned
WHERE rating >= 4.5
  AND rating_count >= 1000
ORDER BY rating DESC, rating_count DESC
LIMIT 20;
SELECT
    name,
    city,
    rating,
    rating_count,
    cost
FROM swiggy_final_cleaned
WHERE rating >= 4.5
ORDER BY rating DESC
LIMIT 20;
SELECT
    name,
    city,
    rating,
    rating_count,
    cost
FROM swiggy_final_cleaned
WHERE rating >= 4.5
  AND rating_count >= 100
ORDER BY rating DESC, rating_count DESC
LIMIT 20;
SELECT
    city,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(cost), 0) AS avg_cost,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
  AND cost IS NOT NULL
GROUP BY city
HAVING COUNT(rating) > 30
ORDER BY avg_rating DESC, avg_cost ASC
LIMIT 10;
SELECT
    name,
    city,
    cost,
    rating,
    rating_count
FROM swiggy_final_cleaned
WHERE cost IS NOT NULL
ORDER BY cost DESC
LIMIT 20;
SELECT
    name,
    city,
    rating,
    rating_count,
    cost
FROM swiggy_final_cleaned
WHERE rating >= 4.0
  AND rating_count >= 100
  AND cost IS NOT NULL
ORDER BY cost ASC, rating DESC
LIMIT 20;
SELECT
    cuisine,
    ROUND(AVG(cost), 0) AS avg_cost,
    COUNT(*) AS restaurant_count
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
  AND cost IS NOT NULL
GROUP BY cuisine
ORDER BY avg_cost DESC
LIMIT 10;
SELECT
    name,
    city,
    rating,
    rating_count,
    cost,
    ROUND(rating * rating_count, 0) AS combined_score
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
  AND rating_count IS NOT NULL
  AND rating_count >= 100
ORDER BY combined_score DESC
LIMIT 20;
SELECT city, COUNT(*) AS total_restaurants
FROM swiggy_final_cleaned
GROUP BY city
ORDER BY total_restaurants DESC
LIMIT 1;
SELECT cuisine, COUNT(*) AS total_restaurants
FROM swiggy_final_cleaned
WHERE cuisine IS NOT NULL
GROUP BY cuisine
ORDER BY total_restaurants DESC
LIMIT 1;
SELECT name, COUNT(*) AS branches
FROM swiggy_final_cleaned
WHERE name IS NOT NULL
GROUP BY name
ORDER BY branches DESC
LIMIT 1;
SELECT
    city,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(rating) AS rated_restaurants
FROM swiggy_final_cleaned
WHERE rating IS NOT NULL
GROUP BY city
HAVING COUNT(rating) > 50
ORDER BY avg_rating DESC
LIMIT 1;
SELECT
    city,
    ROUND(AVG(cost), 0) AS avg_cost
FROM swiggy_final_cleaned
WHERE cost IS NOT NULL
GROUP BY city
ORDER BY avg_cost DESC
LIMIT 1;
SELECT
    city,
    ROUND(AVG(cost), 0) AS avg_cost
FROM swiggy_final_cleaned
WHERE cost IS NOT NULL
GROUP BY city
ORDER BY avg_cost ASC
LIMIT 1;
