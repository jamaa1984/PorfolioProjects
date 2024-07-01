select *
from
PortfolioProject..CovidDeaths
order by 3,4

select *
from
PortfolioProject..CovidVaccination
order by 3,4

--select data that we are be using
select location,date,total_cases,new_cases,total_deaths,population
from
PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
-- shows liklihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From
PortfolioProject..CovidDeaths
where location like '%Afghanistan%'
order by 1,2


-- looking at Total cases vs Population

select location,date,total_cases,population, (convert(float,total_cases)/nullif(convert(float,population),0))*100 as PercentageCases
From
PortfolioProject..CovidDeaths
order by 5 desc

-- looking at countries with highest infection rate compared to population

select location,population,max(total_cases)as HighestInfectionCount, max ((convert(float,total_cases)/nullif(convert(float,population),0)))*100 as pourcentagepopulationunfection
From
PortfolioProject..CovidDeaths
group by location,population
order by 4 desc

--let's break things down by continent
select continent, max(cast(total_deaths as float))as TotalDeathCount
From
PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--showing countries with highest death count per population

select location, max(cast(total_deaths as float))as TotalDeathCount
From
PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
 
 -- Global numbers
select date, sum(cast(new_cases as float)) as sumcasesperday, sum(cast(new_deaths as float)) as deathsperday,sum((convert(float,new_deaths)/ nullif(convert(float,new_cases),0)))*100 as DeathPoucentage
from
PortfolioProject..CovidDeaths
group by date
order by DeathPoucentage desc

select date, sum(cast(new_cases as float)) as sumcasesperday, sum(cast(new_deaths as float)) as deathsperday,sum((cast(new_deaths as float)/nullif(cast(new_cases as float),0)))*100 as DeathPoucentage
from
PortfolioProject..CovidDeaths
group by date
order by date desc

select sum(cast(new_cases as float)) as sumcasesperday, sum(cast(new_deaths as float)) as deathsperday,sum((cast(new_deaths as float)/nullif(cast(new_cases as float),0)))*100 as DeathPoucentage
from
PortfolioProject..CovidDeaths

select *
from
PortfolioProject..CovidVaccination


-- How to join Two tables
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date

-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, convert(float,dea.population) as population, convert(float, vac.new_vaccinations) as newvaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1, 2, 3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by  2, 3

--USE CTE 

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by  2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population nvarchar(255),
New_vaccinations nvarchar(255),
RollingPeopleVaccinated nvarchar(255),
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2, 3

select *,(convert(float,RollingPeopleVaccinated)/(convert(float,population)))*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated