/*
Chemicals in Cosmetics Dataset  Exploration 
Skills used: Joins, CTE's, Aggregate Functions, Creating Views
*/

---- Q1. Find out which chemicals were used the most in cosmetics and personal care products.

WITH CHEMICAL_USED
AS
(
SELECT DISTINCT
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalName, 
	New_project.dbo.[chemicals-in-cosmetics-].PrimaryCategory,	
	New_project.dbo.[chemicals-in-cosmetics-].SubCategory
FROM New_project.dbo.[chemicals-in-cosmetics-3]
INNER JOIN New_project.dbo.[chemicals-in-cosmetics-] 
	ON  New_project.dbo.[chemicals-in-cosmetics-].ChemicalName = New_project.dbo.[chemicals-in-cosmetics-3].ChemicalName
)
SELECT ChemicalName, COUNT(ChemicalName) AS Chemical_Appearance
FROM CHEMICAL_USED
GROUP BY ChemicalName
ORDER BY 2 DESC;

----q2. Find out which companies used the most reported chemicals in their cosmetics and personal care products.

WITH Chemical_Company_Usage
AS
(
SELECT DISTINCT
	New_project.dbo.[chemicals-in-cosmetics-].CompanyName,
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalName, 
	New_project.dbo.[chemicals-in-cosmetics-].PrimaryCategory,	
	New_project.dbo.[chemicals-in-cosmetics-].SubCategory
FROM New_project.dbo.[chemicals-in-cosmetics-3]
INNER JOIN New_project.dbo.[chemicals-in-cosmetics-] 
	ON  New_project.dbo.[chemicals-in-cosmetics-].ChemicalName = New_project.dbo.[chemicals-in-cosmetics-3].ChemicalName
)
SELECT CompanyName, COUNT(ChemicalName) AS Chemicals_reported
FROM Chemical_Company_Usage
GROUP BY CompanyName
ORDER BY 2 DESC;

--or with second logic using titanium dioxide been the most reported chemicals
WITH Chemical_Company_Usage
AS
(
SELECT DISTINCT
	New_project.dbo.[chemicals-in-cosmetics-].CompanyName,
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalName, 
	New_project.dbo.[chemicals-in-cosmetics-].PrimaryCategory,	
	New_project.dbo.[chemicals-in-cosmetics-].SubCategory
FROM New_project.dbo.[chemicals-in-cosmetics-3]
INNER JOIN New_project.dbo.[chemicals-in-cosmetics-] 
	ON  New_project.dbo.[chemicals-in-cosmetics-].ChemicalName = New_project.dbo.[chemicals-in-cosmetics-3].ChemicalName
)
SELECT  CompanyName, ChemicalName, COUNT(ChemicalName) AS Chemicals_reported
FROM Chemical_Company_Usage
WHERE ChemicalName LIKE '%Titanium dioxide%'
GROUP BY CompanyName, ChemicalName
ORDER BY 3 DESC;

----Q3. Which brands had chemicals that were removed and discontinued? Identify the chemicals.

WITH Chemical_Removed_and_discontinued
AS
(
SELECT DISTINCT
	New_project.dbo.[chemicals-in-cosmetics-].CompanyName,
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalName,	
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalDateRemoved,
	New_project.dbo.[chemicals-in-cosmetics-].DiscontinuedDate
FROM New_project.dbo.[chemicals-in-cosmetics-3]
INNER JOIN New_project.dbo.[chemicals-in-cosmetics-] 
	ON  New_project.dbo.[chemicals-in-cosmetics-].ChemicalId = New_project.dbo.[chemicals-in-cosmetics-3].ChemicalId
)
SELECT *
FROM Chemical_Removed_and_discontinued
WHERE (DiscontinuedDate is not NULL) AND (ChemicalDateRemoved is not NULL)
ORDER BY 1;

--Q4. Identify the brands that had chemicals which were mostly reported in 2018.

WITH Chemical_Reported
AS
(
SELECT DISTINCT
	New_project.dbo.[chemicals-in-cosmetics-].CompanyName,
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalName,	
	New_project.dbo.[chemicals-in-cosmetics-].InitialDateReported,
	New_project.dbo.[chemicals-in-cosmetics-].MostRecentDateReported
FROM New_project.dbo.[chemicals-in-cosmetics-3]
INNER JOIN New_project.dbo.[chemicals-in-cosmetics-] 
	ON  New_project.dbo.[chemicals-in-cosmetics-].ChemicalId = New_project.dbo.[chemicals-in-cosmetics-3].ChemicalId
)
SELECT *
FROM Chemical_Reported
WHERE (InitialDateReported LIKE '%2018%') AND (MostRecentDateReported LIKE '%2018%')
ORDER BY 2 DESC;

--Q5. Can you tell if discontinued chemicals in bath products were removed. 

SELECT 
	DISTINCT ChemicalName, PrimaryCategory,DiscontinuedDate, ChemicalDateRemoved
FROM New_project.dbo.[chemicals-in-cosmetics-]
WHERE (PrimaryCategory LIKE '%bath products%') AND (DiscontinuedDate is not null)
order by 3
WITH Discontinued_Bath_Product_Chemicals
AS
(
SELECT DISTINCT
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalName, 
	New_project.dbo.[chemicals-in-cosmetics-].PrimaryCategory,	
	New_project.dbo.[chemicals-in-cosmetics-].DiscontinuedDate,
	New_project.dbo.[chemicals-in-cosmetics-].ChemicalDateRemoved
FROM New_project.dbo.[chemicals-in-cosmetics-3]
INNER JOIN New_project.dbo.[chemicals-in-cosmetics-] 
	ON  New_project.dbo.[chemicals-in-cosmetics-].ChemicalName = New_project.dbo.[chemicals-in-cosmetics-3].ChemicalName
)
SELECT ChemicalName, PrimaryCategory, DiscontinuedDate, ChemicalDateRemoved,
      CASE
      WHEN ChemicalDateRemoved is NULL THEN 'Not_Removed' ELSE 'Removed'
	  END AS Removed_or_Not
FROM Discontinued_Bath_Product_Chemicals
WHERE (PrimaryCategory LIKE '%bath products%') AND (DiscontinuedDate is not null) 
ORDER BY 2;


--Q6. How long were removed chemicals in baby products used? (Tip: Use creation date to tell)

SELECT PrimaryCategory, ChemicalName, ChemicalCreatedAt, ChemicalDateRemoved, cast(DATEDIFF(M,ChemicalCreatedAt,ChemicalDateRemoved)/12 as varchar) + ' years ' +
		cast(DATEDIFF(M,ChemicalCreatedAt,ChemicalDateRemoved)%12  as varchar) + ' months ' +
		cast(DATEPART(d, ChemicalDateRemoved) - DATEPART(d, ChemicalCreatedAt) as varchar) + ' days' as Time_Diffrence
FROM New_project.dbo.[chemicals-in-cosmetics-]
WHERE (PrimaryCategory LIKE '%baby products%') AND (ChemicalDateRemoved is not null)
ORDER BY 3
