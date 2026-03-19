-- =====================================
-- Chicago City Payments Analysis
-- Dataset: Chicago Open Data - Payments (date of dataset - 03/09/2026)
-- Analyst: Oleksii Popadynets
-- =====================================

-- Step 1. Dataset Overview

SELECT
COUNT(*) AS total_payments,
COUNT(DISTINCT department_name) AS departments,
COUNT(DISTINCT vendor_name) AS vendors
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`;

-- Results:
-- total_payments: 406592
-- departments: 63
-- vendors: 71447

-- Step 2. Total City Spending

SELECT 
SUM(amount) AS total_spending
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`;

-- Result:
-- Total spending in dataset: $113,526,218,437.72

-- Step 3: Average Payment Size

SELECT
AVG(amount) AS average_payment
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`;

-- Result:
-- Average payment size: $279,214.10

-- Step 4. Top Spending Departments

SELECT
department_name,
SUM(amount) AS total_spent
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`
WHERE department_name IS NOT NULL
GROUP BY department_name
ORDER BY total_spent DESC
LIMIT 10;

-- Key Findings:
-- 1. Chicago Department of Aviation: ~$14.28B
-- 2. Department of Finance: ~$13.01B
-- 3. Department of Transportation: ~$8.32B
-- 4. Department of Water Management: ~$5.84B
-- 5. Department of Family and Support Services: ~$3.88B

-- Step 5. Top Vendors by Payments

SELECT
vendor_name,
SUM(amount) AS total_received
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean` 
GROUP BY vendor_name
ORDER BY total_received DESC
LIMIT 10;

-- Key Findings:
-- 1. Blue Cross & Blue Shield: ~$8.35B
-- 2. Municipal Employee Pension Fund: ~$3.92B
-- 3. Caremark Inc: ~$2.14B
-- 4. Cook County Treasurer: ~$1.90B
-- 5. Policemen's Pension Fund: ~$1.72B

-- Step 6. Vendor concentration analysis

SELECT
vendor_name,
SUM(amount) AS total_received,
ROUND(100 * SUM(amount) / (SELECT SUM(amount)
    FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`), 2) AS percent_of_total_spending
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`
GROUP BY vendor_name
ORDER BY total_received DESC
LIMIT 10;

-- Key Findings:
-- 1. Blue Cross & Blue Shield $8.35B 7.36%
-- 2. Municipal Employee Pension Fund $3.92B 3.46%
-- 3. Caremark Inc $2.14B 1.88%
-- 4. Cook County Treasurer $1.90B 1.67%
-- 5. Policemen’s A & B Pension Fund $1.72B 1.51%

-- Top 5 vendors receive ~15.88% of total city spending.
-- Healthcare providers and pension funds dominate the list,
-- indicating that employee benefits and retirement obligations
-- are major cost drivers in municipal spending.

-- Step 7. Largest Individual Payments

SELECT
vendor_name,
department_name,
amount,
check_date
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean` 
ORDER BY amount DESC
LIMIT 20;

-- Key Findings:
-- 1. Blue Cross & Blue Shield Department of Finance $426,000,671
-- 2. Blue Cross & Blue Shield Department of Finance $388,957,108
-- 3. Blue Cross & Blue Shield Department of Finance $385,701,382
-- 4. Blue Cross & Blue Shield Department of Finance $385,662,383
-- 5. Blue Cross & Blue Shield Department of Finance $383,176,920

-- The largest individual transactions exceed $400M.
-- All top 5 payments were issued by the Department of Finance
-- to Blue Cross & Blue Shield.

-- This suggests large scheduled payments related to
-- municipal employee healthcare benefits.

-- Step 8: Department spending concentration

SELECT 
department_name,
SUM(amount) AS total_spent,
ROUND(100 * SUM(amount) / (SELECT SUM(amount)
   FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean`), 2) AS percent_of_total_spending
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean` 
WHERE department_name IS NOT NULL
GROUP BY department_name
ORDER BY total_spent DESC
LIMIT 10;

-- Key Findings:
-- 1. Chicago Department of Aviation $14.28B 12.58%
-- 2. Department of Finance $13.01B 11.46%
-- 3. Chicago Department of Transportation $8.32B 7.33%
-- 4. Department of Water Management $5.84B 5.15%
-- 5. Department of Family and Support Services $3.88B 3.42%

-- Top 5 departments account for ~39.9% of total city spending.
-- The Chicago Department of Aviation alone represents ~12.6%.
-- This reflects the significant financial scale of airport operations.
--
-- The Department of Finance (~11.5%) likely handles large
-- healthcare and pension-related payments.
--
-- Infrastructure-related departments such as Transportation
-- and Water Management also represent major components of
-- municipal spending.

-- Step 9: Spending trends over time

SELECT  
EXTRACT(YEAR FROM check_date) AS year,
COUNT(*) AS number_of_payments,
SUM(amount) AS total_spent
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean` 
WHERE check_date IS NOT NULL
GROUP BY year
ORDER BY year;

-- Payment activity by year:
-- 2022: 52,079 payments (~$3.60B)
-- 2023: 57,768 payments (~$4.38B)
-- 2024: 41,805 payments (~$4.62B)
-- 2025: 115,835 payments (~$10.66B)
-- 2026: 22,737 payments (~$2.83B, likely incomplete year)

-- Observations:
-- Spending increased steadily between 2022 and 2024.
-- 2025 shows a major spike in both payment volume and total spending.
-- 2026 likely represents partial data for the year.

-- Step 10: Department vendor dependency analysis

SELECT
department_name,
vendor_name,
SUM(amount) AS total_spent
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean` 
WHERE department_name IS NOT NULL
GROUP BY department_name, vendor_name
ORDER BY total_spent DESC
LIMIT 20;

-- Key Findings:
-- 1. Department of Finance Blue Cross & Blue Shield $8.35B
-- 2. Department of Finance Caremark Inc $2.14B
-- 3. Chicago Department of Aviation Austin Power Partners $1.15B
-- 4. Department of Water Management Benchmark Construction Co. Inc $840M
-- 5. Chicago Department of Aviation AOR Transit $712M

-- Identifies which vendors receive the largest payments
-- from individual city departments.
-- This helps reveal supplier dependency relationships.

-- Step 11: Average payment by department

SELECT  
department_name,
COUNT(*) AS number_of_payments,
AVG(amount) AS average_payment,
SUM(amount) AS total_spending
FROM `city-budget-sql-analysis.city_budget_data.chicago_payments_clean` 
WHERE department_name IS NOT NULL
GROUP BY department_name
ORDER BY average_payment DESC
LIMIT 10;

-- Key Findings:
-- Department name				Number of payments	Average Payment		Total spending
-- 1. Department of Finance			1877			$6.93M			$13B
-- 2. Finance General				2			$5.06M			$10M
-- 3. O'Hare modernization project		505			$4.18M			$2.11B
-- 4. Chicago comission on human relations	28			$2.1M			$58.8M
-- 5. Department of revenue			335			$1.44M			$481.9M

-- This analysis identifies which departments issue
-- the largest payments on average, providing insight
-- into operational spending patterns.