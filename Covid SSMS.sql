select * from PorfolioProj..CovidDeaths
where continent is not null
order by 3,4

select location, date,total_cases, new_cases, total_deaths, population  
from PorfolioProj..CovidDeaths
order by 1,2

-- looking at the total cases vs total deaths
-- liklihood of dying if you contract covid in your country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProj..CovidDeaths
where location like '%states%' -- and continent is not null
order by 1,2

-- total cases vs population 
-- show what percntage of population got covid

select location, date, population, total_cases,  (total_cases/population)*100 as InfectionPercentage
from PorfolioProj..CovidDeaths
-- where location like '%states%' and continent is not null
order by 1,2

-- looking at contries with highest infection rate compared to population

select location,population, MAX(total_cases)as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectionPercentage
from PorfolioProj..CovidDeaths
-- where location like '%states%'and continent is not null
group by location, population
order by InfectionPercentage desc

-- showing countries with the highest death count per population
select location, MAX(cast(total_deaths as int))as TotalDeathCount 
from PorfolioProj..CovidDeaths
-- where location like '%states%' 
where continent is not null
group by location, population
order by TotalDeathCount desc

-- Lets break things down by continent 
--showing the continents with the highest death count

select continent, MAX(cast(total_deaths as int))as TotalDeathCount 
from PorfolioProj..CovidDeaths
-- where location like '%states%' 
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
select SUM(new_cases) as NewCases, sum(new_deaths) as Deaths--, SUM(new_deaths)/SUM(new_cases)*100
from PorfolioProj..CovidDeaths
where continent is not null
--group by date 
order by 1,2


-- total population vs vacination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProj..CovidDeaths  dea
join PorfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProj..CovidDeaths  dea
join PorfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population) 
from PopvsVac 

-- Temp Table

Create Table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
 Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProj..CovidDeaths  dea
join PorfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) 
from #PercentPopulationVaccinated 


-- creating View to store data for later visualization

Create View PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from PorfolioProj..CovidDeaths  dea
join PorfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated