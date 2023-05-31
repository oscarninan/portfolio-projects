SELECT *
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM Portfolio..CovidVaccinations
--ORDER BY 3,4

-- Selecting Date to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
ORDER BY 1,2

-- Checking Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract Covid in your Country

SELECT location, date, total_cases, total_deaths, 
((CONVERT(float, total_deaths)/CONVERT(float,total_cases))*100) AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid

SELECT location, date, population, total_cases,  
((CONVERT(float, total_cases)/CONVERT(float,population))*100) AS CovidPercentage
FROM Portfolio..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to Population


SELECT location, population, MAX(convert(float,total_cases)) AS HighestInfectionCount,
MAX((convert(float,total_cases)/population))*100 AS InfectedPopPercentage
FROM Portfolio..CovidDeaths
--WHERE location = 'Canada'
GROUP BY location, population
ORDER BY InfectedPopPercentage DESC

-- Looking at Countries with highest death count compared to Population


SELECT location, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Canada'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at the Situation continent wise


SELECT continent, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
--MAX((convert(float,total_deaths)/population))*100 AS DeathsPercentage
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Canada'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL SITUATION with Deaths vs Cases

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
(SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_count_people_vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_count_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_count_people_vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_count_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_count_people_vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_count_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_count_people_vaccinated
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated