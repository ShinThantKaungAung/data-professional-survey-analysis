-- Data Cleaning 

SELECT *
FROM survey;

-- create staging table to preserve original raw data
CREATE TABLE survey_staging
LIKE survey
;

INSERT survey_staging
SELECT *
FROM survey
;

SELECT *
FROM survey_staging
;

-- rename Columns
ALTER TABLE survey_staging
RENAME COLUMN `ï»¿Unique ID` TO respondent_id,
RENAME COLUMN `Date Taken (America/New_York)` TO date_taken,
RENAME COLUMN `Time Taken (America/New_York)` TO time_taken,
RENAME COLUMN `Q1 - Which Title Best Fits your Current Role?` TO current_role,
RENAME COLUMN `Q2 - Did you switch careers into Data?` TO career_switch,
RENAME COLUMN `Q3 - Current Yearly Salary (in USD)` TO salary,
RENAME COLUMN `Q4 - What Industry do you work in?` TO industry,
RENAME COLUMN `Q5 - Favorite Programming Language` TO favorite_programming_language,
RENAME COLUMN `Q6 - How Happy are you with Salary` TO salary_happiness,
RENAME COLUMN `Q6 - How Happy are you with Work/Life Balance` TO worklife_balance_happiness,
RENAME COLUMN `Q6 - How Happy are you with Coworker` TO coworker_happiness,
RENAME COLUMN `Q6 - How Happy are you with Management` TO management_happiness,
RENAME COLUMN `Q6 - How Happy are you with Upward Mobility` TO upward_mobility_happiness,
RENAME COLUMN `Q6 - How Happy are you with Learning New Things` TO learning_happiness,
RENAME COLUMN `Q7 - How difficult was it for you to break into Data?` TO difficulty_breaking_into_data,
RENAME COLUMN `Q8 - Most important thing when looking for new work today` TO top_job_priority,
RENAME COLUMN `Q9 - Male/Female?` TO gender,
RENAME COLUMN `Q10 - Current Age` TO age,
RENAME COLUMN `Q11 - Which Country do you live in?` TO residing_country,
RENAME COLUMN `Q12 - Highest Level of Education` TO highest_education,
RENAME COLUMN `Time Spent` TO time_spent,
RENAME COLUMN `Q13 - Ethnicity` TO ethnicity;


-- Check for Duplicates

-- assigning row numbers to check
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
	current_role,
	career_switch,
	salary,
	industry,
	favorite_programming_language,
	salary_happiness,
	worklife_balance_happiness,
	coworker_happiness,
	management_happiness,
	upward_mobility_happiness,
	learning_happiness,
	difficulty_breaking_into_data,
	top_job_priority,
	gender,
	age,
	residing_country,
	highest_education,
	ethnicity
) AS row_num
FROM survey_staging;

-- use cte to query anything > 1
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
	current_role,
	career_switch,
	salary,
	industry,
	favorite_programming_language,
	salary_happiness,
	worklife_balance_happiness,
	coworker_happiness,
	management_happiness,
	upward_mobility_happiness,
	learning_happiness,
	difficulty_breaking_into_data,
	top_job_priority,
	gender,
	age,
	residing_country,
	highest_education,
	ethnicity
) AS row_num
FROM survey_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1
;
-- Checked for duplicate survey responses by comparing all answer columns (Q1-Q13)
-- No duplicate responses were found

-- Standardizing Data

-- change date taken from text type to date type
SELECT date_taken,
STR_TO_DATE(date_taken, '%m/%d/%Y')
FROM survey_staging;

UPDATE survey_staging
SET date_taken = STR_TO_DATE(date_taken, '%m/%d/%Y');

SELECT date_taken
FROM survey_staging;

ALTER TABLE survey_staging
MODIFY COLUMN date_taken DATE;


-- change time taken from text type to time type
SELECT time_taken,
CAST(time_taken AS TIME)
FROM survey_staging;

UPDATE survey_staging
SET time_taken = CAST(time_taken AS TIME);

SELECT time_taken
FROM survey_staging;

ALTER TABLE survey_staging
MODIFY COLUMN time_taken TIME;


-- change time spent from text type to time type
SELECT time_spent,
CAST(time_spent AS TIME)
FROM survey_staging;

ALTER TABLE survey_staging
MODIFY COLUMN time_spent TIME;


-- trim all text columns of whitespace
UPDATE survey_staging
SET current_role = TRIM(current_role),
    career_switch = TRIM(career_switch),
    salary = TRIM(salary),
    industry = TRIM(industry),
    favorite_programming_language = TRIM(favorite_programming_language),
    salary_happiness = TRIM(salary_happiness),
    worklife_balance_happiness = TRIM(worklife_balance_happiness),
    coworker_happiness = TRIM(coworker_happiness),
    management_happiness = TRIM(management_happiness),
    upward_mobility_happiness = TRIM(upward_mobility_happiness),
    learning_happiness = TRIM(learning_happiness),
    difficulty_breaking_into_data = TRIM(difficulty_breaking_into_data),
    top_job_priority = TRIM(top_job_priority),
    gender = TRIM(gender),
    age = TRIM(age),
    residing_country = TRIM(residing_country),
    highest_education = TRIM(highest_education),
    ethnicity = TRIM(ethnicity);
    


