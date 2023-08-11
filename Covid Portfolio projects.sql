SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

SELECT * FROM PortfolioProject..Covidvaccinations
ORDER BY 3,4;

-- To select the required columns

SELECT location,date,total_cases, new_cases,population
from PortfolioProject..CovidDeaths
ORDER BY 1,2;


-- Total cases versus Total Deaths
--(Showing the likelihood of dying contracting covid by country)
select location, date,total_cases,total_deaths, case when total_cases = 0 THEN null
		else (total_deaths/total_cases)*100
		END AS Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY Deathpercentage DESC;





-- Total cases versus population
--showing the percentage of population with covid

select location, date, total_cases, population,
		case when population = 0 THEN null
		else (total_cases/population)*100
		END AS Percentpopulationinfected
from PortfolioProject..CovidDeaths
order by population


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionRate,
MAX(total_cases/nullif(population,0))*100 AS Percentpopulationinfected
from PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Percentpopulationinfected DESC;





-- Showing countries with Highest Death count per population 
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE CONTINENT IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



-- BREAKING DOWN BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;



--Global Numbers
select date,
	  nullif(sum(new_cases),0) as totalnewcases,
	  nullif(sum(cast(new_deaths as int)),0) as totalnewdeaths,
	  sum(cast(new_deaths as int))/nullif(sum(new_cases),0) * 100 as deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
group by date
ORDER BY 1,2 desc;

--Creating a subquery

select date, isnull(totalnewdeaths/nullif(totalnewcases,0),0)*100 as deathpercentage from
(select date,
	  sum(new_cases) as totalnewcases,
	  sum(cast(new_deaths as int)) as totalnewdeaths
From PortfolioProject..CovidDeaths
group by date)  AS TTT


---Joining the two tables
select *
From PortfolioProject..Covidvaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date

-- Total population versus  Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..Covidvaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Total population versus Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..Covidvaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



