/*

Selecting data to be analysed

*/

SELECT location,
	   date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population 
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  order by 1,2


  -------------------------------------------------------------------------------------------------------------------------------------

/*

Checking Total Cases vs Total Deaths for specific location
Show likelihood of dying from Covid

*/

SELECT location,
	   date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 as DeathPercent
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  Where location like '%Ghana%'
  order by 1,2


  -------------------------------------------------------------------------------------------------------------------------------------
/*

Checking Total Cases vs Population
Show percentage of population that contracted Covid

*/

SELECT location,
	   date,
	   total_cases,
	   population,
	   (total_cases/population)*100 as CasesPercent
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  --Where location like '%Ghana%'
  order by 1,2


  -------------------------------------------------------------------------------------------------------------------------------------
  /*

Checking countries with highest infection rates

*/

SELECT location,
	   population,
	   MAX(total_cases) as HighestInfectionCount,
	   MAX((total_cases/population))*100 as PopInfectedPercent
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  --Where location like '%Ghana%'
  group by location, population
  order by PopInfectedPercent desc


  -------------------------------------------------------------------------------------------------------------------------------------
   /*

Checking countries with highest death rates

*/

SELECT location,
	  MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  --Where location like '%Ghana%'
  where continent is not null
  group by location
  order by TotalDeathCount desc


  -------------------------------------------------------------------------------------------------------------------------------------
   /*

Categorize based on continents
Showing highest death count

*/

SELECT location,
	  MAX(cast(total_deaths as int)) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  --Where location like '%Ghana%'
  where continent is not null
  group by location
  order by TotalDeathCount desc



  -------------------------------------------------------------------------------------------------------------------------------------
  /*

Categorize based on global numbers for highest infections

*/

SELECT date,
	   SUM(new_cases) as Cases,
	   SUM(cast(new_deaths as int)) as Deaths,
	   SUM(cast(new_deaths as int))/SUM(new_cases)*100 as NewDeathPercent
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  --Where location like '%Ghana%'
  where continent is not null
  group by date
  order by 1,2



  -------------------------------------------------------------------------------------------------------------------------------------
   /*

Join Tables
Showing Total Population vs Vaccinations

*/

SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
	   order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3


  -------------------------------------------------------------------------------------------------------------------------------------
   /*

Use CTE

*/

With PopsvsVac (continent, location, date, population, New_Vaccinations, RollingVacCount)
as
(
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
	   order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3
)
SELECT *
, (RollingVacCount/population)*100 as PopVacPercent
From PopsvsVac
  -------------------------------------------------------------------------------------------------------------------------------------
    /*

Create Temp Table and insert data

*/
DROP TABLE if exists #PopulationVaccPercent
Create Table #PopulationVaccPercent
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingVacCount NUMERIC
)


Insert into #PopulationVaccPercent
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
	   order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3


SELECT *
, (RollingVacCount/population)*100 as PopVacPercent
From #PopulationVaccPercent

  -------------------------------------------------------------------------------------------------------------------------------------
   /*

Create view to store data 

*/
Create View PopulationVaccPercent as
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   vac.new_vaccinations,
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
	   order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3

Select *
From PopulationVaccPercent
  -------------------------------------------------------------------------------------------------------------------------------------