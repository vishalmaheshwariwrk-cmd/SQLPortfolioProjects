Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are using

Select location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid by countries
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location,date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%India%'
Order by 1,2

--what country has the highest infection rate compared to the population
Select location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

--Highest Death count by countries population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount -- converting varchar to int
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc


--showing the continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount -- converting varchar to int
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc
--Testing it will continent is null
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount -- converting varchar to int
--From PortfolioProject..CovidDeaths
--where continent is null
--Group by location
--Order by TotalDeathCount desc


--Global numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

--Global numbers without date
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Combining two tables covid deaths and covid vaccinations
--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--More details
--Parition breaks the sum based on new locations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE 
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP Table

DROP Table if exists #PercentPopulationVaccinated --to delete temp table automatically
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) --bigint to avoid overflow
OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating a view to store data for later visulizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint, vac.new_vaccinations)) --bigint to avoid overflow
OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,
       vac.new_vaccinations,
       SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (
           PARTITION BY dea.location 
           ORDER BY dea.location, dea.date
       ) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- to resolve when i cant see file under view
EXEC sp_help 'PercentPopulationVaccinated';

SELECT * FROM PercentPopulationVaccinated; -- to view everything from table

SELECT name, SCHEMA_NAME(schema_id) AS schema_name
FROM sys.views
WHERE name = 'PercentPopulationVaccinated';



----More Analysis
/*

Queries used for Tableau Project

*/
-- 1. 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location
--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2

-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