-- Standardize current role titles

-- get rid of "Other (Please Specify)"
SELECT current_role, 
	TRIM(REPLACE(current_role, 'Other (Please Specify):', '')) cleaned_role
FROM survey_staging
WHERE current_role LIKE 'Other (Please Specify):%'
;

UPDATE survey_staging
SET current_role = TRIM(REPLACE(current_role, 'Other (Please Specify):', ''))
WHERE current_role LIKE 'Other (Please Specify):%'
;

-- technical consultant
UPDATE survey_staging
SET current_role = 'Technical Consultant'
WHERE current_role LIKE 'Technical consulta'
;

-- data analysts
UPDATE survey_staging
SET current_role = 'Data Analyst'
WHERE current_role LIKE 'Student %'
;

-- software engineers
UPDATE survey_staging
SET current_role = 'Software Engineer'
WHERE current_role LIKE '%software e%'
;

-- supply chain analyst
UPDATE survey_staging
SET current_role = 'Supply Chain Analyst'
WHERE current_role LIKE '%supply%'
;

-- systems configuration
UPDATE survey_staging
SET current_role = 'System Configuration'
WHERE current_role LIKE '%systems%'
;

-- tableau administrator
UPDATE survey_staging
SET current_role = 'Tableau Administrator'
WHERE current_role LIKE 'tableau%'
;

-- software support
UPDATE survey_staging
SET current_role = 'Software Support'
WHERE current_role LIKE 'software support'
;

-- business analysts
UPDATE survey_staging
SET current_role = 'Business Analyst'
WHERE current_role LIKE '%business analyst%'
;

-- sales & marketing
UPDATE survey_staging
SET current_role = 'Sales & Marketing'
WHERE current_role LIKE '%sales &%'
;

-- product owner
UPDATE survey_staging
SET current_role = 'Product Owner'
WHERE current_role LIKE '%product%'
;

-- Turn empty "Other (Please Specify)" into blank
UPDATE survey_staging
SET current_role = ''
WHERE current_role LIKE '%other%'
;

-- bi Managers
UPDATE survey_staging
SET current_role = 'BI Manager'
WHERE current_role LIKE 'manager,%'
;

-- data analytics manager
UPDATE survey_staging
SET current_role = 'Data Analytics Manager'
WHERE current_role LIKE 'manager of%'
;

-- set unclear roles to blank
UPDATE survey_staging
SET current_role = ''
WHERE current_role = 'I work with data tools and can create simple dashboards but I am not a data scientist'
;

-- data scientists
UPDATE survey_staging
SET current_role = 'Data Scientist'
WHERE current_role LIKE '%data scientist%'
;

-- investigation specialist
UPDATE survey_staging
SET current_role = 'Investigation Specialist'
WHERE current_role LIKE '%investigation%'
;

-- insights analyst
UPDATE survey_staging
SET current_role = 'Insights Analyst'
WHERE current_role LIKE '%insights%'
;

-- financial Analyst
UPDATE survey_staging
SET current_role = 'Financial Analyst'
WHERE current_role LIKE '%financ%'
;

-- social media analyst
UPDATE survey_staging
SET current_role = 'Social Media Analyst'
WHERE current_role LIKE '%social%'
;

-- data manager
UPDATE survey_staging
SET current_role = 'Data Manager'
WHERE current_role LIKE '%data manager%'
;

-- fix "Business Analys" into business analysts
UPDATE survey_staging
SET current_role = 'Business Analyst'
WHERE current_role LIKE '%business analys'
;

-- billing analysts
UPDATE survey_staging
SET current_role = 'Billing Analyst'
WHERE current_role LIKE '%billing%'
;

-- bi consultant
UPDATE survey_staging
SET current_role = 'BI Consultant'
WHERE current_role LIKE '%bi consultant%'
;

-- ads operation
UPDATE survey_staging
SET current_role = 'Ads Operation'
WHERE current_role LIKE '%ads%'
;

-- account manager
UPDATE survey_staging
SET current_role = 'Account Manager'
WHERE current_role LIKE '%account%'
;

-- reporting admin
UPDATE survey_staging
SET current_role = 'Reporting Administrator'
WHERE current_role LIKE '%adm'
;

-- database admin
UPDATE survey_staging
SET current_role = 'Database Administrator'
WHERE current_role LIKE '%DBA%'
;

-- researcher
UPDATE survey_staging
SET current_role = 'Researcher'
WHERE current_role LIKE '%researchers'
;

-- power bi developer
UPDATE survey_staging
SET current_role = 'Power BI Developer'
WHERE current_role LIKE '%power%'
;

SELECT current_role, COUNT(*) count_respondents
FROM survey_staging
GROUP BY current_role
ORDER BY 1 DESC;


-- Standardize industry

-- get rid of "Other (Please Specify)"
SELECT industry, 
	TRIM(REPLACE(industry, 'Other (Please Specify):', '')) cleaned_industry
FROM survey_staging
WHERE industry LIKE 'Other (Please Specify):%'
;

