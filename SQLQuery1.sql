Select * 
From dataexplo..CovidDeaths
where continent is not null 
order by 3,4

Select * 
From dataexplo..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From dataexplo..CovidDeaths
where continent is not null
order by 1,2

--looking at likelihood of death for people who contract covid in the united states
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dataexplo..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--checking to see what role population plays in the number of total cases
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From dataexplo..CovidDeaths
order by 1,2

--looking at which countries have the highest ratio of infections compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
From dataexplo..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--looking at which countries have the highest number of deaths
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataexplo..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--looking at which continents have the highest number of deaths
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataexplo..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--looking at global deathrate
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From dataexplo..CovidDeaths
where continent is not null
order by 1,2

--looking at number of vaccinations compared to total population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dataexplo..CovidDeaths dea
Join dataexplo..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--adding CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dataexplo..CovidDeaths dea
Join dataexplo..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--adding temp table
DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dataexplo..CovidDeaths dea
Join dataexplo..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating views for tableau
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from dataexplo..CovidDeaths dea
Join dataexplo..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View TotalDeathCountCountries as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataexplo..CovidDeaths
where continent is not null
group by location
--order by TotalDeathCount desc

Create View TotalDeathCountContinents as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dataexplo..CovidDeaths
where continent is not null
group by continent
--order by TotalDeathCount desc

Create View InfectionsVsPopulation as 
Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
From dataexplo..CovidDeaths
group by location, population
--order by PercentPopulationInfected desc

Create View DeathPercentage as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dataexplo..CovidDeaths
--Where location like '%states%'
--and continent is not null
--order by 1,2