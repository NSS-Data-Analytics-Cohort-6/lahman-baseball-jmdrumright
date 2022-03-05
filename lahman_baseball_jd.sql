-- Q1: What range of years for baseball games played does the provided database cover?
-- A1: 1871 to 2016

SELECT MIN(yearid),
	MAX(yearid)
FROM batting;

-- Q2: Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- A2: Eddie Edward Carl Gaedel.

SELECT MIN(height) AS shortest_height,
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

SELECT DISTINCT p.playerid,
	p.height,
	p.namefirst,
	p.namelast,
	a.g_all
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
ORDER BY p.height
LIMIT 1;

-- A2: Eddie Edward Carl Gaedel played in 1 game.
SELECT a.g_all,
	p.namefirst,
	p.namegiven,
	p.namelast,
	p.playerid
FROM people AS p
JOIN appearances AS a
ON p.playerid = a.playerid
WHERE p.playerid = 'gaedeed01';

-- A2: Eddie Edward Carl Gaedel played for St. Louis Browns
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

-- Q3: Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- A3: David David Taylor Price at $245,553,888.

SELECT CONCAT(CAST(p.namefirst AS text), ' ', CAST(p.namelast AS text)) AS full_name,
	s.schoolname,
	SUM(sa.salary) AS salary
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
ORDER BY salary DESC;

-- Q4: Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
-- A4: Outfield = 29,650 putouts, Infield = 58,934 putouts, Battery = 41,424 putouts

SELECT DISTINCT playerid,
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

-- Q5: Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