UPDATE survey_staging
SET industry = TRIM(REPLACE(industry, 'Other (Please Specify):', ''))
WHERE industry LIKE 'Other (Please Specify):%'
;

-- utilities
UPDATE survey_staging
SET industry = 'Utilities'
WHERE industry LIKE '%util%'
;

-- group unemployed together
UPDATE survey_staging
SET industry = 'Unemployed'
WHERE industry LIKE '%unemp%'
;

UPDATE survey_staging
SET industry = 'Unemployed'
WHERE industry LIKE '%not%'
;

UPDATE survey_staging
SET industry = 'Unemployed'
WHERE industry LIKE '%looking%'
;

-- technology
UPDATE survey_staging
SET industry = 'Technology'
WHERE industry LIKE 'tech%'
;

-- group students
UPDATE survey_staging
SET industry = 'Student'
WHERE industry LIKE '%student%'
;

UPDATE survey_staging
SET industry = 'Student'
WHERE industry LIKE '%boot%'
;

UPDATE survey_staging
SET industry = 'Student'
WHERE industry = 'Currently studying . Previously worked in Power Generation'
;

-- supply chain
UPDATE survey_staging
SET industry = 'Supply Chain'
WHERE industry LIKE '%supply%'
;

-- government
UPDATE survey_staging
SET industry = 'Government'
WHERE industry LIKE '%govern%'
;

UPDATE survey_staging
SET industry = 'Government'
WHERE industry = 'Gover'
;

-- sports
UPDATE survey_staging
SET industry = 'Sports'
WHERE industry LIKE 'sport%'
;

-- social work
UPDATE survey_staging
SET industry = 'Social Work'
WHERE industry = 'Social work'
;

-- retail
UPDATE survey_staging
SET industry = 'Retail'
WHERE industry LIKE '%reta%'
;

-- market research
UPDATE survey_staging
SET industry = 'Market Research'
WHERE industry LIKE '%market research%'
;

-- public transport
UPDATE survey_staging
SET industry = 'Public Transport'
WHERE industry LIKE '%public transport%'
;

-- Turn empty "Other (Please Specify)" into blank
UPDATE survey_staging
SET industry = ''
WHERE industry = 'Other (Please Specify)'
;

-- oil and gas
UPDATE survey_staging
SET industry = 'Oil & Gas'
WHERE industry LIKE '%oil%'
;

-- semiconductor manufacturing
UPDATE survey_staging
SET industry = 'Semiconductor Manufacturing'
WHERE industry LIKE '%semiconductor%'
;

-- research (non-clinical)
UPDATE survey_staging
SET industry = 'Research (Non-Clinical)'
WHERE industry LIKE 'research%'
;

-- set unclear responses to blank
UPDATE survey_staging
SET industry = ''
WHERE industry = 'Cons'
;

-- none
UPDATE survey_staging
SET industry = 'None'
WHERE industry LIKE '%none%'
;

-- non profit
UPDATE survey_staging
SET industry = 'Nonprofit'
WHERE industry LIKE '%nonp%'
OR industry LIKE '%non p%'
;

-- medical industry
UPDATE survey_staging
SET industry = 'Healthcare'
WHERE industry LIKE '%medical%'
;

-- media & advertising
UPDATE survey_staging
SET industry = 'Media & Advertising'
WHERE industry LIKE '%media%'
;

-- chemical manufacturing
UPDATE survey_staging
SET industry = 'Chemical Manufacturing'
WHERE industry LIKE '%chemical%'
;

-- manufacturing
UPDATE survey_staging
SET industry = 'Manufacturing'
WHERE industry LIKE 'manuf%'
;

-- logistics & warehousing
UPDATE survey_staging
SET industry = 'Logistics & Warehousing'
WHERE industry LIKE '%warehousing%'
;

-- last mile delivery logistics
UPDATE survey_staging
SET industry = 'Last Mile Delivery Logistics'
WHERE industry LIKE '%last%'
;

-- science
UPDATE survey_staging
SET industry = 'Science'
WHERE industry = 'Interning in Sciences, Weather and Meteorological data'
;

-- igaming
UPDATE survey_staging
SET industry = 'iGaming'
WHERE industry = 'Igaming'
;

-- hospitality
UPDATE survey_staging
SET industry = 'Hospitality'
WHERE industry LIKE '%hospitality%'
;

-- home & living
UPDATE survey_staging
SET industry = 'Home & Living'
WHERE industry = 'Home and living'
;

-- home maker
UPDATE survey_staging
SET industry = 'Homemaker'
WHERE industry = 'Home maker'
;

-- food & beverage
UPDATE survey_staging
SET industry = 'Food & Beverage'
WHERE industry LIKE '%food %'
;

UPDATE survey_staging
SET industry = 'Food & Beverage'
WHERE industry = 'Beverage and foods'
;

-- fmcg
UPDATE survey_staging
SET industry = 'FMCG'
WHERE industry = 'Fmcg'
;

-- fashion/online store
UPDATE survey_staging
SET industry = 'Fashion/Online Store'
WHERE industry = 'fashion/online store'
;

