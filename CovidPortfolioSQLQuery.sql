SELECT *
FROM PortfolioProject..CovidDeaths
Where Continent is not NULL
Order By 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where Continent is not NULL
Order By 1,2

-- Look at total cases vs total deaths
-- show the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
AND Continent is not NULL
Order By 1,2

-- Look at the total cases vs population
-- show what percentage of population got Covid

SELECT location, date, population, total_cases, (cast(total_cases as float) / cast(population as float))*100 AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' OR location like '%canada%'
Where Continent is not NULL
Order By 1,2

-- Look at countries with highest infection rate compared to population

SELECT location, population, Max(cast(total_cases as int)) as HighestInfectionCount, cast(Max( cast(total_cases as int) / population)*100 as int) AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' OR location like '%canada%'
Where Continent is not NULL
Group By location, population
Order By PercentageOfPopulationInfected DESC

-- Showing the countries with the highest death count per population

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' OR location like '%canada%'
Where Continent is not NULL
Group By location
Order By TotalDeathCount DESC


-- Break things down by continent

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' OR location like '%canada%'
Where continent is NULL
Group By location
Order By TotalDeathCount DESC



-- Showing the continents with the highest death count per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%' OR location like '%canada%'
Where continent is not NULL
Group By continent
Order By TotalDeathCount DESC

-- Global Numbers

SELECT date, sum(new_cases) AS TotalCases, sum(cast(new_deaths as int)) AS TotalDeaths, sum(cast(new_deaths as int)) / NULLIF(sum(new_cases),0)*100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE Continent is not NULL
GROUP By date
Order By 1,2


-- Total cases
SELECT sum(new_cases) AS TotalCases, sum(cast(new_deaths as int)) AS TotalDeaths, sum(cast(new_deaths as int)) / nullif(sum(new_cases),0)*100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE Continent is not NULL
-- GROUP By date
Order By 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Create Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
-- order by 2,3

SELECT *
FROM PercentPopulationVaccinated