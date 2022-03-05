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
WHERE p.playerid = 'gaedeed01'

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
ORDER BY p.height

-- Q3: Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

