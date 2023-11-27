-- -- 
-- Covid19 Vaccination
--
--
-- 1. Quick look at Poland
select 	location, 
		population ,
		cast(max(total_cases) as double) as TotalCases, 
		cast((max(total_cases) / population )*100 as double) as PercentOfPopulationInfected, 
		cast(max(total_deaths) as double) as TotalDeathCount, 
		cast(round(( max(total_deaths) / population )*100,4) as double) as PercentOfPopulationDead
from covid19_portfolio.covid19_deaths
where continent ='Europe' and location = 'Poland'
group by 1,2 
order by TotalDeathCount desc 

-- 2. Total deaths in Poland 

select 	location, 
		population, 
		cast(max(total_deaths) as double) as TotalDeaths
from covid19_deaths 
where location = 'Poland'
group by 1,2

--  3. Covid19 Vaccination vs Date/ New Vaccination/ ROling Vaccination/ Pople with one dose/ People vaccinated

select 	location, 
		date, 
		cast(new_vaccinations as double) as NewVaccinations,
		sum(new_vaccinations) over(partition by location order by location, date) as RollingVaccination,
		cast(total_vaccinations as double) as TotalVaccination, 
		cast((people_vaccinated/population)*100 as double) as PERCPeopfleVaccinatedWithAtLeastOneDose , 
		cast((people_fully_vaccinated/population)*100 as double) as PERCPeopleVullyVaccinated 
from covid19_vaccinations cv 


-- 4. Daily new cases and vaccination per day

select dea.location,
		dea.date,
		vac.population,
		dea.new_cases,
		sum(vac.new_vaccinations) over(partition by vac.location order by vac.location, vac.date) as RollingVaccination
from covid19_deaths as dea
join covid19_vaccinations as vac on dea.location = vac.location and dea.date = vac.date
where dea.location = 'Poland'


-- 5. Vaccination on each continent
select location,
		continent,
		cast(max(people_vaccinated/population)*100 as double) as PERCPeopleVaccinatedWithAtLeastOneDose , 
		cast(max(people_fully_vaccinated/population)*100 as double) as PERCPeopleVullyVaccinated 
from covid19_vaccinations
-- where continent = 'Europe' 
where continent = 'Asia'
-- and location = ''
group by 2,1


-- 6. Death count vs vaccination 
with death_vacc as
(
	select dea.location,
			dea.date,
			dea.population,
	-- 		total_deaths,
-- 			dea.new_deaths,
			cast(vac.people_vaccinated as double) as people_vac_with_one_dose,
			sum(dea.new_deaths) over(partition by dea.location order by dea.location, dea.date) as rolling_deaths,
			sum(vac.new_vaccinations) over(partition by vac.location order by vac.location, vac.date) as rollingVaccination
	from covid19_deaths as dea
	join covid19_vaccinations as vac on dea.location = vac.location and dea.date = vac.date
-- 	where dea.location = 'Poland'
)
select location,
		date, 
		((rolling_deaths/population)*100) as perc_of_population_deaths, 
		((people_vac_with_one_dose/population)*100) as perc_vacc_with_onde_dose
from death_vacc
-- order by perc_of_population_deaths desc 

	


		


