-- Loaded a csv file, taking a look at it

Select * From PortfolioProject..CovidDeaths

--Taking a look at specific columns of focus"

Select Location, date, total_cases,new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
order by Location, Date

-- Looking at deaths/cases as new column DeathPercentage

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths

-- Finding countries with highest percentage of population infected as new column PercentInfected

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentInfected DESC

-- Finding countries Total Death Count

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by Location
Order by TotalDeathCount DESC


--Finding continents Total Death Count 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is null
Group by location
Order by TotalDeathCount DESC

-- Joining vaccination data to deaths data. Finding a rolling total of people vaccinated and percent of people vaccinated. Creating a CTE.

WITH PopulationVsVaccination (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
Where d.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
FROM PopulationVsVaccination

--Creating a Temp Table

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--Inserting data into temp table

INSERT INTO #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
Where d.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating a view to store data for later visualization in PowerBI

Create view PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
Where d.continent is not null