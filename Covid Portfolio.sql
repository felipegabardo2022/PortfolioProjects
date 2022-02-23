select * from PortfolioProject.dbo.CovidDeaths$
order by 3,4

/*
select * from PortfolioProject.dbo.CovidVaccinations$
order by 3,4
*/

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

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
select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

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

select *, ( RollingPeopleVaccinated/Population) *10
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
 from  PortfolioProject.dbo.CovidDeaths$ dea
 join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * From PercentPopulationVaccinated