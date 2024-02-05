USE PortfolioProject

-- Checking data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;

-- Total Cases vs total deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

-- Total cases vs population
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS InfectionRate
FROM CovidDeaths
WHERE location = 'China'
ORDER BY 1, 2;

-- Countries with highest infection rate compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS InfectionRate
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY InfectionRate DESC

-- Countries with highest death rate compared to population
SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Continent
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death counts
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP by date
ORDER BY 1, 2;

-- Total pop vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE
WITH PopvVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CAST(RollingPeopleVaccinated as float)/population)*100
FROM PopvVac
WHERE location = 'Albania'

-- Temp table
DROP TABLE IF EXISTS #PrecentPopulationVaccinated
CREATE TABLE #PrecentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PrecentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CAST(RollingPeopleVaccinated as float)/population)*100
FROM #PrecentPopulationVaccinated
WHERE location = 'Albania'

-- Create view to store data for later visualization
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac 
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Check view
SELECT * 
FROM PercentagePopulationVaccinated