# 🏦 Bank Loan Approval & Performance Tracking System 

## Project Overview

This project is an **industry‑ready database and analytics solution** designed to simulate how banks evaluate, approve, and monitor loan applications. It focuses on **data quality, business‑driven SQL analysis, and performance optimization**, closely aligning with real‑world banking and fintech use cases.

The system ingests raw loan application data, performs **professional data cleaning**, enforces **business constraints**, and generates **actionable insights** to support loan approval and credit risk decisions.

---

## Business Problem
This project addresses these challenges by building a **clean, reliable, and insight‑driven loan analytics database** that answers real business questions such as:

* Which applicants are most likely to get approved?
* How does credit history impact approval rates?
* Which regions and customer profiles are safest for lending?

---

## Dataset Description

Source: Kaggle – Loan Prediction Dataset
🔗 [https://www.kaggle.com/datasets/altruistdelhite04/loan-prediction-problem-dataset](https://www.kaggle.com/datasets/altruistdelhite04/loan-prediction-problem-dataset)

The dataset represents **bank loan applications**, containing applicant demographics, income details, credit history, loan attributes, and approval status.

### Key Columns

* `loan_id` – Unique loan identifier
* `gender`, `married`, `dependents` – Applicant demographics
* `education`, `self_employed` – Socio‑economic indicators
* `applicantincome`, `coapplicantincome` – Financial capacity
* `loanamount`, `loan_amount_term` – Loan details
* `credit_history` – Creditworthiness indicator (0 / 1)
* `property_area` – Urban / Semiurban / Rural
* `loan_status` – Approved (Y) or Rejected (N)

 *The dataset intentionally contains missing values and inconsistencies to reflect real‑world banking data.*

---

## Database Architecture

### Core Table

* **`loan_staging`** – Central fact table holding cleaned loan application data

### Normalized Tables (Demonstration)

* **`customers`** – Applicant‑level attributes
* **`loans`** – Loan‑level financial attributes

### Design Highlights

* Primary keys for **data integrity**
* `CHECK` constraints to **enforce business rules**
* Indexes for **performance optimization**
* Views for **reporting and analytics layers**

---

##  Data Cleaning & Preparation Strategy

Professional data preparation techniques were applied, similar to production systems:

### Missing Values Handling

* **Categorical columns** → Mode imputation
* **Numerical columns** → Average imputation

### Standardization

* Normalized dependent values (e.g., `3+ → 3`)

### Deduplication

* Removed duplicate `loan_id` records using PostgreSQL system columns

### Data Validation

* Enforced non‑negative income and loan values
* Restricted valid values for `credit_history` and `loan_status`

✔ Ensures the dataset is **analysis‑ready, reliable, and business‑safe**

---

## SQL Concepts Demonstrated 

This project intentionally covers **SQL skills commonly tested in interviews**:

* ✅ DDL & Constraints (`PRIMARY KEY`, `CHECK`)
* ✅ Data Cleaning with `UPDATE` & subqueries
* ✅ Data Exploration (`COUNT`, `MIN`, `MAX`, `AVG`)
* ✅ Advanced Aggregations & `CASE` statements
* ✅ Joins & Normalized Schema Design
* ✅ Subqueries (correlated & non‑correlated)
* ✅ Views for reporting layers
* ✅ Indexing for query performance
* ✅ Transactions demonstrating **ACID properties**

---

## Business Insights Generated

The analysis answers **real banking decision‑making questions**, including:

* Income groups with the highest loan approval rates
* Impact of credit history on approval probability
* Safest property areas for lending
* Approval trends for self‑employed vs salaried applicants
* Ideal loan amount and term ranges
* Identification of high‑risk applicant profiles

Insights are written from a **business analyst’s perspective**, not just SQL outputs.

---

## Tech Stack

* **Database:** PostgreSQL
* **Language:** SQL
* **Concepts:** Data Cleaning, Analytics, Indexing, Transactions
* **Domain:** Banking & Financial Services

---

## Future Enhancements

* Predictive modeling using **SQL + Python**
* Role‑based access control for production simulation
* Loan default risk scoring

---

## 👤 Author

**Krupali Dhangar**
B.Tech | 3rd Year IT Student
