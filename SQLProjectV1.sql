SELECT *
FROM SqlProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4


SELECT *
FROM SqlProject..CovidVaccinations
ORDER BY 3, 4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM SqlProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases Vs Total Deaths
-- shows the chance of dying, if you get the deadly covid virus in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SqlProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


-- observing the Total Cases Vs Population
-- reveals the percentage of population that got covid

SELECT Location, date, population, total_cases, (population/total_cases)*100 as PopulationPercentage
FROM SqlProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- observing countries with their highest infection rate compared to their population

SELECT Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM SqlProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

-- lets break things up by continent
SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM SqlProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Showing continent with the highest death count

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM SqlProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Observing global numbers

SELECT date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
FROM SqlProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Observing total cases vs total deaths

SELECT Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
FROM SqlProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


--looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated,
FROM SqlProject..CovidDeaths dea
JOIN SqlProject..CovidVaccinations vac
-- JOINING ON SPECIFIC KEY INFORMATION LIKE LOCATION AND DATE
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY  2, 3


	-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population)*100 
FROM SqlProject..CovidDeaths dea
JOIN SqlProject..CovidVaccinations vac
-- JOINING ON SPECIFIC KEY INFORMATION LIKE LOCATION AND DATE
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY  2, 3
	)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population)*100 
FROM SqlProject..CovidDeaths dea
JOIN SqlProject..CovidVaccinations vac
-- JOINING ON SPECIFIC KEY INFORMATION LIKE LOCATION AND DATE
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY  2, 3

	SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations



CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT( int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated/population)*100 
FROM SqlProject..CovidDeaths dea
JOIN SqlProject..CovidVaccinations vac
-- JOINING ON SPECIFIC KEY INFORMATION LIKE LOCATION AND DATE
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY  2, 3


	SELECT *
	FROM  PercentPopulationVaccinated

