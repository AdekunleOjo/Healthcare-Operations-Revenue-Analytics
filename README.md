# 🏥 Healthcare Operations & Revenue Analytics 

---

## 📊 Overview
This project presents a complete end-to-end healthcare analytics workflow, transforming raw and inconsistent data into actionable business insights.

The analysis focuses on **patient demand, operational performance, and financial efficiency**, with the goal of supporting data-driven decision-making in a healthcare environment.

Focus areas:
- Patient demand  
- Operational efficiency  
- Revenue performance  

---

## 🎯 Problem
Healthcare data was fragmented, inconsistent, and lacked visibility into:
- Patient trends  
- Operational workload  
- Revenue collection performance  

---

## 🧹 Data Cleaning (SQL Server)
- Standardized IDs (PAT, VIS, BILL, MED formats)  
- Converted dates to ISO format  
- Cleaned missing and invalid values  
- Normalized categorical fields  
- Ensured relational integrity across tables  

👉 [View SQL Script](sql/data_cleaning.sql)

---

## 🧩 Data Model
- Patients → Visits (1:M)  
- Patients → Billing (1:M)  
- Visits → Billing (1:M)  
- Visits → Medications (1:M)  

---

## 📊 Dashboard

A 3-page Power BI dashboard answering key business questions:

- **Executive Summary** → Performance & trends  
- **Operational Insights** → Demand & efficiency  
- **Financial Analysis** → Revenue & leakage  

## 📸 Healthcare Operations & Revenue Analytics Dashboard

![Dashboard](image/dashboard_image.png)

---

## 🔍 Key Insights

- Patient demand is steadily increasing  
- Chronic diseases (Diabetes, Hypertension) dominate visits  
- Operations are efficient (low average length of stay)  
- Only ~50% of revenue is collected  
- Significant unpaid and pending revenue → cash flow risk  
- Middle-aged patients drive highest demand  
- Revenue anomaly detected in early 2025  

---

## 📊 Results

- Cleaned and structured real-world dataset  
- Built relational model for analysis  
- Developed executive-level dashboard  
- Identified critical revenue leakage  
- Enabled data-driven decision-making  

---

## 🚀 Recommendations

- Improve billing and collection processes  
- Track and reduce unpaid revenue  
- Optimize operations based on demand trends  
- Strengthen financial monitoring systems  

---

## 🛠 Tools
SQL Server • Power BI • Excel  

---

## 💼 Author
**Adekunle Ojo**  
Data Analyst | Data-Driven Problem Solver
