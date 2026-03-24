# Oracle HCM Talent Review Detailed Report

## Overview

This repository contains the SQL query and documentation for a **BI Publisher (BIP) report developed in Oracle HCM Cloud** to extract detailed talent review meeting data.

The report provides a comprehensive view of employee talent review outcomes including 9-box ratings, performance and potential ratings, meeting details, manager hierarchy, and facilitator notes.

This solution demonstrates advanced reporting using Oracle HCM Talent Management and Performance data structures.

---

## Technology Stack

* Oracle HCM Cloud
* Oracle BI Publisher (BIP)
* Oracle SQL

---

## Report Objective

The objective of this report is to provide HR and leadership teams with **deep insights into talent review discussions and employee potential assessment**.

The report enables organizations to:

* Analyze talent review meeting outcomes
* Track performance and potential ratings
* Identify high-potential employees
* Review facilitator notes and discussions
* Understand organizational talent distribution

---

## Key Data Extracted

### Employee Information

* Employee Name
* Person Number
* Assignment Number
* Assignment Status
* Work Email

---

### Talent Review Meeting Details

* Meeting Title
* Meeting Date
* Meeting Status
* Meeting Owner
* Business Leader

---

### Talent Ratings

* Performance Rating (PTA Rating)
* Potential Rating
* Talent Readiness
* 9-Box / N-Box Rating

---

### High Potential Identification

* High Potential Flag (Y/N based on rating)

---

### Organizational Information

* Business Group
* Business Unit
* Department
* Legal Employer
* Location
* Country
* World Area

---

### Job Information

* Job Name
* Job Family
* Job Function
* Contributor Type
* Organization Level

---

### Manager Hierarchy

* Line Manager Name & ID
* Manager Assignment Number
* Manager Email Address

---

### Facilitator Notes

* Meeting Notes (HTML cleaned)
* Note Creator Name
* Note Creator ID

---

## Oracle HCM Tables Used

### Talent Review & Performance

* HRR_DASHBOARDS
* HRR_MEETINGS
* HRT_PROFILES_B
* HRT_PROFILE_ITEMS
* HRT_RATING_LEVELS_TL

---

### Employee Core Data

* PER_ALL_PEOPLE_F
* PER_PERSON_NAMES_F
* PER_ALL_ASSIGNMENTS_M
* PER_PERIODS_OF_SERVICE

---

### Manager Hierarchy

* PER_MANAGER_HRCHY_DN
* PER_ASSIGNMENT_SUPERVISORS_F

---

### Organizational Data

* HR_ALL_ORGANIZATION_UNITS
* HR_LOCATIONS_ALL
* PER_JOBS_F_VL
* PER_JOB_FAMILY_F_VL

---

### Supporting Tables

* PER_EMAIL_ADDRESSES
* HR_LOOKUPS
* FND_LOOKUP_VALUES_VL
* FF_USER_TABLES_VL
* FF_USER_ROWS_VL
* HRT_NOTES

---

## Query Logic Highlights

### Talent Ratings Extraction

The report extracts ratings using:

* HRT_PROFILE_ITEMS
* HRT_RATING_LEVELS_TL

This includes:

* Performance Rating
* Potential Rating
* Talent Readiness
* 9-box placement

---

### 9-Box / N-Box Mapping

The query retrieves **N-box cell assignment** using:

Profile content type:
'N BOX CELL ASSIGNMENT'

---

### High Potential Logic

Employees are marked as **High Potential** if they fall into:

* High Performance + High Potential categories

---

### Facilitator Notes Processing

The query cleans HTML notes using:

* REGEXP_REPLACE
* DBMS_LOB.SUBSTR

This converts rich text notes into readable plain text.

---

### Manager Hierarchy

Manager details are retrieved using:

* Functional Manager
* Line Manager

via:

PER_MANAGER_HRCHY_DN

---

### Organizational Mapping

Custom mappings are derived using:

* User Defined Tables (UDT)
* World Area mapping

---

### Security

The report enforces Oracle HCM security using:

PER_PERSON_SECURED_LIST_V

---

## Key Features

* Provides detailed talent review insights
* Displays 9-box / N-box talent ratings
* Identifies high-potential employees
* Extracts and cleans facilitator notes
* Includes full organizational hierarchy
* Supports dynamic parameter filtering
* Combines performance and talent data

---

## Parameters Supported

The report supports filtering using:

* Meeting Status
* Review Year
* Business Unit
* Department
* Legal Employer
* Location
* Employee Name
* Manager Name
* Meeting Leader

---

## Use Cases

* Talent review analysis
* Leadership decision-making
* Succession planning
* Identifying high-potential employees
* Reviewing meeting discussions

---

## Learning Outcomes

This report demonstrates:

* Oracle HCM Talent Review data model
* Performance and talent integration
* Advanced SQL techniques
* BI Publisher reporting
* HTML data cleansing in SQL
* Manager hierarchy handling

---

## Author

Saurabh Mharolkar
Oracle HCM Developer

---

## License

This project is licensed under the MIT License.

