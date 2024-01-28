select location,date,total_cases,new_cases,total_deaths,population,continent from CovidDeaths
order by 1,2


-- total_deaths  vs total_cases 
-- shows the likelyhood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  as DeathPercentage from CovidDeaths
WHERE LOCATION LIKE 'India'
order by 1,2

-- looking at the total cases vs population

select location,date,total_cases,total_deaths,population,(total_cases/population)*100  as percentofpopulationinfected from CovidDeaths
-- WHERE LOCATION LIKE 'India'
order by 1,2


-- Looking at countries with higher infection rate compared to population

select location,population,max(total_cases) as highestInfectionCount,max(total_cases/population)*100  as  PercentOfPopulationInfected
from CovidDeaths
-- WHERE LOCATION LIKE 'India'
group by location,population
order by PercentOfPopulationInfected desc

select location,population,max(total_cases) as highestInfectionCount,max(total_cases/population)*100  as  PercentOfPopulationInfected
from CovidDeaths
-- WHERE LOCATION LIKE 'India'
group by location,population
order by PercentOfPopulationInfected desc

-- Showing countries with higher death_counts perpopulation

select location,max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
group by location
order by total_death_count desc


-- showing the continets with the highest death counts

select continent,max(cast(total_deaths as int)) as maximum_deaths from CovidDeaths
where continent is not null
group by continent
order by maximum_deaths desc

-- breaking to global number
select date,sum(new_cases )AS TOTAL_NEW_CASES,SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS,
SUM(CAST(new_deaths AS INT))/SUM(TOTAL_CASES)*100 AS 
DEATH_PERCENTAGE from CovidDeaths WHERE continent IS NOT NULL
group by  date
order by date


SELECT*FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location 
AND  DEA.DATE=VAC.DATE

-- LOOKING AT TOTAL POPULATION VS VACCINATION


SELECT DEA.CONTINENT, DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location 
AND  DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 2,3

--Rollinng new vaccination

SELECT DEA.CONTINENT, DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
 as Rollingpeoplevaccinate FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location 
AND  DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 2,3

-- use CET

with popvsVac(CONTINENT,LOCATION,DATE,POPULATION,
NEW_VACCINATIONS,rollingpeoplevaccinate)
as
(
SELECT DEA.CONTINENT, DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
 as Rollingpeoplevaccinate FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location 
AND  DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL)
select*,(rollingpeoplevaccinate/population)*100 from popvsVac

--Temp table
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(continent varchar(255),location varchar(255),Date datetime,
population numeric,new_vaccinations numeric,rollingPeopleVAccinatted numeric)

insert into #PercentagePopulationVaccinated
SELECT DEA.CONTINENT, DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
 as Rollingpeoplevaccinate FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location 
AND  DEA.DATE=VAC.DATE
--WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 2,3

select*, (rollingPeopleVAccinatted/population)*100 from #PercentagePopulationVaccinated
 

 create view percentagepopulationvaccinated as
 SELECT DEA.CONTINENT, DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date)
 as Rollingpeoplevaccinate FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location 
AND  DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 2,3
select *from percentagepopulationvaccinated



