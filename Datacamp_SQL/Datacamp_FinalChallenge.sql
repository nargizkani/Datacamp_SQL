-- In this exercise, you'll need to get the country names and other 2015
-- data in the economies table and the countries table for Central American
-- countries with an official language.
-- Select fields
SELECT DISTINCT name, total_investment, imports
  -- From table (with alias)
  FROM countries AS c
    -- Join with table (with alias)
    LEFT JOIN economies AS e
      -- Match on code
      ON (c.code = e.code
      -- and code in Subquery
        AND c.code IN (
          SELECT l.code
          FROM languages AS l
          WHERE official = 'true'
        ) )
  -- Where region and year are correct
  WHERE year = 2015 AND region = 'Central America'
-- Order by field
ORDER BY name;

-- Final challenge (2)
-- Let's ease up a bit and calculate the average fertility rate for each
-- region in 2015.
-- Select fields
SELECT region, continent, AVG(fertility_rate) AS avg_fert_rate
  -- From left table
  FROM countries AS c
  INNER JOIN populations AS p
  ON c.code = p.country_code
  WHERE year = 2015
  GROUP BY region, continent
-- Order appropriately
  ORDER BY avg_fert_rate;

-- Final challenge (3)


-- You are now tasked with determining the top 10 capital
-- cities in Europe and the Americas in terms of a calculated percentage
-- using city_proper_pop and metroarea_pop in cities.
--
-- Do not use table aliasing in this exercise.

-- INSTRUCTIONS:
-- Select the city name, country code, city proper population, and metro area population.
-- Calculate the percentage of metro area population composed of city proper population for each city in cities, aliased as city_perc.
-- Focus only on capital cities in Europe and the Americas in a subquery.
-- Make sure to exclude records with missing data on metro area population.
-- Order the result by city_perc descending.
-- Then determine the top 10 capital cities in Europe and the Americas in terms of this city_perc percentage.

SELECT name, country_code, city_proper_pop, metroarea_pop,
      city_proper_pop  / metroarea_pop  * 100 AS city_perc
  FROM cities
  WHERE name IN
    -- Subquery
    (SELECT capital
     FROM countries
     WHERE (continent = 'Europe'
        OR continent LIKE '%America'))
       AND metroarea_pop IS NOT NULL
ORDER BY city_perc DESC
LIMIT 10;