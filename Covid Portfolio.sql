/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject.dbo.CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, coalesce(MAX(total_cases),'') as HighestInfectionCount,  coalesce(Max((total_cases/population))*100,'') as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
Where population is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, coalesce(MAX(total_cases),'') as HighestInfectionCount,  coalesce(Max((total_cases/population))*100,'') as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
Where population is not null
Group by Location, Population, date
order by PercentPopulationInfected desc




-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%Brazil%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, ( total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
where location like '%Brazil%'
order by 1,2

-- Looking at Countries with highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
group by location, population
order by PercentPopulationInfected desc
 

 -- Showing Countries with Highest Death Count per Population

 Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc
 

 
 -- Showing Continentes with Highest Death Count per Population

 Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is not  null
group by continent
order by TotalDeathCount desc
 
 -- Global Number 

 Select sum(new_cases) as total_cases, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
 from PortfolioProject.dbo.CovidDeaths$
 where continent is not null
-- group by date
 order by 1,2;

 --  Looking at Total Population vs Vaccinations

With PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
 from  PortfolioProject.dbo.CovidDeaths$ dea
 join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)


-- Temp Table

drop table if exists  #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
 from  PortfolioProject.dbo.CovidDeaths$ dea
 join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
 from  PortfolioProject.dbo.CovidDeaths$ dea
 join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



-- To check out information from the Tableu Visualization


-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Double check based off the data provided


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



