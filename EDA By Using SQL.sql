USE apeamcet2022;

-- ============================================================================
-- DATA CLEANING / DML STATEMENTS
-- Note: SET SQL_SAFE_UPDATES = 0 if Workbench is in Safe Mode
-- ============================================================================

-- 1. Fix COED typo: GGIRLS -> GIRLS
-- UPDATE apeamcet2022.ranks_cutoff_transformed 
-- SET COED = 'GIRLS' 
-- WHERE COED = 'GGIRLS';

-- 2. Update District Names from abbreviations to full names
-- Example: ATP -> ANANTAPURAMU
-- UPDATE apeamcet2022.ranks_cutoff_transformed 
-- SET District = 'ANANTAPURAMU' 
-- WHERE District = 'ATP';

-- 3. Update Branch Names from abbreviations to full names
-- Example: AGR -> Agricultural Engineering
-- UPDATE apeamcet2022.ranks_cutoff_transformed 
-- SET Branch = 'Agricultural Engineering' 
-- WHERE Branch = 'AGR';

-- ============================================================================
-- DESCRIPTIVE STATISTICS
-- ============================================================================

-- How many colleges
SELECT 
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed;

-- Total branches
SELECT 
  COUNT(DISTINCT Branch) AS Branch_Count
FROM apeamcet2022.ranks_cutoff_transformed;

SELECT DISTINCT Branch
FROM apeamcet2022.ranks_cutoff_transformed
ORDER BY Branch;

-- How many colleges by college type
SELECT 
  College_Type,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY College_Type
ORDER BY College_Count DESC;

-- How many colleges by region
SELECT 
  Region,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY Region
ORDER BY College_Count DESC;

-- How many college types by region
SELECT 
  Region,
  College_Type,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY Region, College_Type
ORDER BY College_Count DESC;

-- How many colleges by district
SELECT 
  District,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY District
ORDER BY College_Count DESC;

-- How many colleges by affiliate university
SELECT 
  Affliate_Univ,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY Affliate_Univ
ORDER BY College_Count DESC;

-- Places with most colleges (Top 5)
SELECT 
  Place,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY Place
ORDER BY College_Count DESC
LIMIT 5;

-- COED colleges count
SELECT 
  COED,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY COED
ORDER BY College_Count DESC;

-- ============================================================================
-- COMPARISONS
-- ============================================================================

-- COED colleges ratio
SELECT 
  COED,
  COUNT(DISTINCT College_Code) AS College_Count
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY COED
ORDER BY College_Count DESC;

-- Colleges by establishment year
SELECT 
  ESTD,
  College_Name,
  College_Type,
  ROUND(AVG(Fee), 2) AS College_Fee
FROM apeamcet2022.ranks_cutoff_transformed
GROUP BY ESTD, College_Name, College_Type
ORDER BY College_Type, College_Fee DESC;

-- ============================================================================
-- RANKING ANALYSIS - BRANCH WISE
-- ============================================================================