-- e-commerce
UPDATE survey_staging
SET industry = 'E-commerce'
WHERE industry LIKE '%commerce%'
;

UPDATE survey_staging
SET industry = 'E-commerce'
WHERE industry = 'Ecom'
;

-- digital marketing
UPDATE survey_staging
SET industry = 'Digital Marketing'
WHERE industry LIKE '%digital%'
;

-- demography & social Statistics
UPDATE survey_staging
SET industry = 'Demography & Social Statistics'
WHERE industry LIKE 'Demography and Social Statistics'
;

-- data insights
UPDATE survey_staging
SET industry = 'Data Insights'
WHERE industry = 'Data insights company'
;

-- customer service
UPDATE survey_staging
SET industry = 'Customer Service'
WHERE industry LIKE '%customer%'
;

-- coworking space
UPDATE survey_staging
SET industry = 'Coworking Space'
WHERE industry = 'Coworking space'
;

-- consumer electronics
UPDATE survey_staging
SET industry = 'Consumer Electronics'
WHERE industry LIKE 'Consumer Elec'
;

-- consulting
UPDATE survey_staging
SET industry = 'Consulting'
WHERE industry LIKE '%consult%' OR industry LIKE '%cob%'
;

-- aviation
UPDATE survey_staging
SET industry = 'Aviation'
WHERE industry LIKE '%avia%'
;

-- automotive
UPDATE survey_staging
SET industry = 'Automotive'
WHERE industry LIKE '%auto%'
;

-- air transportation
UPDATE survey_staging
SET industry = 'Air Transportation'
WHERE industry = 'Air transpo'
;

-- aerospace
UPDATE survey_staging
SET industry = 'Aerospace'
WHERE industry = 'Arrosp'
;

-- general contractor
UPDATE survey_staging
SET industry = 'General Contractor'
WHERE industry = 'General contractor'
;

-- ngo
UPDATE survey_staging
SET industry = 'NGO'
WHERE industry = 'NGO - Legislation'
;

-- telecommunications
UPDATE survey_staging
SET industry = 'Telecommunications'
WHERE industry = 'Telecommunication'
;

-- food service 
UPDATE survey_staging
SET industry = 'Food Service'
WHERE industry = 'Foodservice'
;

-- food service franchising
UPDATE survey_staging
SET industry = 'Food Service Franchising'
WHERE industry = 'Foodservice Franchising'
;

SELECT industry, COUNT(*) count_respondents
FROM survey_staging
GROUP BY industry
ORDER BY 1 DESC;



-- Standardize Favorite Programming Language

-- get rid of "Other:"
SELECT favorite_programming_language, 
	TRIM(REPLACE(favorite_programming_language, 'Other:', '')) cleaned_language
FROM survey_staging
WHERE favorite_programming_language LIKE 'Other:%'
;

UPDATE survey_staging
SET favorite_programming_language = TRIM(REPLACE(favorite_programming_language, 'Other:', ''))
WHERE favorite_programming_language LIKE 'Other:%'
;

-- vba
UPDATE survey_staging
SET favorite_programming_language = 'VBA'
WHERE favorite_programming_language LIKE '%vba%'
;

-- set unclear languages to blank
UPDATE survey_staging
SET favorite_programming_language = ''
WHERE favorite_programming_language LIKE '%unknown%'
;

UPDATE survey_staging
SET favorite_programming_language = ''
WHERE favorite_programming_language = 'NA'
;

UPDATE survey_staging
SET favorite_programming_language = ''
WHERE favorite_programming_language = 'Just started learning'
;

UPDATE survey_staging
SET favorite_programming_language = ''
WHERE favorite_programming_language = 'I do analysis and create presentations based on datasets provided by others'
;

-- none
UPDATE survey_staging
SET favorite_programming_language = 'None'
WHERE favorite_programming_language LIKE "%don't%"
OR favorite_programming_language LIKE '%none%'
OR favorite_programming_language = 'I donâ€™t know any'
OR favorite_programming_language = 'I currently do not work with programming languages yet'
OR favorite_programming_language LIKE '%dont%'
;

-- qlik sense script
UPDATE survey_staging
SET favorite_programming_language = 'Qlik Sense Script'
WHERE favorite_programming_language = 'Qlik sense script'
;

-- power bi
UPDATE survey_staging
SET favorite_programming_language = 'Power BI'
WHERE favorite_programming_language = 'Power bi'
;

-- php
UPDATE survey_staging
SET favorite_programming_language = 'PHP'
WHERE favorite_programming_language = 'Php'
;

-- c#
UPDATE survey_staging
SET favorite_programming_language = 'C#'
WHERE favorite_programming_language = 'c#'
;

-- excel
UPDATE survey_staging
SET favorite_programming_language = 'Excel'
WHERE favorite_programming_language = 'Mainly use Excel'
OR favorite_programming_language = 'excel'
;

-- excel/sql
UPDATE survey_staging
SET favorite_programming_language = 'Excel/SQL'
WHERE favorite_programming_language = 'Knowledge of Excel and SQL yet'
;

