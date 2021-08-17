--SHOWS likelihood of dying if you contract covid in your country

SELECT "LOCATION", "DATE", total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE "LOCATION" like '%States%'
order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT "LOCATION", "DATE", population, total_cases,(total_cases/population)*100 as DeathPercentage
FROM coviddeaths
WHERE "LOCATION" like '%States%'
order by 1,2;

-- Looking at Country with highest infection rate compared to population

SELECT "LOCATION", population, max(total_cases) as highestInfectioncount,max((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
--WHERE "LOCATION" like '%States%'
group by "LOCATION", population
order by PercentPopulationInfected desc;

-- Showing countries with the highest death count per population

SELECT "LOCATION", max(cast(total_deaths as int)) as totaldeathcount
FROM coviddeaths
--WHERE "LOCATION" like '%States%'
WHERE continent is not null
group by "LOCATION"
order by totaldeathcount desc;

-- Lets break things down by continent


SELECT "LOCATION", max(cast(total_deaths as int)) as totaldeathcount
FROM coviddeaths
--WHERE "LOCATION" like '%States%'
WHERE continent is null
group by "LOCATION"
order by totaldeathcount desc;

-- Showing continents with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as totaldeathcount
FROM coviddeaths
--WHERE "LOCATION" like '%States%'
WHERE continent is not null
group by continent
order by totaldeathcount desc;

-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- WHERE "LOCATION" like '%States%'
where continent is not null
--group by "DATE"
order by 1,2;


-- Looking at total populations vs vaccinations

Select dea.continent, dea."LOCATION", dea."DATE", dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea."LOCATION" order by dea."LOCATION", dea."DATE")
from coviddeaths dea
join covidvaccinations vac
on dea."LOCATION" = vac."LOCATION"
and dea."DATE" = vac."DATE"
where dea.continent is not null
order by 2,3;

-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea."LOCATION", dea."DATE", dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea."LOCATION" order by dea."LOCATION", dea."DATE")
as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea."LOCATION" = vac."LOCATION"
and dea."DATE" = vac."DATE"
where dea.continent is not null
--order by 2,3;
