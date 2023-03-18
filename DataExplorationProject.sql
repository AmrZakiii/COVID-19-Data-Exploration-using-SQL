
SELECT * FROM CovidDeaths$
where continent is not null
ORDER BY 3,4

SELECT * FROM CovidVaccinations$
ORDER BY 3,4

-- 1 Selecting used data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

-- total cases vs total deaths 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM CovidDeaths$
Where location = 'Egypt'
ORDER BY 1,2

-- total cases vs population 

SELECT location, date, total_cases, population, (total_cases/population)*100 as infectionPercentage
FROM CovidDeaths$
Where location = 'Egypt'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT location, population , MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as infectionPercentage
FROM CovidDeaths$
GROUP BY location, population
ORDER BY infectionPercentage DESC

-- Highest Death Count per Population for Country

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
where continent is not NULL
Group by location
order by TotalDeathCount DESC

-- Global numbers daily

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Population vs new Vaccinations per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) as RollingPplVaccinated
From CovidDeaths$ as dea
join CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- CTE to carry out further operations on newly created columns

WITH PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPplVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) as RollingPplVaccinated
From CovidDeaths$ as dea
join CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPplVaccinated/Population)*100 AS RollingPercentageVaccinated
FROM PopvsVac
