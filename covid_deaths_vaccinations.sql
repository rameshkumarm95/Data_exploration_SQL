-- Database
USE [SQL_Portfolio_Projects];


-- View all the attributes and the records 
SELECT * FROM CovidDeaths;
SELECT * FROM CovidVaccinations;

-- Data cleaning (Check formats)
ALTER TABLE CovidDeaths
ALTER COLUMN date DATE;

ALTER TABLE CovidVaccinations
ALTER COLUMN date DATE;



-- Data Exploration

-- Select the important data for analysis
SELECT location, date, total_cases, new_cases, total_deaths
, population
FROM CovidDeaths
ORDER BY 1,2;


-- 1. Looking at Total_Cases vs Total_Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, total_cases,
total_deaths, CONCAT(100*(total_deaths/total_cases),' %')
AS percent_deaths FROM CovidDeaths
WHERE total_cases != 0 AND total_deaths != 0
ORDER BY 1;

-- 2. Looking at Total_cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population,
CONCAT(100*(total_cases/population),' %') AS percent_infected
FROM CovidDeaths
WHERE total_cases != 0 AND population != 0
ORDER BY 1,2;


-- 3. Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) 
AS Higest_infected_count, 
MAX(CONCAT(100*(total_cases/population),' %'))
AS percent_infected
FROM CovidDeaths
WHERE total_cases != 0 AND population !=0
GROUP BY location,population
ORDER BY 4 DESC;


-- 4. Showing countries with highest death count per population
SELECT TOP 5 location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;



-- 5 Showing continents with highest death count per population
SELECT TOP 5 continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;


-- 6. Global numbers
SELECT date, SUM(new_cases) AS total_new_cases_per_day,
SUM(new_deaths) AS total_deaths,
100*(SUM(new_deaths) / SUM(new_cases)) 
AS percentage_death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(new_cases)> 0
ORDER BY 1,2;


-- 7. Joining two tables
SELECT * FROM CovidDeaths c JOIN CovidVaccinations v
ON c.location = v.location AND c.date = v.date;


-- 8. Looking at Total population vs vaccinations
SELECT TOP 5 c.continent,c.location, c.date,
c.population,v.new_vaccinations
FROM CovidDeaths c JOIN CovidVaccinations v
ON c.location = v.location AND c.date = v.date
WHERE (c.continent IS NOT NULL AND c.continent != '')
AND v.new_vaccinations > 0
ORDER BY 2,3;

SELECT c.continent,c.location, c.date,
c.population,v.new_vaccinations,
SUM(v.new_vaccinations) OVER(PARTITION BY c.location
ORDER BY c.location,c.date)
AS Rolling_people_vaccinated
FROM CovidDeaths c JOIN CovidVaccinations v
ON c.location = v.location AND c.date = v.date
WHERE (c.continent IS NOT NULL AND c.continent != '')
AND v.new_vaccinations > 0
ORDER BY 2,3;


WITH pop_vac AS (
SELECT c.continent,c.location, c.date,
c.population,v.new_vaccinations,
SUM(v.new_vaccinations) OVER(PARTITION BY c.location
ORDER BY c.location,c.date)
AS Rolling_people_vaccinated
FROM CovidDeaths c JOIN CovidVaccinations v
ON c.location = v.location AND c.date = v.date
WHERE (c.continent IS NOT NULL AND c.continent != '')
AND v.new_vaccinations > 0
)
SELECT *, (Rolling_people_vaccinated/population) * 100
FROM pop_vac;
