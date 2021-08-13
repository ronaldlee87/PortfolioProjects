SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent is NOT NULL
ORDER BY 1,2


-- Shows likelihood of dying if covid is infected. 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent is NOT NULL
ORDER BY 1,2

-- Total case vs Population
-- Percentage of population got Covid
SELECT location, population, date, total_cases, (total_cases/ population)*100 as casePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND continent is NOT NULL
ORDER BY 1,2

-- 4. Tableau Table 4

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as 
	PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected DESC

-- 3. Tableau Table 3

-- Looking at Countries with Highest Infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as 
	PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


-- 2. Tableau Table 2 

-- Shows Countries with Highest Death count per population
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- break by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Shows continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- 1. Tableau Table 1 

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

-- Global Numbers by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2


-- Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations))  OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations))  OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3


Select *
From PercentPopulationVaccinated



