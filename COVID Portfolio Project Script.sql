-- Select * 
-- from Project..CovidDeaths


Select location, date, total_cases, total_deaths,population
from Project..CovidDeaths
ORDER BY 1,2

--Comparing Total Deaths to Total Cases 
--Likelihood of dying 
-- Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
-- from Project..CovidDeaths

SELECT location, date, total_cases, total_deaths, 
       CAST(total_deaths AS decimal) / total_cases * 100 AS Death_Percentage
FROM Project..CovidDeaths
--WHERE location = 'Nigeria'
ORDER BY 1,2

--Comparing Total Cases to Population
SELECT location, date, population, total_cases,
       CAST(total_cases AS decimal) / population * 100 AS Cases_Percentage
FROM Project..CovidDeaths
 WHERE location = 'Nigeria'
ORDER BY 1,2

-- Determining countries with higer cases of infection
SELECT location, population, MAX (total_cases) as HighCases,
       MAX(CAST(total_cases AS decimal) / population) * 100 AS Cases_Percentage
FROM Project..CovidDeaths
GROUP BY location,population
ORDER BY 4 DESC

--Determining countries with the highest death rate
SELECT location, population, MAX (total_deaths) as DeathCases
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY 3 DESC

--Determining the continent with the highest death rate

SELECT continent, MAX (total_deaths) as DeathCases
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- SELECT location, MAX (total_deaths) as DeathCases
-- FROM Project..CovidDeaths
-- WHERE continent is null
-- GROUP BY location
-- ORDER BY 2 DESC

--Having a Global view


Select date, SUM (new_cases) as TotalCases, SUM(CAST(new_deaths as decimal)) as TotalDeaths, 
        SUM(CAST(new_deaths as decimal))/SUM (new_cases)*100 as DeathPercentage
from Project..CovidDeaths
WHERE continent is not null 
GROUP BY date 
order by 1,2


Select *
from Project..CovidVaccinations  

SELECT *
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location AND dea.date = vac.date

----Determining the population that got vaccinated in each country
SELECT dea.location, population, SUM(CAST (vac.new_vaccinations as decimal)) as TotalVaccination, 
        SUM(CAST (vac.new_vaccinations as decimal))/population *100 as Vaccination_Percentage
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location, population
ORDER BY 1

--Determining the cummulative number of people vaccinated per day in each country
SELECT dea.continent, dea.location, dea.date,population, vac.new_vaccinations,
         SUM(cast(vac.new_vaccinations as decimal)) 
         OVER (PARTITION BY dea.location order by dea.location, dea.date)  as CummulativeTotal
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
ORDER BY    2,3

----Deriving the Total population vaccinated per day in each country using CTE
WITH Pop_Vac (continent, location, date, population, new_vaccinations,CummulativeTotal) 
AS (
    SELECT dea.continent, dea.location, dea.date,population, vac.new_vaccinations,
         SUM(cast(vac.new_vaccinations as decimal)) 
         OVER (PARTITION BY dea.location order by dea.location, dea.date)  as CummulativeTotal
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null
)
Select continent, location, date, population, new_vaccinations,CummulativeTotal, (CummulativeTotal/population)*100
from Pop_Vac


---USING TEMP TABLE
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativeTotal numeric)


INSERT INTO #PercentVaccinated
SELECT dea.continent, dea.location, dea.date,population, vac.new_vaccinations,
         SUM(cast(vac.new_vaccinations as decimal)) 
         OVER (PARTITION BY dea.location order by dea.location, dea.date)  as CummulativeTotal
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null

SELECT * , (CummulativeTotal/Population)*100 as CummulativePercent
FROM #PercentVaccinated


----Creating Views
CREATE VIEW PercentVaccinated as 
SELECT dea.continent, dea.location, dea.date,population, vac.new_vaccinations,
         SUM(cast(vac.new_vaccinations as decimal)) 
         OVER (PARTITION BY dea.location order by dea.location, dea.date)  as CummulativeTotal
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null and vac.new_vaccinations is not null