-- Average rank by branch
WITH Avg_Rank_By_Branches AS (
  SELECT 
    Branch,
    ROUND(AVG(`Rank`)) AS Avg_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(AVG(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  GROUP BY Branch
  ORDER BY Branch
)
SELECT * 
FROM Avg_Rank_By_Branches;

-- Top ranks by branch
WITH Top_Ranks_By_Branch AS (
  SELECT 
    Branch,
    ROUND(MIN(`Rank`)) AS Top_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(MIN(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  GROUP BY Branch
  ORDER BY Branch
)
SELECT * 
FROM Top_Ranks_By_Branch
WHERE Branch_Rank < 11;

-- Last ranks by branch
WITH Last_Ranks_By_Branch AS (
  SELECT 
    Branch,
    ROUND(MAX(`Rank`)) AS Last_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(MAX(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  GROUP BY Branch
  ORDER BY Branch, Last_Rank DESC
)
SELECT * 
FROM Last_Ranks_By_Branch
WHERE Branch_Rank < 11;

-- ============================================================================
-- RANKING ANALYSIS - BRANCH & GENDER WISE
-- ============================================================================

-- Average rank by gender and branch
WITH Avg_Rank_Boys AS (
  SELECT 
    Branch,
    ROUND(AVG(`Rank`)) AS Boys_Avg_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(AVG(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  WHERE Gender = 'BOYS'
  GROUP BY Branch
  ORDER BY Boys_Avg_Rank
),
Avg_Rank_Girls AS (
  SELECT 
    Branch,
    ROUND(AVG(`Rank`)) AS Girls_Avg_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(AVG(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  WHERE Gender = 'GIRLS'
  GROUP BY Branch
  ORDER BY Girls_Avg_Rank
)
SELECT 
  b.Branch,
  b.Boys_Avg_Rank,
  g.Girls_Avg_Rank
FROM Avg_Rank_Boys b
JOIN Avg_Rank_Girls g USING (Branch);

-- Top rank by gender and branch
WITH Top_Rank_Boys AS (
  SELECT 
    Branch,
    ROUND(MIN(`Rank`)) AS Boys_Top_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(MIN(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  WHERE Gender = 'BOYS'
  GROUP BY Branch
  ORDER BY Boys_Top_Rank
),
Top_Rank_Girls AS (
  SELECT 
    Branch,
    ROUND(MIN(`Rank`)) AS Girls_Top_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(MIN(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  WHERE Gender = 'GIRLS'
  GROUP BY Branch
  ORDER BY Girls_Top_Rank
)
SELECT 
  b.Branch,
  b.Boys_Top_Rank,
  g.Girls_Top_Rank
FROM Top_Rank_Boys b
JOIN Top_Rank_Girls g USING (Branch);

-- Last rank by gender and branch
WITH Last_Rank_Boys AS (
  SELECT 
    Branch,
    ROUND(MAX(`Rank`)) AS Boys_Last_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(MAX(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  WHERE Gender = 'BOYS'
  GROUP BY Branch
  ORDER BY Boys_Last_Rank DESC
),
Last_Rank_Girls AS (
  SELECT 
    Branch,
    ROUND(MAX(`Rank`)) AS Girls_Last_Rank,
    ROW_NUMBER() OVER (ORDER BY ROUND(MAX(`Rank`))) AS Branch_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  WHERE Gender = 'GIRLS'
  GROUP BY Branch
  ORDER BY Girls_Last_Rank DESC
)
SELECT 
  b.Branch,
  b.Boys_Last_Rank,
  g.Girls_Last_Rank
FROM Last_Rank_Boys b
JOIN Last_Rank_Girls g USING (Branch);

-- ============================================================================
-- RANKING ANALYSIS - CATEGORY & BRANCH WISE
-- ============================================================================

-- Average rank by category and branch
WITH Avg_Rank_Category_Branch_Wise AS (
  SELECT 
    Branch,
    Category,
    ROUND(AVG(`Rank`)) AS Avg_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  GROUP BY Branch, Category
  ORDER BY Branch, Avg_Rank
)
SELECT * 
FROM Avg_Rank_Category_Branch_Wise;

-- Top rank by category and branch
WITH Top_Rank_Category_Branch_Wise AS (
  SELECT 
    Branch,
    Category,
    ROUND(MIN(`Rank`)) AS Top_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  GROUP BY Branch, Category
  ORDER BY Branch, Top_Rank
)
SELECT * 
FROM Top_Rank_Category_Branch_Wise;

-- Last rank by category and branch
WITH Last_Rank_Category_Branch_Wise AS (
  SELECT 
    Branch,
    Category,
    ROUND(MAX(`Rank`)) AS Last_Rank
  FROM apeamcet2022.ranks_cutoff_transformed
  GROUP BY Branch, Category
  ORDER BY Branch, Last_Rank DESC
)
SELECT * 
FROM Last_Rank_Category_Branch_Wise;

