select *
from covid19_portfolio.covid19_deaths
order by 3,4;

-- select *
-- from covid19_portfolio.covid19_vaccinations
-- order by 3,4;
-- 

-- UPDATE - I want to have null value in the continent column where continent = ''  (empty string) , so:

update covid19_portfolio.covid19_deaths
set continent = null
where continent = ''

update covid19_portfolio.covid19_vaccinations 
set continent = null
where continent = ''

-- Change 'date' column type 

alter table covid19_portfolio.covid19_deaths 
modify date date

alter table covid19_portfolio.covid19_vaccinations 
modify date date

-- Select Data that we are going to be using

select location , date , total_cases , new_cases , total_deaths , population 
from covid19_portfolio.covid19_deaths
order by 1,2

-- Looking at total case vs total deaths 
-- Shows likelihood of dying if you contract covid in your country

select location , date , total_cases  , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from covid19_portfolio.covid19_deaths
where location = 'Poland' 
order by 1,2
-- limit 10

-- Looking at Total cases vs Population
-- Shows what percantage of population got Covid

select location , date , total_cases  , population , (total_cases /population)*100 as PercentPopulationInfected
from covid19_portfolio.covid19_deaths
-- where location = 'Poland'
order by 1,2


-- Sub query - When at least 1% of population in Poland was infected 

select location, date, PercentPopulationInfected
from(
	select location, date, total_cases, population, (total_cases /population)*100 as PercentPopulationInfected
	from covid19_portfolio.covid19_deaths
	where location = 'Poland'
	order by 1,2
	)  alias
where PercentPopulationInfected >= 1
limit 1

-- Looking at countries with highest infection rate compared to population

select location , population ,max( total_cases ) as HighestInfectionCount , max( (total_cases /population)*100) as PercentPopulationInfected
from covid19_portfolio.covid19_deaths
-- where location = 'Poland'
group by location , population 
order by PercentPopulationInfected desc 

-- Showing countries with highest death count per population


--
select location , max(total_deaths) as TotalDeathCount
from covid19_portfolio.covid19_deaths
where continent is not null
group by location 
order by TotalDeathCount desc 

-- Let`s break things down by continent

select continent , max(total_deaths) as TotalDeathCount
from covid19_portfolio.covid19_deaths
-- where location = 'Poland'
where continent is not null 
group by  continent
order by TotalDeathCount desc 

-- GLOBAL NUMBERS 

 select date, sum(new_cases ) as total_cases , sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentageAcrossWorld
 from covid19_portfolio.covid19_deaths
 where continent is not null
group by date 
order by 1,2

-- GLOBAL numbers on September 2023 overall across the world

 select sum(new_cases ) as total_cases , sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentageAcrossWorld
 from covid19_portfolio.covid19_deaths
 where continent is not null
order by 1,2


-- Vaccination table

select * 
from covid19_portfolio.covid19_vaccinations cv 
limit 20

-- Looking at population vs vaccination

select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations 
from covid19_portfolio.covid19_deaths dea
join covid19_portfolio.covid19_vaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null 
-- and where dea.location = 'Poland'
order by 1,2,3

select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from covid19_portfolio.covid19_deaths dea
	join covid19_portfolio.covid19_vaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

-- USE CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as (
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from covid19_portfolio.covid19_deaths dea
	join covid19_portfolio.covid19_vaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- and dea.location = 'Cuba'
order by 1,2,3
)
select * , (TotalPeopleVaccinated/population)*100 as PercentageOfVaccinatedPeople
from PopvsVac

-- same result with TEMP TABLE

drop table if exists PercentageOfVaccinated
create table PercentageOfVaccinated
(
continent varchar(50),
location varchar(50),
date date,
population double,
new_vaccinations varchar(50),
TotalPeopleVaccinated double
)

insert into PercentageOfVaccinated
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from covid19_portfolio.covid19_deaths dea
	join covid19_portfolio.covid19_vaccinations vac
	on dea.location  = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 1,2,3

select *, (totalpeoplevaccinated / population)*100 as percentageofpeoplevacc
from percentageofvaccinated p 


-- First vaccinations for covid19 

select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations 
from covid19_portfolio.covid19_deaths dea
join covid19_portfolio.covid19_vaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations !=0
-- and dea.location = 'Poland'
order by 3

-- Creating view to store data for late viz

create view FirstVaccination as 
select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations 
from covid19_portfolio.covid19_deaths dea
join covid19_portfolio.covid19_vaccinations vac
on dea.location  = vac.location
and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations !=0
-- and dea.location = 'Poland'
order by 3

create view DeathPercentageAcrossTheWorld as
 select sum(new_cases ) as total_cases , sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentageAcrossWorld
 from covid19_portfolio.covid19_deaths
 where continent is not null
order by 1,2





