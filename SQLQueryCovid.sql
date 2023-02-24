SELECT * FROM
Portfolioproject.dbo.CoviddeathsClean$
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT * FROM
Portfolioproject.dbo.CovidVaccinationclean$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portfolioproject.dbo.CoviddeathsClean$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases Vs Total deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS percentage_deaths
FROM Portfolioproject.dbo.CoviddeathsClean$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Likelihood of dying of Covid in our counrty
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS percentage_deaths
FROM Portfolioproject.dbo.CoviddeathsClean$
Where location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--Total cases Vs Population and finding what percentage of the population has Covid in our country
SELECT location,date,population,total_cases,(total_cases/population)*100 AS percentage_covid
FROM Portfolioproject.dbo.CoviddeathsClean$
Where location LIKE '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--Finding out the highest Covid infection rate Countrywise
SELECT location,population,MAX(total_cases) AS highest_covidcases,MAX((total_cases/population))*100 AS highest_percentage_covid
FROM Portfolioproject.dbo.CoviddeathsClean$
--Where location LIKE '%states%'
 WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY highest_percentage_covid desc

--Finding the highest number of deaths countrywise due to Covid
SELECT location,MAX(CAST(total_deaths AS INT)) AS highest_coviddeaths,MAX((total_deaths/population))*100 AS highest_percentage_coviddeath
FROM Portfolioproject.dbo.CoviddeathsClean$
--Where location LIKE '%states%'
 WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY highest_percentage_coviddeath desc

--Finding the death statistics due to Covid Continent wise
SELECT continent,MAX(CAST(total_deaths AS INT)) AS highest_coviddeaths,MAX((total_deaths/population))*100 AS highest_percentage_coviddeath
FROM Portfolioproject.dbo.CoviddeathsClean$
--Where location LIKE '%states%'
 WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_percentage_coviddeath desc

--Latest Covid cases and deaths due to it.
SELECT SUM(new_cases) AS latest_cases, SUM(CAST(new_deaths AS INT)) AS latest_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS latest_deathpercentage
FROM Portfolioproject.dbo.CoviddeathsClean$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT Codeath.continent,Codeath.location,Codeath.date,Codeath.population,Covacc.new_vaccinations,SUM(CAST(new_vaccinations as INT))
OVER(PARTITION BY Codeath.location ORDER BY Codeath.location,Codeath.date) AS rolling_totalVacc
FROM Portfolioproject.dbo.CoviddeathsClean$ AS Codeath
JOIN Portfolioproject.dbo.CovidVaccinationclean$ AS Covacc
ON Codeath.location=Covacc.location
AND Codeath.date=Covacc.date
WHERE Codeath.continent IS NOT NULL
ORDER BY 2,3

--Creating CTE
WITH popVsvac (continent, location, date, population, new_vaccinations, rolling_totalVacc)
AS (
SELECT Codeath.continent,Codeath.location,Codeath.date,Codeath.population,Covacc.new_vaccinations,SUM(CAST(new_vaccinations as INT))
OVER(PARTITION BY Codeath.location ORDER BY Codeath.location,Codeath.date) AS rolling_totalVacc
FROM Portfolioproject.dbo.CoviddeathsClean$ AS Codeath
JOIN Portfolioproject.dbo.CovidVaccinationclean$ AS Covacc
ON Codeath.location=Covacc.location
AND Codeath.date=Covacc.date
WHERE Codeath.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * 
FROM popVsvac

--Creating a Temp Table 
DROP TABLE IF EXISTS #PercentpopVacc
CREATE TABLE #Percentpopvacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_totalVacc numeric
)
INSERT INTO #Percentpopvacc
SELECT Codeath.continent,Codeath.location,Codeath.date,Codeath.population,Covacc.new_vaccinations,SUM(CAST(new_vaccinations as INT))
OVER(PARTITION BY Codeath.location ORDER BY Codeath.location,Codeath.date) AS rolling_totalVacc
FROM Portfolioproject.dbo.CoviddeathsClean$ AS Codeath
JOIN Portfolioproject.dbo.CovidVaccinationclean$ AS Covacc
ON Codeath.location=Covacc.location
AND Codeath.date=Covacc.date
WHERE Codeath.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(rolling_totalVacc/population)*100
FROM #Percentpopvacc
WHERE location='Albania'

--Creating Views for data storage
CREATE VIEW Covideathconview AS
SELECT continent,MAX(CAST(total_deaths AS INT)) AS highest_coviddeaths,MAX((total_deaths/population))*100 AS highest_percentage_coviddeath
FROM Portfolioproject.dbo.CoviddeathsClean$
--Where location LIKE '%states%'
 WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY highest_percentage_coviddeath desc

CREATE VIEW Percentpopvaccview AS
SELECT Codeath.continent,Codeath.location,Codeath.date,Codeath.population,Covacc.new_vaccinations,SUM(CAST(new_vaccinations as INT))
OVER(PARTITION BY Codeath.location ORDER BY Codeath.location,Codeath.date) AS rolling_totalVacc
FROM Portfolioproject.dbo.CoviddeathsClean$ AS Codeath
JOIN Portfolioproject.dbo.CovidVaccinationclean$ AS Covacc
ON Codeath.location=Covacc.location
AND Codeath.date=Covacc.date
WHERE Codeath.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM Percentpopvaccview

SELECT * FROM Covideathconview