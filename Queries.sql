use PortfolioProject
Go

select * 
from PortfolioProject ..CovidDeaths
where continent is not NULL
order by 3, 4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. CovidDeaths
order by 1,2

-- Looking at toal cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.. CovidDeaths
where location like '%India%' and continent is not NULL
order by 1,2

-- Looking at total cases vs population 
-- Shows what percentage of population got covid

Select Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.. CovidDeaths
where location like '%India%' and continent is not NULL
order by 1,2

-- Looking at countries with high infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.. CovidDeaths
-- where location like '%India%'
group by location, population
order by PercentPopulationInfected desc

-- Showing countries wiht highest death rate per population 

Select location, max(cast (total_deaths as int )) as TotalDeathCount
from PortfolioProject.. CovidDeaths
where continent is not NULL
-- where location like '%India%'
group by location
order by TotalDeathCount desc

--Let's break things by continent

Select continent, max(cast (total_deaths as int )) as TotalDeathCount
from PortfolioProject.. CovidDeaths
where continent is not NULL
-- where location like '%India%'
group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, max(cast (total_deaths as int )) as TotalDeathCount
from PortfolioProject.. CovidDeaths
where continent is not NULL
-- where location like '%India%'
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select sum(cast (new_deaths as int)) as total_deaths ,sum(new_cases) as total_cases ,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.. CovidDeaths
where continent is not NULL
--group by date
order by 1,2

-- Covid Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Use CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/population) from PopVsVac

-- Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
select * , (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated