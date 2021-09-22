
/* 

Data Exploration Project with COVID 19 data from Our World in Data

Functions and skills used: Aggregate Functions, Joins, Wildcards, Converting Data Types, Window Functions, CTE, Temp Tables  

*/


--Finding the death percentage in each country / Likelyhood of dying in your country if you contract covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio..CovidDeaths
where location= 'India' 
order by 1,2


-- Transmission rate by country

select location, date, population, total_cases, (total_cases/population)*100 as Transmission_rate
from portfolio..CovidDeaths
where location like '%States%' 
order by 1,2


--countries with the highest infection rates 

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_population_infected
from portfolio..CovidDeaths
group by location, population
order by percentage_population_infected desc;


--countries with the highest death count

select location, max(cast(total_deaths as int)) as Total_Death_Count
from portfolio..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc;


--global death percentage (total cases=228M, total deaths= 4.6M, total death percentage= 2.3%)

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Death_Count, (sum(cast(total_deaths as int))/sum(total_cases))*100 as Global_Death_percentage
from portfolio..CovidDeaths
where continent is not null
order by 1;


--Join 

--Percentage of Population taking Covid Vaccines (rolling count using Window functions)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as People_Vaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to find percentage of population vaccinated on each date in a country

With PopulationVsVaccinated (Continent, Location, Date, Population, New_Vaccinations, People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as People_Vaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (People_Vaccinated/Population)*100 as percentage_population_vaccinated
From PopulationVsVaccinated



-- Using Temp Table to to find percentage of population vaccinated on each date in a country

--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as People_Vaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (People_Vaccinated/Population)*100 as percentage_population_vaccinated
From #PercentPopulationVaccinated
