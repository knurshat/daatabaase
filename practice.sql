CREATE TABLE players (
    players_id SERIAL PRIMARY KEY,
    players_name VARCHAR(50),
    team_name VARCHAR(50),
    position VARCHAR(50),
    jersey_number INTEGER,
    height_cm INTEGER,
    birth_date DATE,
    salary INTEGER
);
CREATE TABLE teams(
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(50),
    city VARCHAR(50),
    coach_name VARCHAR(50),
    home_stadium VARCHAR(50),
    championship_wins INTEGER,
    founded_year INTEGER
);
CREATE TABLE matches(
    match_id SERIAL PRIMARY KEY,
    home_team VARCHAR(50),
    away_team VARCHAR(50),
    match_date DATE,
    home_score INTEGER,
    away_score INTEGER,
    attendance VARCHAR(50)
);


SELECT
  CONCAT(players_name, ' (#', jersey_number, ')') AS player_info,
  UPPER(team_name) AS team_upper,
  LEFT(position, 2) AS short_position
FROM players;

SELECT
  players_name,
  height_cm,
  CASE
    WHEN height_cm > 190 THEN 'Tall'
    WHEN height_cm BETWEEN 175 AND 190 THEN 'Average'
    ELSE 'Short'
  END AS height_category
FROM players;

SELECT *
FROM teams
WHERE city LIKE 'Los%' OR city LIKE '%ton';

SELECT *
FROM players
WHERE salary BETWEEN 500000 AND 2000000
  AND position <> 'Goalkeeper';


SELECT
  players_name,
  height_cm,
  CASE
    WHEN height_cm > 190 THEN 'Tall'
    WHEN height_cm BETWEEN 175 AND 190 THEN 'Average'
    ELSE 'Short'
  END AS height_category
FROM players;

SELECT *
FROM teams
WHERE city LIKE 'Los%' OR city LIKE '%ton';

SELECT *
FROM players
WHERE salary BETWEEN 500000 AND 2000000
  AND position <> 'Goalkeeper';

SELECT
  players_name,
  EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_date) AS age
FROM players;

SELECT *
FROM matches
WHERE (home_score + away_score) > 5;

SELECT *
FROM teams
WHERE championship_wins > 2 OR founded_year < 1950;