-- sql
UPDATE survey_staging
SET favorite_programming_language = 'SQL'
WHERE favorite_programming_language = 'Mostly use sql but thatâ€™s not programming language..'
OR favorite_programming_language = 'i mean, i mostly work in SQL and its variants?'
OR favorite_programming_language = 'SQL because that is all I know really well so far.'
OR favorite_programming_language = 'Sql'
OR favorite_programming_language = 'sql'
OR favorite_programming_language LIKE 'If SQL is categorised%'
;

-- postgresql
UPDATE survey_staging
SET favorite_programming_language = 'PostgreSQL'
WHERE favorite_programming_language LIKE '%sql p%'
;

-- alteryx
UPDATE survey_staging
SET favorite_programming_language = 'Alteryx'
WHERE favorite_programming_language = 'Altery'
;

-- sql & pl/sql
UPDATE survey_staging
SET favorite_programming_language = 'SQL & PL/SQL'
WHERE favorite_programming_language = 'Sql &  plsql'
;

SELECT favorite_programming_language, COUNT(*) count_respondents
FROM survey_staging
GROUP BY favorite_programming_language
ORDER BY 1 DESC;



-- Standardize top job priority

-- get rid of "Other (Please Specify)"
SELECT top_job_priority, 
	TRIM(REPLACE(top_job_priority, 'Other (Please Specify):', '')) cleaned_priority
FROM survey_staging
WHERE top_job_priority LIKE 'Other (Please Specify):%'
;

UPDATE survey_staging
SET top_job_priority = TRIM(REPLACE(top_job_priority, 'Other (Please Specify):', ''))
WHERE top_job_priority LIKE 'Other (Please Specify):%'
;

-- multiple priorities
UPDATE survey_staging
SET top_job_priority = 'Multiple Priorities'
WHERE top_job_priority = 'I would say a combination of good work/life balance with a better pay and the exposure to a workplace that supposed growth'
OR top_job_priority = 'Both Good work / life Balance and Good Culture'
;

-- desired location
UPDATE survey_staging
SET top_job_priority = 'Desired Location'
WHERE top_job_priority = 'Want to move from Australia to Canada, so position in desired country'
;

-- the work
UPDATE survey_staging
SET top_job_priority = 'The Work'
WHERE top_job_priority = 'The work'
;

-- remote work
UPDATE survey_staging
SET top_job_priority = 'Remote Work'
WHERE top_job_priority = 'Remote too'
;

-- learning opportunities
UPDATE survey_staging
SET top_job_priority = 'Learning Opportunities'
WHERE top_job_priority = 'Learning possibilities'
OR top_job_priority = 'Good opportunities in projects and learnjng'
OR top_job_priority = 'Learning opportunity'
OR top_job_priority = 'Learning New Things'
OR top_job_priority = 'Learning new skills'
OR top_job_priority = 'Opportunity to learn'
;

-- all of the above
UPDATE survey_staging
SET top_job_priority = 'All of the Above'
WHERE top_job_priority = 'All of the above'
OR top_job_priority = 'All of the options are important to me when looking for a new job'
OR top_job_priority = 'Mix of better salary, good work/life balance, remote work and good culture'
;

-- growth opportunities
UPDATE survey_staging
SET top_job_priority = 'Growth Opportunities'
WHERE top_job_priority LIKE '%growth%'
OR top_job_priority LIKE '%advance%'
;

-- mentorship
UPDATE survey_staging
SET top_job_priority = 'Mentorship'
WHERE top_job_priority LIKE '%mentor%'
;

-- passion
UPDATE survey_staging
SET top_job_priority = 'Passion'
WHERE top_job_priority = 'My passion is to become a Data analyst'
;

-- interesting work
UPDATE survey_staging
SET top_job_priority = 'Interesting Work'
WHERE top_job_priority = 'Challenging / exciting problems'
OR top_job_priority = 'Projects Iâ€™m interested in'
OR top_job_priority = 'Intresting work'
;

-- strong data strategy & team
UPDATE survey_staging
SET top_job_priority = 'Strong Data Strategy & Team'
WHERE top_job_priority = 'Strong organizational data strategy, high-performing team'
;

-- unclear role to blank
UPDATE survey_staging
SET top_job_priority = ''
WHERE top_job_priority = 'Salary and expo'
;

UPDATE survey_staging
SET top_job_priority = ''
WHERE top_job_priority = 'Better work & remote salary'
;

-- in-office work
UPDATE survey_staging
SET top_job_priority = 'In-Office Work'
WHERE top_job_priority = 'In office work'
;

-- business impact
UPDATE survey_staging
SET top_job_priority = 'Business Impact'
WHERE top_job_priority LIKE '%impact%'
;

-- desired job title
UPDATE survey_staging
SET top_job_priority = 'Desired Job Title'
WHERE top_job_priority = 'Different job title, either product owner or consulting'
;

-- satisfied with current role
UPDATE survey_staging
SET top_job_priority = 'Satisfied with Current Role'
WHERE top_job_priority = 'Currently very happy with where I am.'
;

SELECT top_job_priority, COUNT(*) count_respondents
FROM survey_staging
GROUP BY top_job_priority
ORDER BY 1 DESC;


-- Standardize residing country

