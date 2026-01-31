--Drop Table if Exist
drop table if exists loan_staging;


-- Create database
CREATE DATABASE loan_staging;

--create table
CREATE TABLE loan_staging (
    loan_id TEXT PRIMARY KEY,
    gender TEXT,
    married TEXT,
    dependents INT,
    education TEXT,
    self_employed TEXT,
    applicantincome INT CHECK (applicantincome >= 0),
    coapplicantincome INT DEFAULT 0 CHECK (coapplicantincome >= 0),
    loanamount INT,
    loan_amount_term INT,
    credit_history INT CHECK (credit_history IN (0,1)),
    property_area TEXT,
    loan_status TEXT CHECK (loan_status IN ('Y','N'))
);

--print data
SELECT * FROM loan_staging LIMIT 5;

--data exploration
--count of rows

select count(*) from loan_staging;

--select null values 

select * from loan_staging
where loan_id is null
or 
gender is null
or
married is null
or
dependents is null
or 
education is null
or
self_employed is null
or 
applicantincome is null
or 
coapplicantincome is null
or
loanamount is null
or 
loan_amount_term is null
or
credit_history is null
or
property_area is null
or 
loan_status is null

--clean gender

UPDATE loan_staging
SET gender = (
    SELECT gender
    FROM loan_staging
    WHERE gender IS NOT NULL
    GROUP BY gender
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE gender IS NULL;

--clean married

UPDATE loan_staging
SET married = (
    SELECT married
    FROM loan_staging
    WHERE married IS NOT NULL
    GROUP BY married
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE married IS NULL;

--clean dependents

UPDATE loan_staging
SET dependents = (
    SELECT dependents
    FROM loan_staging
    WHERE dependents IS NOT NULL
    GROUP BY dependents
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE dependents IS NULL;

--clean self_employed

UPDATE loan_staging
SET self_employed = (
    SELECT self_employed
    FROM loan_staging
    WHERE self_employed IS NOT NULL
    GROUP BY self_employed
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE self_employed IS NULL;

--clean loanAmount(Avg)

UPDATE loan_staging
SET loanamount = (
    SELECT ROUND(AVG(loanamount))
    FROM loan_staging
    WHERE loanamount IS NOT NULL
)
WHERE loanamount IS NULL;

--clean loan_amount_term

UPDATE loan_staging
SET loan_amount_term = (
    SELECT loan_amount_term
    FROM loan_staging
    WHERE loan_amount_term IS NOT NULL
    GROUP BY loan_amount_term
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE loan_amount_term IS NULL;

--clean crdit_history

UPDATE loan_staging
SET credit_history = (
    SELECT credit_history
    FROM loan_staging
    WHERE credit_history IS NOT NULL
    GROUP BY credit_history
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
WHERE credit_history IS NULL;

--check after cleaning
SELECT
    COUNT(*) FILTER (WHERE gender IS NULL) AS gender_nulls,
    COUNT(*) FILTER (WHERE married IS NULL) AS married_nulls,
    COUNT(*) FILTER (WHERE dependents IS NULL) AS dependents_nulls,
    COUNT(*) FILTER (WHERE self_employed IS NULL) AS self_employed_nulls,
    COUNT(*) FILTER (WHERE loanamount IS NULL) AS loanamount_nulls,
    COUNT(*) FILTER (WHERE loan_amount_term IS NULL) AS term_nulls,
    COUNT(*) FILTER (WHERE credit_history IS NULL) AS credit_history_nulls
FROM loan_staging;

--Standardize Dependents
UPDATE loan_staging
SET dependents = '3'
WHERE dependents = '3+';

--Remove Duplicate Loan IDs
DELETE FROM loan_staging
WHERE loan_id IN (
    SELECT loan_id
    FROM loan_staging
    GROUP BY loan_id
    HAVING COUNT(*) > 1
)
AND ctid NOT IN (
    SELECT MIN(ctid)
    FROM loan_staging
    GROUP BY loan_id
);


--DATA EXPLORATION

-- Total number of loan applications
SELECT COUNT(*) AS total_loans
FROM loan_staging;

-- Approved vs Rejected loans
SELECT DISTINCT loan_status
FROM loan_staging;

-- Minimum, Maximum and Average applicant income
SELECT 
    MIN(applicantincome) AS min_income,
    MAX(applicantincome) AS max_income,
    ROUND(AVG(applicantincome), 2) AS avg_income
FROM loan_staging;


--BASIC SELECT QUERIES

--Approved Loans Only
SELECT *
FROM loan_staging
WHERE loan_status = 'Y';

-- Applicants earning more than 10,000
SELECT loan_id, applicantincome
FROM loan_staging
WHERE applicantincome > 10000
ORDER BY applicantincome DESC;

--Urban Property Applicants
SELECT loan_id, property_area
FROM loan_staging
WHERE property_area = 'Urban'
LIMIT 10;


--AGGREGATE FUNCTIONS

--Loan Approval Rate
SELECT 
    loan_status,
    COUNT(*) AS total_applications
FROM loan_staging
GROUP BY loan_status;

--Average Loan Amount by Education
SELECT 
    education,
    ROUND(AVG(loanamount), 2) AS avg_loan_amount
FROM loan_staging
GROUP BY education;

--Approval by Credit History
SELECT 
    credit_history,
    COUNT(*) AS total_loans
FROM loan_staging
WHERE loan_status = 'Y'
GROUP BY credit_history;


--JOINS (NORMALIZED STRUCTURE)

--Create Customer Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    loan_id VARCHAR(20) UNIQUE,
    gender VARCHAR(10),
    married VARCHAR(10),
    education VARCHAR(20),
    self_employed VARCHAR(10)
);

--Create Loan Table
CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    loanamount NUMERIC CHECK (loanamount > 0),
    loan_amount_term NUMERIC,
    credit_history NUMERIC,
    loan_status CHAR(1)
);

--JOIN Customers & Loans
SELECT 
    c.loan_id,
    c.gender,
    l.loanamount,
    l.loan_status
FROM customers c
INNER JOIN loans l
ON c.loan_id = l.loan_id;


--SUBQUERIES

--Above-Average Loan Amounts
SELECT loan_id, loanamount
FROM loan_staging
WHERE loanamount > (
    SELECT AVG(loanamount)
    FROM loan_staging
);

--Applicants with Highest Income
SELECT loan_id, applicantincome
FROM loan_staging
WHERE applicantincome = (
    SELECT MAX(applicantincome)
    FROM loan_staging
);


--VIEWS (REPORTING LAYER)

--Loan Approval Summary View
CREATE VIEW loan_approval_summary AS
SELECT 
    property_area,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans
FROM loan_staging
GROUP BY property_area;

SELECT * FROM loan_approval_summary;


--INDEXING (PERFORMANCE)

-- Speed up search on loan status
CREATE INDEX idx_loan_status
ON loan_staging(loan_status);

-- Speed up income based analysis
CREATE INDEX idx_applicant_income
ON loan_staging(applicantincome);


--TRANSACTIONS (ACID PROPERTIES)
--commit
BEGIN;

UPDATE loans
SET loan_status = 'Y'
WHERE loan_id = 'LP001002';

COMMIT;

--rollback
BEGIN;

UPDATE loans
SET loanamount = -500
WHERE loan_id = 'LP001002';

ROLLBACK;


---BUSINESS INSIGHTS

--Q.Which applicant income range has the highest loan approval rate?
SELECT 
    CASE
        WHEN applicantincome < 3000 THEN 'Low Income'
        WHEN applicantincome BETWEEN 3000 AND 7000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS income_group,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate_percentage
FROM loan_staging
GROUP BY income_group
ORDER BY approval_rate_percentage DESC;


--Q.Does credit history actually impact loan approval?
SELECT 
    credit_history,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY credit_history;


--Q.Which property area is the safest for lending?
SELECT 
    property_area,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY property_area
ORDER BY approval_rate DESC;


--Q.Do self-employed applicants have lower approval rates?
SELECT 
    self_employed,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY self_employed;


--Q.What is the ideal loan amount range with maximum approvals?
SELECT 
    CASE
        WHEN loanamount < 100 THEN 'Small Loan'
        WHEN loanamount BETWEEN 100 AND 200 THEN 'Medium Loan'
        ELSE 'Large Loan'
    END AS loan_size,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY loan_size
ORDER BY approval_rate DESC;


--Q.Which combination of education + credit history gives the best approval chance?
SELECT 
    education,
    credit_history,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY education, credit_history
HAVING COUNT(*) > 20
ORDER BY approval_rate DESC;

--Q.Which marital status + dependents group has the highest loan approval success?
SELECT 
    married,
    dependents,
    COUNT(*) AS total_applications,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY married, dependents
HAVING COUNT(*) > 10
ORDER BY approval_rate DESC;

--Q.Are graduates more likely to receive higher loan amounts?
SELECT 
    education,
    ROUND(AVG(loanamount), 2) AS avg_loan_amount,
    COUNT(*) AS total_loans
FROM loan_staging
GROUP BY education;

--Q.What loan term duration has the highest approval rate?
SELECT 
    loan_amount_term,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) AS approved_loans,
    ROUND(
        100.0 * SUM(CASE WHEN loan_status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS approval_rate
FROM loan_staging
GROUP BY loan_amount_term
ORDER BY approval_rate DESC;

--Q.Who are the high-risk applicants (low income + no credit history)?
SELECT 
    loan_id,
    applicantincome,
    credit_history,
    loanamount
FROM loan_staging
WHERE applicantincome < 3000
AND credit_history = 0
AND loan_status = 'N';

--Q.Which 3 customer profiles generate the highest approval volume?
SELECT 
    education,
    self_employed,
    property_area,
    COUNT(*) AS approved_loans
FROM loan_staging
WHERE loan_status = 'Y'
GROUP BY education, self_employed, property_area
ORDER BY approved_loans DESC
LIMIT 3;

--Q.Which applicants receive approval despite low income?
SELECT 
    loan_id,
    applicantincome,
    credit_history,
    loanamount,
    property_area
FROM loan_staging
WHERE applicantincome < (
    SELECT AVG(applicantincome) FROM loan_staging
)
AND loan_status = 'Y';





