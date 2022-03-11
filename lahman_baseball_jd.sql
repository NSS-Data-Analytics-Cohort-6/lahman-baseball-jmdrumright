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
-- 1864 to 2014, use MIN (Rob)

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
	p.playerid,
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
GROUP BY p.playerid,
	full_name,
	s.schoolname
ORDER BY total_salary_earned DESC; -- A3: David Price at $245,553,888.

SELECT playerid, SUM(salary)
FROM salaries
WHERE playerid LIKE 'priceda01'
GROUP BY playerid -- David Price should be $81,851,596????

SELECT
	DISTINCT p.playerid,
	s.salary,
	SUM(s.salary) AS sumsalary,
	s.yearid
FROM people AS p
LEFT JOIN collegeplaying AS c
ON p.playerid = c.playerid
LEFT JOIN salaries AS s
ON p.playerid = s.playerid
WHERE c.playerid IN (SELECT playerid
				  FROM collegeplaying
				  WHERE schoolid LIKE 'vandy') -- This shows that David Price should be $245,553,888 tho.
	AND c.playerid LIKE 'priceda01'
GROUP BY p.playerid, s.salary, s.yearid
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
	AVG(so+soa) / 2 AS avg_so,
	SUM(g) AS sumgame,
	ROUND(((AVG(so+soa)) / 2) / (SUM(g)), 2) AS avg_so_pg_bd,
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
ORDER BY decade;

-- Katie A5:
SELECT 
	ROUND((ROUND(AVG(so),2) / (SUM(g) / 2)), 2) AS avgsopg,
	ROUND((ROUND(AVG(hr),2) / (SUM(g) / 2)), 2) AS avghrpg,
	CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
		 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		 WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		 WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s' 
		 END AS decade
/* Alternative: CONCAT(LEFT(CAST(yearid AS text), 3), '0s') AS decade */
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

-- A5: Strikeouts peaked in the mid 1900s

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

-- Q7 last q: How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

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

-- A7: 12 / 47 of the years from 1970 to 2016 (inclusive) or 25.53% of the time.

-- Abigail A7:
WITH top_scores AS
	(SELECT a.yearid,
		a.name,
		a.w,
		a.wswin
	FROM teams AS a
	INNER JOIN (
		SELECT yearid,
				MAX(w) AS w
		FROM teams
		GROUP BY yearid
		ORDER BY yearid) AS b
	ON a.yearid = b.yearid AND a.w = b.w
	WHERE a.yearid BETWEEN 1970 AND 2016)
	SELECT SUM(CASE WHEN wswin = 'Y' THEN 1
			   WHEN wswin = 'N' THEN 0 END) AS total -- This matches my 12
		FROM top_scores;

WITH top_scores AS
	(SELECT a.yearid,
		a.name,
		a.w,
		a.wswin
	FROM teams AS a
	INNER JOIN (
		SELECT yearid,
				MAX(w) AS w
		FROM teams
		GROUP BY yearid
		ORDER BY yearid) AS b
	ON a.yearid = b.yearid AND a.w = b.w
	WHERE a.yearid BETWEEN 1970 AND 2016)
	SELECT ROUND(AVG(CASE WHEN wswin = 'Y' THEN 1
			   WHEN wswin = 'N' THEN 0 END)*100, 2) AS avg
		FROM top_scores; -- Denominator seems to be 52 (12/52) so her perc is 23.08%

-- Q8: Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT
	p.park_name,
	h.team,
	ROUND((CAST(h.attendance AS numeric) / CAST(h.games AS numeric))) AS avg_att,
	h.games
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
WHERE h.year = 2016
GROUP BY
	p.park_name,
	h.team,
	h.games,
	h.attendance
HAVING games >= 10
ORDER BY avg_att DESC
LIMIT 5;
/*A8: Dodger Stadium (Los Angeles Dodgers) at 45,720
Busch Stadium III (St Louis Cardinals) at 42,525
Rogers Center (Toronto Blue Jays) at 41,878
AT&T Park (San Francisco Giants) at 41,546
Wrigley Field (Chicago Cubs) at 39,906*/

SELECT
	p.park_name,
	h.team,
	ROUND((CAST(h.attendance AS numeric) / CAST(h.games AS numeric))) AS avg_att,
	h.games
FROM homegames AS h
JOIN parks AS p
ON h.park = p.park
WHERE h.year = 2016
GROUP BY
	p.park_name,
	h.team,
	h.games,
	h.attendance
HAVING games >= 10
ORDER BY avg_att
LIMIT 5;
/*A8: Tropicana Field (Tampa Bay Rays) at 15,879
Oakland-Alameda County Coliseum (Oakland Athletics) at 18,784
Progressive Field (Cleveland Indians) at 19,650
Marlins Park (Miami Marlins) at 21,405
U.S. Cellular Field (Chicago White Sox) at 21,559*/

-- Q9: Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH nat AS (
	SELECT
		DISTINCT playerid,
		awardid,
		yearid,
		lgid
	FROM awardsmanagers
	WHERE awardid LIKE 'TSN Manager of the Year' -- 1st CTE: National League
		AND lgid LIKE 'NL'),
am AS (
	SELECT
		DISTINCT playerid,
		awardid,
		yearid,
		lgid
	FROM awardsmanagers
	WHERE awardid LIKE 'TSN Manager of the Year' -- 2nd CTE: American League
		AND lgid LIKE 'AL')
SELECT
	nat.playerid,
	p.namegiven,
	p.namefirst,
	p.namelast,
	nat.yearid AS NLwinningyear,
	am.yearid AS ALwinningyear
FROM nat
JOIN am
ON nat.playerid = am.playerid
JOIN people AS p
ON p.playerid = am.playerid
WHERE (nat.lgid LIKE 'NL' AND am.lgid LIKE 'AL')
	AND (am.playerid LIKE 'johnsda02' OR am.playerid LIKE 'leylaji99');
-- A9: Davey Johnson (NL in 2012, AL in 1997) and Jim Leyland (NL in 1988, 1990, 1992, AL in 2006)

SELECT
	DISTINCT m.playerid,
	m.yearid,
	m.teamid,
	t.name
FROM managers AS m
JOIN teams AS t
ON m.teamid = t.teamid
WHERE m.playerid LIKE 'johnsda02'
	AND (m.yearid = 2012 OR m.yearid = 1997)
ORDER BY m.yearid DESC;
-- A9: Davey Johnson was managing the Baltimore Orioles in 1997 and the Washington Senators/Nationals in 2012.

SELECT
	DISTINCT m.playerid,
	m.yearid,
	m.teamid,
	t.name
FROM managers AS m
JOIN teams AS t
ON m.teamid = t.teamid
WHERE m.playerid LIKE 'leylaji99'
	AND (m.yearid = 1988 OR m.yearid = 1990 OR m.yearid = 1992 OR m.yearid = 2006)
ORDER BY m.yearid DESC;
-- A9: Jim Leyland was managing the Pittsburgh Pirates/Pittsburg Alleghenys in 1988, 1990, 1992 and the Detroit Tigers in 2006.

-- Q10: Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH maxhr AS ( -- 1st CTE: Max hr of each player's annual hr
	SELECT
		playerid,
		yearid,
		MAX(maxhrppby) OVER(PARTITION BY playerid) AS maxmaxhrppby -- Does yearid even matter?
	FROM(
		SELECT DISTINCT
			playerid,
			yearid,
			SUM(hr) OVER(PARTITION BY playerid, yearid) AS maxhrppby -- Gimme each player's annual hr (dup years removed w DISTINCT)
		FROM batting
		GROUP BY playerid, yearid, hr
		ORDER BY playerid) AS subquery
	GROUP BY
		playerid,
		yearid,
		maxhrppby
	ORDER BY playerid, yearid DESC),
--NO: If their maxmaxhrppby (not 2016) > 2016 hr, then they did NOT hit their career highest hr in 2016.
--YES: If their maxmaxhrppby (2016) <= 2016 hr, then they DID hit their career highest hr in 2016.

sixteenhr AS ( -- 2nd CTE: Number of homeruns for each player in 2016 with at least 1 hr
	SELECT
		DISTINCT playerid,
		SUM(hr) OVER(PARTITION BY playerid) AS totalhrppinsixteen
	FROM batting
	WHERE yearid = 2016
		AND hr >= 1
	GROUP BY playerid, hr),

decade AS ( -- 3rd CTE: Players with at least 10 yrs in the league
	SELECT
		b.playerid,
		p.debut,
		p.finalgame,
		CAST(p.finalgame AS date) - CAST (p.debut AS date) AS daysinlg
	FROM batting AS b
	JOIN people AS p
	ON b.playerid = p.playerid
	WHERE CAST(p.finalgame AS date) - CAST(p.debut AS date) >= 3650 -- Played for at least 10 years
	GROUP BY
		b.playerid,
		p.finalgame,
		p.debut)
-- Note: The only nulls for p.debut and p.finalgame are when both are null (195 rows) so don't worry about them

SELECT
	DISTINCT mh.playerid,
	p.namefirst,
	p.namelast,
	mh.yearid,
	mh.maxmaxhrppby,
	sh.totalhrppinsixteen,
	ROUND((CAST(d.daysinlg AS numeric) / 365), 2) AS yrsinlg,
	d.daysinlg
FROM maxhr AS mh
JOIN sixteenhr AS sh
ON mh.playerid = sh.playerid
JOIN decade AS d
ON sh.playerid = d.playerid
JOIN people AS p
ON d.playerid = p.playerid
WHERE yearid = 2016 -- Show me their hr for 2016 only
	AND mh.maxmaxhrppby = sh.totalhrppinsixteen -- Show me that their career high matches 2016
-- A10: 8 players hit their career highest number of home runs in 2016 (verified playerids thru the query below)
-- Note: Some ppl's career high is in 2016 and another year: Edwin Encarnacion (2012), Francisco Liriano (2015), Adam Wainwright (2009)

SELECT playerid, yearid, MAX(hr)
FROM batting
WHERE playerid LIKE 'canoro01' -- Change playerid to verify their career max is in 2016
GROUP BY yearid, playerid, hr
ORDER BY hr DESC, yearid DESC;
-- Playerids (8): canoro01, colonba01, davisra01, encared01, liriafr01, napolmi01, paganan01, wainwad01

-- Katie A10 (returns dupes):
WITH a AS
	(SELECT 
		b.playerid,
		COUNT (b.yearid) AS years
	FROM batting AS b
	GROUP BY b.playerid
	HAVING COUNT(b.yearid)>10),

c AS
	(SELECT
		b.playerid,
	 	b.yearid,
	 	b.hr,
		MAX(b.hr) AS career_high
	  FROM batting AS b
	  WHERE b.yearid = '2016'
	  GROUP BY 
	 	b.playerid,
		b.yearid,
	 	b.hr
	   HAVING b.hr = MAX(b.hr))

SELECT
 	a.playerid,
	a.years,
	b.hr,
	c.career_high,
	p.namefirst,
	p.namelast,
	b.yearid,
	c.yearid
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
INNER JOIN a
ON a.playerid = p.playerid
INNER JOIN c
ON a.playerid = c.playerid
WHERE b.yearid = 2016
	AND b.yearid = c.yearid
	AND b.hr >= 1
GROUP BY 
	a.playerid,
	a.years,
	b.hr,
	c.career_high,
	p.namefirst,
	p.namelast,
	b.yearid,
	c.yearid
ORDER BY c.career_high DESC;