-- get rid of "Other (Please Specify)"
SELECT residing_country, 
	TRIM(REPLACE(residing_country, 'Other (Please Specify):', '')) 
FROM survey_staging
WHERE residing_country LIKE 'Other (Please Specify):%'
;

UPDATE survey_staging
SET residing_country = TRIM(REPLACE(residing_country, 'Other (Please Specify):', ''))
WHERE residing_country LIKE 'Other (Please Specify):%'
;

-- uzbekistan
UPDATE survey_staging
SET residing_country = 'Uzbekistan'
WHERE residing_country = 'uzb'
;

-- tunisia
UPDATE survey_staging
SET residing_country = 'Tunisia'
WHERE residing_country = 'TUNISIA'
;

-- singapore
UPDATE survey_staging
SET residing_country = 'Singapore'
WHERE residing_country = 'SG'
;

-- republic democratic of the congo
UPDATE survey_staging
SET residing_country = 'Republic Democratic of the Congo'
WHERE residing_country = 'Republic democratic of Congo'
;

-- portugal
UPDATE survey_staging
SET residing_country = 'Portugal'
WHERE residing_country = 'Portugsl'
;

-- peru
UPDATE survey_staging
SET residing_country = 'Peru'
WHERE residing_country = 'PerÃº'
;

-- "Other (Please Specify)" into blank
UPDATE survey_staging
SET residing_country = ''
WHERE residing_country = 'Other (Please Specify)'
;

-- kenya
UPDATE survey_staging
SET residing_country = 'Kenya'
WHERE residing_country = 'Kenua'
;

-- ireland
UPDATE survey_staging
SET residing_country = 'Ireland'
WHERE residing_country LIKE '%ire%'
;

-- indonesia
UPDATE survey_staging
SET residing_country = 'Indonesia'
WHERE residing_country = 'indonesia'
;

-- finland
UPDATE survey_staging
SET residing_country = 'Finland'
WHERE residing_country = 'Fin'
;

-- brazil
UPDATE survey_staging
SET residing_country = 'Brazil'
WHERE residing_country = 'Brazik'
;

-- unclear response into blank
UPDATE survey_staging
SET residing_country = ''
WHERE residing_country = 'Austr'
;

UPDATE survey_staging
SET residing_country = ''
WHERE residing_country = 'Aisa'
;

-- argentina
UPDATE survey_staging
SET residing_country = 'Argentina'
WHERE residing_country = 'Argentine'
;

-- nigeria
UPDATE survey_staging
SET residing_country = 'Nigeria'
WHERE residing_country = 'Africa (Nigeria)'
;

-- sri lanka
UPDATE survey_staging
SET residing_country = 'Sri Lanka'
WHERE residing_country = 'Sri lanka'
;

-- lebanon
UPDATE survey_staging
SET residing_country = 'Lebanon'
WHERE residing_country = 'Leba'
;

-- united arab emirates
UPDATE survey_staging
SET residing_country = 'United Arab Emirates'
WHERE residing_country = 'UAE'
;

SELECT residing_country, COUNT(*) count_respondents
FROM survey_staging
GROUP BY residing_country
ORDER BY 1 DESC;



-- Standardize ethnicity

-- get rid of "Other (Please Specify):"
SELECT ethnicity, 
	TRIM(REPLACE(ethnicity, 'Other (Please Specify):', ''))
FROM survey_staging
WHERE ethnicity LIKE 'Other (Please Specify):%'
;

UPDATE survey_staging
SET ethnicity = TRIM(REPLACE(ethnicity, 'Other (Please Specify):', ''))
WHERE ethnicity LIKE 'Other (Please Specify):%'
;

-- turn unclear responses to blank
UPDATE survey_staging
SET ethnicity = ''
WHERE ethnicity = "Race isn't a thing"
OR ethnicity = "N/A"
OR ethnicity = "Bi-racial people should be able to check 2 options in 2022."
OR ethnicity = "Human"
OR ethnicity = '7'
;

-- prefer not to answer
UPDATE survey_staging
SET ethnicity = 'Prefer Not to Answer'
WHERE ethnicity = 'Prefer not to ans'
;

-- "Other (Please Specify)" into blank
UPDATE survey_staging
SET ethnicity = ''
WHERE ethnicity = 'Other (Please Specify)'
;

-- native hawaiian or other pacific islander
UPDATE survey_staging
SET ethnicity = 'Native Hawaiian or Other Pacific Islander'
WHERE ethnicity = 'Native Hawaiian or other Pacific Islander'
;

-- middle eastern
UPDATE survey_staging
SET ethnicity = 'Middle Eastern'
WHERE ethnicity = 'Middleeas'
;

-- malay
UPDATE survey_staging
SET ethnicity = 'Malay'
WHERE ethnicity = 'Melayu'
;

-- latino with italian roots
UPDATE survey_staging
SET ethnicity = 'Latino with Italian Roots'
WHERE ethnicity = 'Latino with Italian roots'
;

-- half black and half white
UPDATE survey_staging
SET ethnicity = 'Half Black and Half White'
WHERE ethnicity = 'Half black and half white'
;

