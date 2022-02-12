-- You will build a query that identifies a match's winner, identifies the identity of the opponent,
-- and finally filters for Barcelona as the home team. Completing a query in this order will allow
-- you to watch your results take shape with each new piece of information.
SELECT
	m.date,
	t.team_long_name AS opponent
	CASE WHEN m.home_goal > m.away_goal THEN 'Barcelona win!'
        WHEN m.home_goal < m.away_goal THEN 'Barcelona loss :('
        ELSE 'Tie' END AS outcome
FROM matches_spain AS m
LEFT JOIN teams_spain AS t
ON m.awayteam_id = t.team_api_id
-- Filter for Barcelona as the home team
WHERE m.hometeam_id = '8634';


-- Select matches where Barcelona was the away team
SELECT
	m.date,
	t.team_long_name AS opponent,
	case when m.home_goal < m.away_goal then 'Barcelona win!'
        WHEN m.home_goal > m.away_goal then 'Barcelona loss :('
        else 'Tie' end AS outcome
FROM matches_spain AS m
-- Join teams_spain to matches_spain
LEFT JOIN teams_spain AS t
ON m.hometeam_id = t.team_api_id
WHERE m.awayteam_id = 8634;


-- In CASE of rivalry
-- Barcelona and Real Madrid have been rival teams for more than 80 years. Matches between these two
-- teams are given the name El Clásico (The Classic). In this exercise, you will query a list of matches played
-- between these two rivals.
--
-- You will notice in Step 2 that when you have multiple logical conditions in a CASE statement, you may quickly end up
-- with a large number of WHEN clauses to logically test every outcome you are interested in. It's important to make sure you don't accidentally exclude key information in your ELSE clause.
--
-- In this exercise, you will retrieve information about matches played between Barcelona (id = 8634) and Real Madrid
-- (id = 8633). Note that the query you are provided with already identifies the Clásico matches using a filter in the
-- WHERE clause.

SELECT
	date,
	-- Identify the home team as Barcelona or Real Madrid
	CASE WHEN  hometeam_id = 8634 THEN 'FC Barcelona'
        ELSE 'Real Madrid CF' END AS home,
    -- Identify the away team as Barcelona or Real Madrid
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona'
        ELSE 'Real Madrid CF' END AS away
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);

-- Construct the final CASE statement identifying who won each match. Note there are 3 possible outcomes,
-- but 5 conditions that you need to identify.
-- Fill in the logical operators to identify Barcelona or Real Madrid as the winner.
SELECT
	date,
	CASE WHEN hometeam_id = 8634 THEN 'FC Barcelona'
         ELSE 'Real Madrid CF' END as home,
	CASE WHEN awayteam_id = 8634 THEN 'FC Barcelona'
         ELSE 'Real Madrid CF' END as away,
	-- Identify all possible match outcomes
	CASE WHEN home_goal > away_goal AND hometeam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal > away_goal AND hometeam_id = 8633 THEN 'Real Madrid win!'
        WHEN home_goal < away_goal AND awayteam_id = 8634 THEN 'Barcelona win!'
        WHEN home_goal < away_goal AND awayteam_id = 8633 THEN 'Real Madrid win!'
        ELSE 'Tie!' END AS outcome
FROM matches_spain
WHERE (awayteam_id = 8634 OR hometeam_id = 8634)
      AND (awayteam_id = 8633 OR hometeam_id = 8633);


-- Filtering your CASE statement
-- Let's generate a list of matches won by Italy's Bologna team! There are quite a few additional teams in the two tables,
-- so a key part of generating a usable query will be using your CASE statement as a filter in the WHERE clause.
--
-- CASE statements allow you to categorize data that you're interested in -- and exclude data you're not interested in.
-- In order to do this, you can use a CASE statement as a filter in the WHERE statement to remove output you don't want to see.
--
-- Here is how you might set that up:
--
-- SELECT *
-- FROM table
-- WHERE
--     CASE WHEN a > 5 THEN 'Keep'
--          WHEN a <= 5 THEN 'Exclude' END = 'Keep';

