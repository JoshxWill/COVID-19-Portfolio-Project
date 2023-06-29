/*
COVID-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From [PortfolioProject(COVID)]..CovidDeaths
Where continent is not null
Order By 3, 4

--Select Data used
Select location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject(COVID)]..CovidDeaths
Order By 1, 2

-- Looking at Total Cases vs. Total Deaths
-- Shows Likelihood of dying if you contracted COVID during these TimeStamps
Select location, date, total_cases, total_deaths, (CONVERT(decimal(15,3), total_deaths)/CONVERT(decimal(15,3), total_cases)) *100 as DeathPercentage
From [PortfolioProject(COVID)]..CovidDeaths
Where location like '%states%'
Order By 1, 2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got COVID
Select location, date, population total_cases, (CONVERT(decimal(15,3), total_cases)/CONVERT(decimal(15,3), population)) *100 as PercentagePopulationInfected
From [PortfolioProject(COVID)]..CovidDeaths
Where location like '%states%'
Order By 1, 2


-- Countries with Highest Infestion Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(decimal(15,3), total_cases)/CONVERT(decimal(15,3), population)) *100 as PercentagePopulationInfected
From [PortfolioProject(COVID)]..CovidDeaths
Group By location, population
Order By PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as  TotalDeathCount
From [PortfolioProject(COVID)]..CovidDeaths
Where continent is not null
Group By location, population
Order By TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject(COVID)]..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [PortfolioProject(COVID)]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject(COVID)]..CovidDeaths dea
Join [PortfolioProject(COVID)]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject(COVID)]..CovidDeaths dea
Join [PortfolioProject(COVID)]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject(COVID)]..CovidDeaths dea
Join [PortfolioProject(COVID)]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject(COVID)]..CovidDeaths dea
Join [PortfolioProject(COVID)]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