-- half asian half african
UPDATE survey_staging
SET ethnicity = 'Half Asian Half African'
WHERE ethnicity = 'Half Asian half African'
;

-- egyptian
UPDATE survey_staging
SET ethnicity = 'Egyptian'
WHERE ethnicity = 'Egyp'
;

-- black or african american
UPDATE survey_staging
SET ethnicity = 'Black or African American'
WHERE ethnicity = 'Bla'
;

-- asian or asian american
UPDATE survey_staging
SET ethnicity = 'Asian or Asian American'
WHERE ethnicity = 'Asian'
;

-- nigerian
UPDATE survey_staging
SET ethnicity = 'Nigerian'
WHERE ethnicity = 'Nigeria'
;

-- mixed
UPDATE survey_staging
SET ethnicity = 'Mixed (Caucasian/African-American)'
WHERE ethnicity = 'Mixed ( Caucasian / African-American )'
;

SELECT ethnicity, COUNT(*) count_respondents
FROM survey_staging
GROUP BY ethnicity
ORDER BY 1 DESC;


-- Check and Standardize Age

SELECT age, COUNT(*) count_respondents
FROM survey_staging
GROUP BY age
ORDER BY 1 DESC;
-- no blanks or extreme values


-- Check and Standardize Gender

SELECT gender, COUNT(*) count_respondents
FROM survey_staging
GROUP BY gender
ORDER BY 1 DESC;
-- no blanks or extreme values


-- Check and Standardize Highest Education

SELECT highest_education, COUNT(*) count_respondents
FROM survey_staging
GROUP BY highest_education
ORDER BY 1 DESC;
-- no extreme values, 52 blanks


-- Check and Standardize Difficulty Breaking into Data

SELECT difficulty_breaking_into_data, COUNT(*) count_respondents
FROM survey_staging
GROUP BY difficulty_breaking_into_data
ORDER BY 1 DESC;
-- no blanks or extreme values


-- Check and Standardize Learning Happiness

SELECT learning_happiness, COUNT(*) count_respondents
FROM survey_staging
GROUP BY learning_happiness
ORDER BY 1 DESC;
-- no extreme values, 5 blanks


-- Check and Standardize Upward Mobility Happiness

SELECT upward_mobility_happiness, COUNT(*) count_respondents
FROM survey_staging
GROUP BY upward_mobility_happiness
ORDER BY 1 DESC;
-- no extreme values, 13 blanks


-- Check and Standardize Management Happiness

SELECT management_happiness, COUNT(*) count_respondents
FROM survey_staging
GROUP BY management_happiness
ORDER BY 1 DESC;
-- no extreme values, 12 blanks


-- Check and Standardize Coworker Happiness

SELECT coworker_happiness, COUNT(*) count_respondents
FROM survey_staging
GROUP BY coworker_happiness
ORDER BY 1 DESC;
-- no extreme values, 11 blanks


-- Check and Standardize Worklife Balance Happiness

SELECT worklife_balance_happiness, COUNT(*) count_respondents
FROM survey_staging
GROUP BY worklife_balance_happiness
ORDER BY 1 DESC;
-- no extreme values, 10 blanks


-- Check and Standardize Salary Happiness

SELECT salary_happiness, COUNT(*) count_respondents
FROM survey_staging
GROUP BY salary_happiness
ORDER BY 1 DESC;
-- no extreme values, 7 blanks


-- Check and Standardize Career Switch

SELECT career_switch, COUNT(*) count_respondents
FROM survey_staging
GROUP BY career_switch
ORDER BY 1 DESC;
-- no extreme values or blanks


-- Check for any missing values in date taken, time taken, time spent, and respondent id

SELECT SUM(respondent_id = '') AS respondent_id_blanks,
    SUM(date_taken IS NULL) AS date_taken_missing,
    SUM(time_taken IS NULL) AS time_taken_missing,
    SUM(time_spent IS NULL) AS time_spent_missing
FROM survey_staging;
-- no missing values


-- Standardize salary

SELECT salary, COUNT(*) count_respondents
FROM survey_staging
GROUP BY salary
ORDER BY 1 ASC;

-- Add Minimum Salary, Maximum Salary, and Estimated Salary Columns
-- This provides numerical data for the salary ranges

-- create another staging table
CREATE TABLE survey_staging2
LIKE survey_staging
;

INSERT INTO survey_staging2
SELECT *
FROM survey_staging
;

ALTER TABLE survey_staging2
ADD COLUMN salary_min INT AFTER salary,
ADD COLUMN salary_max INT AFTER salary_min,
ADD COLUMN salary_midpoint INT AFTER salary_max
;