-- In essence, you can use the CASE statement as a filtering column like any other column in your database. The only
-- difference is that you don't alias the statement in WHERE.
-- Select the season and date columns
SELECT
	season,
	date,
    -- Identify when Bologna won a match
	CASE WHEN hometeam_id = 9857
        AND home_goal > away_goal
        THEN 'Bologna Win'
		WHEN awayteam_id = 9857
        AND away_goal > home_goal
        THEN 'Bologna Win'
		END AS outcome
FROM matches_italy;

-- Select the season, date, home_goal, and away_goal columns
SELECT
	season,
    date,
	home_goal,
	away_goal
FROM matches_italy
WHERE
-- Exclude games not won by Bologna
	CASE WHEN  hometeam_id = 9857 AND home_goal > away_goal THEN 'Bologna Win'
		WHEN awayteam_id = 9857 AND away_goal > home_goal THEN 'Bologna Win'
		END IS NOT NULL;


-- Examine the number of matches played in 3 seasons within each country listed in the database.
-- Using the country and unfiltered match
-- table, you will count the number of matches played in each country during the 2012/2013, 2013/2014, and 2014/2015
-- match seasons.
SELECT
	c.name AS country,
    -- Count matches in each of the 3 seasons
	COUNT(CASE WHEN m.season = '2012/2013' THEN m.id END) AS matches_2012_2013,
	COUNT(CASE WHEN m.season = '2013/2014' THEN m.id END) AS matches_2013_2014,
	COUNT(CASE WHEN m.season = '2014/2015' THEN m.id END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
Group BY country;

-- Your goal here is to use the country and match table to determine the total number
-- of matches won by the home team in each country during the 2012/2013, 2013/2014, and 2014/2015 seasons.
SELECT
	c.name AS country,
    -- Sum the total records in each season where the home team won
	SUM(CASE WHEN  m.season = '2012/2013' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2012_2013,
 	SUM(CASE WHEN m.season = '2013/2014' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2013_2014,
	SUM(CASE WHEN m.season = '2014/2015' AND m.home_goal > m.away_goal
        THEN 1 ELSE 0 END) AS matches_2014_2015
FROM country AS c
LEFT JOIN match AS m
ON c.id = m.country_id
-- Group by country name alias
GROUP BY country;


-- Calculating percent with CASE and AVG
-- examine the number of wins, losses, and ties in each country. The matches table is filtered to include all
-- matches from the 2013/2014 and 2014/2015 seasons.
SELECT
	c.name AS country,
    -- Round the percentage of tied games to 2 decimal points
	ROUND(AVG(CASE WHEN m.season='2013/2014' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2013/2014' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2013_2014,
	ROUND(AVG(CASE WHEN m.season='2014/2015' AND m.home_goal = m.away_goal THEN 1
			 WHEN m.season='2014/2015' AND m.home_goal != m.away_goal THEN 0
			 END),2) AS pct_ties_2014_2015
FROM country AS c
LEFT JOIN matches AS m
ON c.id = m.country_id
GROUP BY country;

-- generate a subquery using the match table, and then join that subquery to the country table to calculate
-- information about matches with 10 or more goals in total!
SELECT
	-- Select country name and the count match IDs
    name AS country_name,
    COUNT(sub) AS matches
FROM country AS c
-- Inner join the subquery onto country
INNER JOIN (SELECT country_id, id
           FROM match
           -- Filter the subquery by matches with 10+ goals
           WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name;



-- In the previous exercise, you found that England, Netherlands, Germany and Spain were the only countries that
-- had matches in the database where 10 or more goals were scored overall. Let's find out some more details about
-- those matches -- when they were played, during which seasons, and how many of the goals were home versus away goals.
SELECT
	-- Select country, date, home, and away goals from the subquery
    country,
    date,
    home_goal,
    away_goal
FROM
	-- Select country name, date, home_goal, away_goal, and total goals in the subquery
	(SELECT name AS country,
     	    m.date,
     		m.home_goal,
     		m.away_goal,
           (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
-- Filter by total goals scored in the main query
WHERE total_goals >= 10;


-- Add a subquery to the SELECT clause
-- Subqueries in SELECT statements generate a single value that allow you to pass
-- an aggregate value down a data frame. This is useful for performing calculations on data within your database.
--
-- In the following exercise, you will construct a query that calculates the average number of goals per match in
-- each country's league.
SELECT
	l.name AS league,
    -- Select and round the league's total goals
    ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
    -- Select & round the average total goals for the season
    (SELECT ROUND(AVG(home_goal + away_goal), 2)
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Filter for the 2013/2014 season
WHERE season = '2013/2014'
GROUP BY league;


-- In the previous exercise, you created a column to compare each league's average total goals to
-- the overall average goals in the 2013/2014 season. In this exercise,
-- you will add a column that directly compares these values by subtracting the overall average from the subquery.
SELECT
	-- Select the league name and average goals scored
	name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    -- Subtract the overall average from the league average
	ROUND(AVG(m.home_goal + m.away_goal) -
		(SELECT AVG(home_goal + away_goal)
		 FROM match
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
-- Only include 2013/2014 results
WHERE season = '2013/2014'
GROUP BY l.name;


-- ALL the subqueries EVERYWHERE
-- In soccer leagues, games are played at different stages. Winning teams progress from one stage to the next, until they reach the final stage. In each stage, the stakes become higher than the previous one. The match
-- table includes data about the different stages that each match took place in.
--
-- In this lesson, you will build a final query across 3 exercises that will contain three subqueries
-- one in the SELECT clause, one in the FROM clause, and one in the WHERE clause. In the final exercise,
-- your query will extract data examining the average goals scored in each stage of a match. Does the average
-- number of goals scored change as the stakes get higher from one stage to the next?

SELECT
	-- Select the stage and average goals for each stage
	m.stage,
    ROUND(AVG(m.home_goal	 + m.away_goal),2) AS avg_goals,
    -- Select the average overall goals for the 2012/2013 season
    ROUND((SELECT AVG(home_goal + away_goal)
           FROM match
           WHERE season = '2012/2013'),2) AS overall
FROM match AS m
-- Filter for the 2012/2013 season
WHERE season = '2012/2013'
-- Group by stage
GROUP BY m.stage;


-- In the previous exercise, you created a data set listing the average home and away goals in each match stage of the
-- 2012/2013 match season.
-- In this next step, you will turn the main query into a subquery to extract a list of stages where the average home goals
-- in a stage is higher than the overall average for home goals in a match.

SELECT
	-- Select the stage and average goals from the subquery
	stage,
	ROUND(s.avg_goals,2) AS avg_goals
FROM
	-- Select the stage and average goals in 2012/2013
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE
	-- Filter the main query using the subquery
	s.avg_goals > (SELECT AVG(home_goal + away_goal)
                    FROM match WHERE season = '2012/2013');


-- In the previous exercise, you added a subquery to the FROM statement and selected the stages where the number
-- of average goals in a stage exceeded the overall average number of goals in the 2012/2013 match season. In this final step,
-- you will add a subquery in SELECT to compare the average number of goals scored in each stage to the total.
SELECT
	-- Select the stage and average goals from s
	stage,
    ROUND(s.avg_goals,2) AS avg_goal,
    -- Select the overall average for 2012/2013
    (SELECT avg(home_goal + away_goal) FROM match WHERE season = '2012/2013') AS overall_avg
FROM
	-- Select the stage and average goals in 2012/2013 from match
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE
	-- Filter the main query using the subquery
	s.avg_goals > (SELECT AVG(home_goal + away_goal)
                    FROM match WHERE season = '2012/2013');


-- Basic Correlated Subqueries
-- Correlated subqueries are subqueries that reference one or more columns in the main query. Correlated subqueries
-- depend on information in the main query to run, and thus, cannot be executed on their own.
-- Correlated subqueries are evaluated in SQL once per row of data retrieved a process that takes a lot
-- more computing power and time than a simple subquery.
-- In this exercise, you will practice using correlated subqueries to examine matches
-- with scores that are extreme outliers for each country above 3 times the average score!
SELECT
	-- Select country ID, date, home, and away goals from match
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE
	-- Filter the main query by the subquery
	(home_goal + away_goal) >
        (SELECT AVG((sub.home_goal + sub.away_goal) * 3)
         FROM match AS sub
         -- Join the main query to the subquery in WHERE
         WHERE main.country_id = sub.country_id);

-- what was the highest scoring match for each country, in each season?
SELECT
	-- Select country ID, date, home, and away goals from match
	main.country_id,
    main.date,
    main.home_goal,
    main.away_goal
FROM match AS main
WHERE
	-- Filter for matches with the highest number of goals scored
	(home_goal + away_goal) =
        (SELECT MAX(sub.home_goal + sub.away_goal)
         FROM match AS sub
         WHERE main.country_id = sub.country_id
               AND main.season = sub.season);


-- In this exercise, you will practice creating a nested subquery to examine the highest total number of goals
-- in each season, overall, and during July across all seasons.
SELECT
	-- Select the season and max goals scored in a match
	season,
    MAX(home_goal + away_goal) AS max_goals,
    -- Select the overall max goals scored in a match
   (SELECT MAX(home_goal + away_goal) FROM match) AS overall_max_goals,
   -- Select the max number of goals scored in any match in July
   (SELECT MAX(home_goal + away_goal)
    FROM match
    WHERE id IN (
          SELECT id FROM match WHERE EXTRACT(MONTH FROM date) = 07)) AS july_max_goals
FROM match
GROUP BY season;


-- generate a list of countries and the number of matches in each country with more than 10 total goals
-- Set up your CTE
WITH match_list AS (
    SELECT
  		country_id,
  		id
    FROM match
    WHERE (home_goal + away_goal) >= 10)
-- Select league and count of matches from the CTE
SELECT
    l.name AS league,
    COUNT(match_list.id) AS matches
FROM league AS l
-- Join the CTE to the league table
LEFT JOIN match_list ON l.id = match_list.country_id
GROUP BY l.name;

-- Set up your CTE
WITH match_list AS (
  -- Select the league, date, home, and away goals
    SELECT
  		l.name AS league,
     	m.date,
  		m.home_goal,
  		m.away_goal,
       (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN league as l ON m.country_id = l.id)
-- Select the league, date, home, and away goals from the CTE
SELECT league, date, home_goal, away_goal
FROM match_list
-- Filter by total goals
WHERE total_goals >= 10;


-- Get team names with a subquery
-- Let's solve a problem we've encountered a few times in this course so far
-- How do you get both the home and away team names into one final query result?
SELECT
	m.date,
    -- Get the home and away team names
    home.hometeam,
    away.awayteam,
    m.home_goal,
    m.away_goal
FROM match AS m

-- Join the home subquery to the match table
left join (
  SELECT match.id, team.team_long_name AS hometeam
  FROM match
  LEFT JOIN team
  ON match.hometeam_id = team.team_api_id) AS home
ON home.id = m.id

-- Join the away subquery to the match table
LEFT JOIN (
  SELECT match.id, team.team_long_name AS awayteam
  FROM match
  LEFT JOIN team
  -- Get the away team ID in the subquery
  ON match.awayteam_id = team.team_api_id) AS away
ON away.id = m.id;



-- How do you get both the home and away team names into one final query result?
WITH home AS (
  SELECT m.id, m.date,
  		 t.team_long_name AS hometeam, m.home_goal
  FROM match AS m
  LEFT JOIN team AS t
  ON m.hometeam_id = t.team_api_id),
-- Declare and set up the away CTE
away AS (
  SELECT m.id, m.date,
  		 t.team_long_name AS awayteam, m.away_goal
  FROM match AS m
  LEFT JOIN team AS t
  ON m.awayteam_id = t.team_api_id)
-- Select date, home_goal, and away_goal
SELECT
	home.date,
    home.hometeam,
    away.awayteam,
    home.home_goal,
    away.away_goal
-- Join away and home on the id column
FROM home
INNER JOIN away
ON away.id = home.id;


-- Window Functions
-- Select the match ID, country name, season, home, and away goals from the match and country tables.
-- Complete the query that calculates the average number of goals scored overall and then includes the
-- aggregate value in each row using a window function.
SELECT
	-- Select the id, country name, season, home, and away goals
	m.id,
    c.name AS country,
    m.season,
	m.home_goal,
	m.away_goal,
    -- Use a window to include the aggregate average in each row
	AVG(m.home_goal + m.away_goal) OVER() AS overall_avg
FROM match AS m
LEFT JOIN country AS c ON m.country_id = c.id;


-- Window functions allow you to create a RANK of information according to any variable you want to use to sort your data.
-- Create a data set of ranked matches according to which leagues, on average, score the most goals in a match.
SELECT
	-- Select the league name and average goals scored
	l.name AS league,
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    -- Rank each league according to the average goals
    RANK() OVER(ORDER BY AVG(m.home_goal + m.away_goal)) AS league_rank
FROM league AS l
LEFT JOIN match AS m
ON l.id = m.country_id
WHERE m.season = '2011/2012'
GROUP BY l.name
ORDER BY league_rank;


-- PARTITION BY a column
-- The PARTITION BY clause allows you to calculate separate "windows" based on columns you want to divide your results.
-- For example, you can create a single column that calculates an overall average of goals scored for each season.
--
-- In this exercise, you will be creating a data set of games played by Legia Warszawa (Warsaw League), the top ranked team
--     in Poland, and comparing their individual game performance to the overall average for that season.
SELECT
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home'
		 ELSE 'away' END AS warsaw_location,
    -- Calculate the average goals scored partitioned by season
    AVG(home_goal) OVER(PARTITION By season) AS season_homeavg,
    AVG(away_goal) OVER(PARTITION By season) AS season_awayavg
FROM match
-- Filter the data set for Legia Warszawa matches only
WHERE
	hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;


-- In this exercise, you will calculate the average number home and away goals scored Legia Warszawa, and their
-- opponents, partitioned by the month in each season.
SELECT
	date,
	season,
	home_goal,
	away_goal,
	CASE WHEN hometeam_id = 8673 THEN 'home'
         ELSE 'away' END AS warsaw_location,
	-- Calculate average goals partitioned by season and month
    AVG(home_goal) OVER(PARTITION BY season,
         	EXTRACT(MONTH FROM date)) AS season_mo_home,
    AVG(away_goal) OVER(PARTITION BY season,
            EXTRACT(MONTH FROM date)) AS season_mo_away
FROM match
WHERE
	hometeam_id = 8673
    OR awayteam_id = 8673
ORDER BY (home_goal + away_goal) DESC;



-- In this exercise, you will expand on the examples discussed in the video, calculating the running total of
-- goals scored by the FC Utrecht when they were the home team during the 2011/2012 season. Do they score more goals at
-- the end of the season as the home or away team?
SELECT
	date,
	home_goal,
	away_goal,
    -- Create a running total and running average of home goals
    SUM(home_goal) OVER(ORDER BY date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_goal) OVER(ORDER BY date
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE
	hometeam_id = 9908
	AND season = '2011/2012';


-- In this exercise, you will slightly modify the query from the previous exercise by sorting the data set in reverse order
--     and calculating a backward running total from the CURRENT ROW to the end of the data set (earliest record).
SELECT
	-- Select the date, home goal, and away goals
	date,
    home_goal,
    away_goal,
    -- Create a running total and running average of home goals
    SUM(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING ) AS running_total,
    AVG(home_goal) OVER(ORDER BY date DESC
         ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS running_avg
FROM match
WHERE
	awayteam_id = 9908
    AND season = '2011/2012';


-- Continue building the query to extract all matches played by Manchester United in the 2014/2015 season.
-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss'
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss'
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select team names, the date and goals
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal,
    m.away_goal
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND (home.team_long_name = 'Manchester United'
           OR away.team_long_name = 'Manchester United');





-- How badly did Manchester United lose in each match?
-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		   WHEN m.home_goal < m.away_goal THEN 'MU Loss'
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
	  CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
		   WHEN m.home_goal < m.away_goal THEN 'MU Win'
  		   ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select columns and and rank the matches by date
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, m.away_goal,
    RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) as match_rank
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));


