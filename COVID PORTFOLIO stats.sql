Select * 
FROM PortfolioProjects..CovidDeaths
Order by 3, 4

Select *
From PortfolioProjects..CovidVaccines
Order By 3, 4


--Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%states%'
Order by 1, 2

--Looking at Total cases vs the population
--shows percentage of population got Covid
Select Location, date, population, total_cases, (Total_cases/population)*100 as PopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%Phil%'
Order by 1, 2

--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases)as HighestInfectionCount, MAX(Total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%Phil%'
Group By location, Population
Order by PercentPopulationInfected desc

--Showing countries with the highest Death count per population

Select Location, MAX(cast (total_deaths as int))as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%Phil%'
Where continent is not null
Group By location
Order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the highest death per count per poppulation

Select location, MAX(cast (total_deaths as int))as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%Phil%'
Where continent is null
Group By location
Order by TotalDeathCount desc





--GLOBAL NUMBERS (include using of aggregate functions)

Select date, SUM(new_cases)as totalCases, SUM (cast(new_deaths as int))as totalDeaths, SUM(cast
	(new_deaths as int))/Sum (New_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--Where location like '%states%'
where continent is not Null
Group by date
Order by 1, 2

--Global Cases vs Total Deaths Percentage
Select SUM(new_cases)as totalCases, SUM (cast(new_deaths as int))as totalDeaths, SUM(cast
	(new_deaths as int))/Sum (New_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--Where location like '%states%'
where continent is not Null
--Group by date
Order by 1, 2




--Looking at Total Population vs Vaccination (JOining two Tables)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProjects..CovidDeaths as dea
JOIN PortfolioProjects..CovidVaccines as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORder by 1,2,3

--Using partition By for Location 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast (new_vaccinations as bigint)) OVER (Partition by dea.Location ORder by dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths as dea
JOIN PortfolioProjects..CovidVaccines as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORder by 1,2,3



--USE CTE  (Execute including the CTE)
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast (new_vaccinations as bigint)) OVER (Partition by dea.Location ORder by dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths as dea
JOIN PortfolioProjects..CovidVaccines as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORder by 1,2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
ORder by 2,3





--TEMP TABLE



DROP TABLE if exists #RollingPeopleVaccinated
Create Table #RollingPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #RollingPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast (new_vaccinations as bigint)) OVER (Partition by dea.Location ORder by dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths as dea
JOIN PortfolioProjects..CovidVaccines as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORder by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #RollingPeopleVaccinated
ORder by 2,3





--Creating View to store data later visualization





Create View PercentPopVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (Cast (new_vaccinations as bigint)) OVER (Partition by dea.Location ORder by dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths as dea
JOIN PortfolioProjects..CovidVaccines as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORder by 1,2,3



Select *
From PercentPopVaccinated



