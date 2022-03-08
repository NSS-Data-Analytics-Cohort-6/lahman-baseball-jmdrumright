-- Q1: What range of years for baseball games played does the provided database cover?

SELECT
	MIN(yearid),
	MAX(yearid)
FROM batting;
-- 1871 to 2016, use MAX

SELECT
	MIN(yearid),
	MAX(yearid)
FROM collegeplaying;
-- 1864 to 2014, use MIN

SELECT
	MIN(c.yearid),
	MAX(b.yearid)
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid
JOIN collegeplaying AS c
ON p.playerid = c.playerid;
-- A1: 1864 to 2016

-- Q2: Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT
	MIN(height) AS shortest_height,
	namefirst,
	namegiven,
	namelast,
	playerid
FROM (SELECT playerid,
	  namefirst,
	  namegiven,
	  namelast,
	  height
	FROM people) AS subquery
GROUP BY namefirst, namegiven, namelast, playerid
ORDER BY shortest_height
LIMIT 1;
-- A2 by Jasmine: Eddie Edward Carl Gaedel.

SELECT
	DISTINCT p.playerid,
	p.height,
	p.namefirst,
	p.namelast,
	a.g_all
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
ORDER BY p.height
LIMIT 1;
-- A2 by Rob and Tim: Eddie Edward Carl Gaedel.

SELECT
	a.g_all,
	p.namefirst,
	p.namegiven,
	p.namelast,
	p.playerid
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
WHERE p.playerid = 'gaedeed01';
-- A2: Eddie Edward Carl Gaedel played in 1 game.

SELECT a.g_all,
	t.name,
	p.namegiven,
	p.playerid
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
JOIN teams AS t
ON a.teamid = t.teamid
ORDER BY p.height;
-- A2: Eddie Edward Carl Gaedel played for St. Louis Browns

-- Q3: Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT
	CONCAT(CAST(p.namefirst AS text), ' ', CAST(p.namelast AS text)) AS full_name,
	s.schoolname,
	SUM(sa.salary) AS total_salary_earned
FROM people AS p
JOIN collegeplaying AS c
ON p.playerid = c.playerid
JOIN schools AS s
ON c.schoolid = s.schoolid
JOIN salaries AS sa
ON p.playerid = sa.playerid
WHERE s.schoolname = 'Vanderbilt University'
GROUP BY full_name,
	s.schoolname
ORDER BY total_salary_earned DESC;
-- A3: David David Taylor Price at $245,553,888.

-- Q4: Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT
	DISTINCT playerid,
	yearid,
	pos,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS'
			OR pos = '1B'
			OR pos = '2B'
			OR pos = '3B' THEN 'Infield'
		ELSE 'Battery' END AS position
FROM fielding;

SELECT
	SUM(po) AS total_putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS'
			OR pos = '1B'
			OR pos = '2B'
			OR pos = '3B' THEN 'Infield'
		ELSE 'Battery' END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position;
-- A4: Outfield = 29,650 putouts, Infield = 58,934 putouts, Battery = 41,424 putouts

-- Q5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? USE THE TEAMS TABLE

-- Average number of strikeouts per game by decade since 1920:
SELECT
	(AVG(so) + AVG(soa)) / 2 AS avg_so,
	SUM(g) AS sumgame,
	ROUND(((AVG(so) + AVG(soa)) / 2) / (SUM(g)), 2) AS avg_so_pg_bd,
	CASE WHEN yearid >= '1920' AND yearid <= '1929' THEN '1920s'
		WHEN yearid >= '1930' AND yearid <= '1939' THEN '1930s'
		WHEN yearid >= '1940' AND yearid <= '1949' THEN '1940s'
		WHEN yearid >= '1950' AND yearid <= '1959' THEN '1950s'
		WHEN yearid >= '1960' AND yearid <= '1969' THEN '1960s'
		WHEN yearid >= '1970' AND yearid <= '1979' THEN '1970s'
		WHEN yearid >= '1980' AND yearid <= '1989' THEN '1980s'
		WHEN yearid >= '1990' AND yearid <= '1999' THEN '1990s'
		WHEN yearid >= '2000' AND yearid <= '2009' THEN '2000s'
		WHEN yearid >= '2010' AND yearid <= '2019' THEN '2010s'
		END AS decade
FROM teams
WHERE yearid >= '1920'
GROUP by decade
ORDER BY decade DESC;
-- A5: Strikeouts more common in the latter half of 1920-2010

