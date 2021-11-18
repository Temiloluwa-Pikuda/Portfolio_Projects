/* DATA EXPLORATION
Covid-19 World data

Skills: Aggregate functions, Window functions, Converting data types, Joins, CTE's, Creating Views
*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 


-- Select data that we are to begin with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Total Cases vs Total Deaths (shows likelihood of death if covid is contracted)

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2


--Total cases vs the Population (Shows what percentage of population got covid)

select location, date,  population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2


-- Countries with Highest Infection Rate compared to Poulation

select location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
group by population, location
order by PercentPopulationInfected desc


--Countries with the Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Nigeria%'
group by location
order by TotalDeathCount desc


-- BREAKING DOWN BY CONTINENT

--Continents with the Highest Death Count per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by  date
order by 1,2

-- Global numbers per date

select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by  date
order by 1,2


--Total population vs Vaccinations (Shows the percentage of population that have been vaccinated)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Creating view to store data for later visualizations

Create View PercentPopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View TotalcasesvsTotaldeaths as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--order by 1,2

Create View TotalcasevsPopulation as
select location, date,  population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths

Create view CountriesHighestInfectionrate as
select location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
group by population, location

Create View CountriesHighestDeathCount as
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location

Create View ContinentHighestDeathCount as
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent

Create View globalnumbers as
select  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null

Create View globalnumbersbydate as
select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by  date