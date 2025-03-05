-- Connect to database
use maven_advanced_sql;

-- PART I: SCHOOL ANALYSIS

-- TASK 1: View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;

-- TASK 2: In each decade, how many schools were there that produced players? [Numeric Functions]
SELECT 	 FLOOR(yearID / 10) *10 AS decade, COUNT(DISTINCT schoolID) AS num_school
FROM 	 schools
GROUP BY decade
ORDER BY decade ;


-- TASK 3: What are the names of the top 5 schools that produced the most players? [Joins]
SELECT 	sd.name_full, COUNT(DISTINCT s.playerID) AS num_players
FROM 	schools s LEFT JOIN school_details sd
				  ON s.schoolID = sd.schoolID
GROUP BY name_full
ORDER BY num_players DESC LIMIT 5;


-- TASK 4: For each decade, what were the names of the top 3 schools that produced the most players? [Window Functions]
WITH cte AS		(SELECT FLOOR(s.yearID / 10) * 10 AS decade, sd.name_full, COUNT(DISTINCT s.playerID) AS num_players
				FROM schools s LEFT JOIN school_details sd
								ON s.schoolID = sd.schoolID
				GROUP BY decade, s.schoolID),

	cte2 AS		(SELECT decade, name_full, num_players,
				ROW_NUMBER() OVER(PARTITION BY decade ORDER BY num_players DESC) AS row_num
				FROM cte)
                
SELECT decade, name_full, num_players
FROM cte2
WHERE row_num <=5
ORDER BY decade DESC, row_num;

-- PART II: SALARY ANALYSIS

-- TASK 1: View the salaries table
SELECT * FROM salaries;

-- TASK 2: Return the top 20% of teams in terms of average annual spending [Window Functions]
WITH cte AS	(SELECT   teamID, yearID, SUM(salary) AS total_spend
			 FROM 	  salaries
			 GROUP BY teamID, yearID
             ORDER BY teamID, yearID),
            
 cte2 AS 	(SELECT 	teamID, ROUND(AVG(total_spend)/ 1000000, 1) AS avg_spend, 
							NTILE(5) OVER(ORDER BY AVG(total_spend) DESC) AS percentile
				 FROM 		cte
				 GROUP BY 	teamID)

SELECT teamID, avg_spend
FROM cte2
WHERE percentile = 1;


-- TASK 3: For each team, show the cumulative sum of spending over the years [Rolling Calculations]
WITH cte AS 
		(SELECT 	teamID, yearID, SUM(salary) AS sum_salary
		FROM 	salaries
		GROUP BY teamID, yearID
        ORDER BY teamID, yearID)
	
SELECT	teamID, yearID,
		ROUND(SUM(sum_salary) OVER(PARTITION BY teamID ORDER BY yearID) / 1000000, 2) AS cum_sum_salary
FROM 	cte;


-- TASK 4: Return the first year that each team's cumulative spending surpassed 1 billion [Min / Max Value Filtering]
WITH st AS				
                (SELECT 	yearID, teamID, SUM(salary) AS sum_salary
				FROM 		salaries
				GROUP BY 	teamID, yearID),


 cs	AS			(SELECT 	yearID, teamID, sum_salary,
							SUM(sum_salary) OVER (PARTITION BY teamID ORDER BY yearID) AS cum_sum
				FROM 		st),

rn AS
				(SELECT 	yearID, teamID, cum_sum,
						ROW_NUMBER() OVER (PARTITION BY teamID ORDER BY cum_sum) AS row_sal
				FROM cs
				WHERE cum_sum > 1000000000)
                
SELECT 	teamID, yearID, ROUND(cum_sum / 1000000000, 2) AS cum_sum_bil
FROM 	rn
WHERE 	row_sal = 1;

-- PART III: PLAYER CAREER ANALYSIS

-- TASK 1: View the players table and find the number of players in the table
SELECT * FROM players;
SELECT COUNT(*) FROM players;

-- TASK 2: For each player, calculate their age at their first (debut) game, their last game,
-- and their career length (all in years). Sort from longest career to shortest career. [Datetime Functions]



-- TASK 3: What team did each player play on for their starting and ending years? [Joins]



-- TASK 4: How many players started and ended on the same team and also played for over a decade? [Basics]



-- PART IV: PLAYER COMPARISON ANALYSIS

-- TASK 1: View the players table
SELECT * FROM players;

-- TASK 2: Which players have the same birthday? Hint: Look into GROUP_CONCAT / LISTAGG / STRING_AGG [String Functions]



-- TASK 3: Create a summary table that shows for each team, what percent of players bat right, left and both [Pivoting]



-- TASK 4: How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference? [Window Functions]


