/*

IMPORTING AND QUERYING COVID DEATHS AND VACCINATION DATA

*/


--------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--------------------------------------------------------------------------------------------------------------------------
  
--SELECT Data that we are going to be using 

SELECT Location,Date, Total_cases ,New_cases,Total_deaths,Population
FROM PortfolioProject..CovidDeaths
where continent is not null
Order By 1,2


--------------------------------------------------------------------------------------------------------------------------

--Looking at Total cases vs Total Deaths
  
--Shows likelihood of dying if you contract covid in your country 
  
SELECT Location,Date, Total_cases ,Total_deaths, 
(Total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location like 'India'
Order By 1,2


--------------------------------------------------------------------------------------------------------------------------  

--Looking at total Cases vs Population
  
--Shows what percentage of population got covid

SELECT Location,Date,Population, Total_cases , 
(Total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where Location like 'India'
Order By 1,2


--------------------------------------------------------------------------------------------------------------------------  

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location,Population, Max(Total_cases) AS HighestInfectionCount ,
Max((Total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
Group By Location,Population
Order By PercentPopulationInfected DESC


--------------------------------------------------------------------------------------------------------------------------  

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by Location
Order by TotalDeathCount DESC

  --------------------------------------------------------------------------------------------------------------------------

--Lets Break Things  Down By CONTINENT
  
--Showing continents with the highest death count per population 

SELECT Continent, MAX(cast(Total_Deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by Continent
Order by TotalDeathCount DESC


--------------------------------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS

--BY DATE

SELECT Date, SUM(new_cases) as Total_cases,SUM(cast(New_deaths as int)) 
AS Total_deaths,SUM(cast(New_deaths as int))/SUM(New_Cases)*100 
AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
Group by Date
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

--AS total cases and total deaths 

SELECT SUM(new_cases) as Total_cases,SUM(cast(New_deaths as int)) 
AS Total_deaths,SUM(cast(New_deaths as int))/SUM(New_Cases)*100 
AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
order by 1,2


--------------------------------------------------------------------------------------------------------------------------

--JOINING Covid_Deaths Table AND CovidVaccination Table

SELECT*
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date

--------------------------------------------------------------------------------------------------------------------------

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--------------------------------------------------------------------------------------------------------------------------

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,SUM(Convert(int, vac.new_vaccinations))
OVER (partition by dea.Location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--------------------------------------------------------------------------------------------------------------------------  

--Calculating Percentage of PopvsVac using CTE
  
WITH PopvsVac (Continent,Location, Date , Population,New_vaccinations,
RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,SUM(Convert(int, vac.new_vaccinations))
OVER (partition by dea.Location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
)
Select*, (RollingpeopleVaccinated/Population)*100
From PopvsVac


--------------------------------------------------------------------------------------------------------------------------

--USING TEMP TABLE FOR POPVSVAC

DROP Table IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,SUM(Convert(int, vac.new_vaccinations)) 
OVER (partition by dea.Location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
--WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--------------------------------------------------------------------------------------------------------------------------

--Creating View to store data for later Visualization

Create View PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,SUM(Convert(int, vac.new_vaccinations)) 
OVER (partition by dea.Location ORDER BY dea.location,dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3


select *
from PercentPopulationVaccinated