-- Average number of home runs per game by decade since 1920:

SELECT
	ROUND(AVG(CAST(hr AS numeric)) / (SUM(CAST(g AS numeric))), 4) AS avg_hr_pg,
	CASE WHEN yearid >= '1920' AND yearid <= '1929' THEN '1920s'
		WHEN yearid >= '1930' AND yearid <= '1939' THEN '1930s'
		WHEN yearid >= '1940' AND yearid <= '1949' THEN '1940s'
		WHEN yearid >= '1950' AND yearid <= '1959' THEN '1950s'
		WHEN yearid >= '1960' AND yearid <= '1969' THEN '1960s'
		WHEN yearid >= '1970' AND yearid <= '1979' THEN '1970s'
		WHEN yearid >= '1980' AND yearid <= '1989' THEN '1980s'
		WHEN yearid >= '1990' AND yearid <= '1999' THEN '1990s'
		WHEN yearid >= '2000' AND yearid <= '2009' THEN '2000s'
		WHEN yearid >= '2010' AND yearid <= '2019' THEN '2010s'
		END AS decade
FROM teams
WHERE yearid >= '1920'
GROUP by decade
ORDER BY decade DESC;
-- A5: Home runs peaked in the 1950s?? Not sure if this is right

-- Q6: Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.

SELECT
	DISTINCT b.playerid,
	p.namefirst,
	p.namelast,
	CAST(b.sb AS numeric) AS stolenbases,
	CAST(b.cs AS numeric) AS caughtstealing,
	CAST(b.sb AS numeric) + CAST(b.cs AS numeric) AS attempts,
	ROUND((CAST(b.sb AS numeric) / (CAST(b.sb AS numeric) + CAST(b.cs AS numeric))), 2) AS success
FROM batting AS b
JOIN people AS p
ON b.playerid = p.playerid
WHERE b.yearid = '2016'
GROUP BY
	b.playerid,
	p.namefirst,
	p.namelast,
	b.sb,
	b.cs
HAVING CAST(sb AS numeric) + CAST(cs AS numeric) >= 20
ORDER BY success DESC;
-- A6: Chris Owings had the most success stealing bases in 2016 with a success rate of 91%.

-- Q7: From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT
	DISTINCT name,
	yearid,
	wswin,
	w
FROM teams
WHERE yearid >= 1970
	AND wswin NOT LIKE 'Y'
ORDER BY w DESC;
-- A7: Seattle Mariners has the largest number of wins (116 in 2001) for a team that did NOT win the World Series.

SELECT
	DISTINCT name,
	yearid,
	wswin,
	w
FROM teams
WHERE yearid >= 1970
	AND wswin LIKE 'Y'
ORDER BY w;
-- A7: Los Angeles Dodgers has the smallest number of wins (63 in 1981) for a team that DID win the World Series. Sabr.org says that there was a "50-day players strike in 1981, in which about a third of the season was eliminated".

SELECT
	DISTINCT name,
	yearid,
	wswin,
	w
FROM teams
WHERE yearid >= 1970
	AND wswin LIKE 'Y'
	AND yearid <> 1981
ORDER BY w;
-- A7: Last query redone without 1981: St. Louis Cardinals has the smallest number of wins (83 in 2006).

SELECT
	DISTINCT name,
	yearid,
	w
FROM teams
WHERE yearid >= 1970
	AND yearid <> 1981
GROUP BY DISTINCT name,
	yearid,
	w,
	wswin
HAVING wswin LIKE 'Y'
ORDER BY w;
-- Editing A7 with HAVING, not sure if I need to edit previous queries to reflect this

-- Q7 last part: How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT
	DISTINCT yearid,
	name,
	wswin,
	wins,
	mostwins
FROM(
	SELECT
		DISTINCT yearid,
		name,
		wswin,
		w AS wins,
		MAX(w) OVER(PARTITION BY yearid) AS mostwins
	FROM teams
	WHERE yearid >= 1970
	ORDER BY yearid DESC) AS subquery
WHERE wswin LIKE 'Y'
	AND wins = mostwins
ORDER BY yearid DESC;

-- A7: 12 out of 47 of the years from 1970 to 2016 (inclusive) or 25.53% of the time.

-- Q8: Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT
	team,
	park,
	attendance / COUNT(games) AS avg_att
FROM homegames
GROUP BY
	team,
	park,
	attendance
ORDER BY avg_att DESC;