-- fill in the columns with their respective information
UPDATE survey_staging2
SET
    salary_min = CASE
        WHEN salary = '0-40k' THEN 0
        WHEN salary = '41k-65k' THEN 41000
        WHEN salary = '66k-85k' THEN 66000
        WHEN salary = '86k-105k' THEN 86000
        WHEN salary = '106k-125k' THEN 106000
        WHEN salary = '125k-150k' THEN 125000
        WHEN salary = '150k-225k' THEN 150000
        WHEN salary = '225k+' THEN 225000
    END,

    salary_max = CASE
        WHEN salary = '0-40k' THEN 40000
        WHEN salary = '41k-65k' THEN 65000
        WHEN salary = '66k-85k' THEN 85000
        WHEN salary = '86k-105k' THEN 105000
        WHEN salary = '106k-125k' THEN 125000
        WHEN salary = '125k-150k' THEN 150000
        WHEN salary = '150k-225k' THEN 225000
        WHEN salary = '225k+' THEN NULL
    END,

    salary_midpoint = CASE
        WHEN salary = '0-40k' THEN 20000
        WHEN salary = '41k-65k' THEN 53000
        WHEN salary = '66k-85k' THEN 75500
        WHEN salary = '86k-105k' THEN 95500
        WHEN salary = '106k-125k' THEN 115500
        WHEN salary = '125k-150k' THEN 137500
        WHEN salary = '150k-225k' THEN 187500
        WHEN salary = '225k+' THEN NULL
    END;


-- newly added columns
SELECT DISTINCT
    salary,
    salary_min,
    salary_max,
    salary_midpoint
FROM survey_staging2
ORDER BY salary_min;



-- Dealing With NULL & Blanks

-- Missing-value handling notes to self:
-- industry: blanks created from unspecified "Other" or unclear responses -> Other
-- current_role: blanks created from unspecified "Other" or unclear responses -> Other
-- favorite_programming_language: blanks created from NA / Unknown / unusable responses -> NULL
-- top_job_priority: blanks created from unspecified "Other" or unclear responses -> Other
-- residing_country: blanks created from unspecified "Other" or unclear responses -> Other
-- ethnicity: blanks created from unspecified "Other" or unclear responses -> Other
-- highest_education: blanks created from NA / Unknown / unusable responses -> NULL
-- learning_happiness: blanks from missing responses -> NULL
-- upward_mobility_happiness: blanks from missing responses -> NULL
-- management_happiness: blanks from missing responses -> NULL
-- coworker_happiness: blanks from missing responses -> NULL
-- worklife_balance_happiness: blanks from missing responses -> NULL
-- salary_happiness: blanks from missing responses -> NULL

-- Filling in all blanks that correspond to 'Other'
UPDATE survey_staging2
SET industry = 'Other'
WHERE TRIM(industry) = ''
;

UPDATE survey_staging2
SET current_role = 'Other'
WHERE TRIM(current_role) = ''
;

UPDATE survey_staging2
SET top_job_priority = 'Other'
WHERE TRIM(top_job_priority) = ''
;

UPDATE survey_staging2
SET residing_country = 'Other'
WHERE TRIM(residing_country) = ''
;

UPDATE survey_staging2
SET ethnicity = 'Other'
WHERE TRIM(ethnicity) = ''
;



-- Filling in all blanks that correspond to NULL
UPDATE survey_staging2
SET favorite_programming_language = NULL
WHERE TRIM(favorite_programming_language) = ''
;

UPDATE survey_staging2
SET highest_education = NULL
WHERE TRIM(highest_education) = ''
;

UPDATE survey_staging2
SET learning_happiness = NULL
WHERE TRIM(learning_happiness) = ''
;

UPDATE survey_staging2
SET upward_mobility_happiness = NULL
WHERE TRIM(upward_mobility_happiness) = ''
;

UPDATE survey_staging2
SET management_happiness = NULL
WHERE TRIM(management_happiness) = ''
;

UPDATE survey_staging2
SET coworker_happiness = NULL
WHERE TRIM(coworker_happiness) = ''
;

UPDATE survey_staging2
SET worklife_balance_happiness = NULL
WHERE TRIM(worklife_balance_happiness) = ''
;

UPDATE survey_staging2
SET salary_happiness = NULL
WHERE TRIM(salary_happiness) = ''
;

SELECT SUM(industry = '') industry_blanks,
    SUM(current_role = '') current_role_blanks,
    SUM(favorite_programming_language = '') language_blanks,
    SUM(top_job_priority = '') priority_blanks,
    SUM(residing_country = '') country_blanks,
    SUM(ethnicity = '')  ethnicity_blanks,
    SUM(highest_education = '') education_blanks,
    SUM(learning_happiness = '') learning_blanks,
    SUM(upward_mobility_happiness = '') mobility_blanks,
    SUM(management_happiness = '')  management_blanks,
    SUM(coworker_happiness = '') coworker_blanks,
    SUM(worklife_balance_happiness = '') worklife_blanks,
    SUM(salary_happiness = '') salary_happiness_blanks
FROM survey_staging2;



-- Deleting any rows or columns that aren't needed

-- remove email, browser, OS, city, country, referrer 
-- since all either empty or provide no information of use
-- create another staging table to delete these columns
CREATE TABLE survey_staging3
LIKE survey_staging2;

INSERT INTO survey_staging3
SELECT *
FROM survey_staging2;

ALTER TABLE survey_staging3
DROP COLUMN email,
DROP COLUMN browser,
DROP COLUMN os,
DROP COLUMN city,
DROP COLUMN country,
DROP COLUMN referrer;


-- Final Look Through of Data
SELECT *
FROM survey_staging3
;
