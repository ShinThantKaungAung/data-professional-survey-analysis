-- Exploratory Data Analysis

-- Baseline Queries
SELECT *
FROM survey_staging3
;

-- What is the total number of survey respondent?
SELECT COUNT(*) total_respondents
FROM survey_staging3
;


-- What is the distribution of survey respondents by their current role?
SELECT current_role,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY current_role
ORDER BY 2 DESC
;


-- What is the distribution of survey respondents across the salary ranges?
SELECT salary,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY salary
ORDER BY salary_min
;


-- What proportion of the survey respondents switched their careers into data?
SELECT career_switch,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY career_switch
ORDER BY 2 DESC
;


-- Which industries do survey respondents work in?
SELECT industry,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY industry
ORDER BY 2 DESC
;


-- What are the most popular programming languages among survey respondents?
SELECT favorite_programming_language,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY favorite_programming_language
ORDER BY 2 DESC
;


-- What is the age profile of survey respondents?
SELECT ROUND(AVG(age), 2) average_age,
    MIN(age) minimum_age,
    MAX(age) maximum_age
FROM survey_staging3
;

-- How are respondents distributed across different age groups?
WITH age_groups AS (
    SELECT
        CASE
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END age_group
    FROM survey_staging3
)
SELECT age_group,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) percentage_of_respondents
FROM age_groups
GROUP BY age_group
ORDER BY 
	CASE
		WHEN age_group = '18-24' THEN 1
		WHEN age_group = '25-34' THEN 2
		WHEN age_group = '35-44' THEN 3
		WHEN age_group = '45-54' THEN 4
		WHEN age_group = '55+' THEN 5
	END
;


-- What is the gender distribution of the survey respondents?
SELECT gender,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY gender
ORDER BY 2 DESC
;


-- what is the highest level of education attained by the survey respondents?
SELECT highest_education,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY highest_education
ORDER BY 2 DESC
;


-- What is the geographic distribution of the survey respondents by country of residence?
SELECT residing_country,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) percentage_of_respondents
FROM survey_staging3
GROUP BY residing_country
ORDER BY 2 DESC
;



-- Relationship Queries

-- Does the reported difficulty of breaking into data differ between career switchers and non-career-switchers?
SELECT career_switch,
	difficulty_breaking_into_data,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY career_switch),2) percentage_of_respondents
FROM survey_staging3
GROUP BY career_switch, difficulty_breaking_into_data
ORDER BY 2 DESC
;


-- How does salary vary across the survey respondents' current roles?
SELECT current_role,
	salary,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY current_role),2) percentage_of_respondents
FROM survey_staging3
GROUP BY current_role, salary
ORDER BY current_role, salary_min ASC
;

-- Follow up
-- Which current roles have sufficient sample sizes for meaningful analysis?
SELECT current_role,
    COUNT(*) respondent_count
FROM survey_staging3
GROUP BY current_role
HAVING COUNT(*) >= 10
ORDER BY respondent_count DESC
;


-- Follow up
-- How does salary vary across current roles with sufficient sample sizes?
WITH meaningful_roles AS (
    SELECT current_role
    FROM survey_staging3
    GROUP BY current_role
    HAVING COUNT(*) >= 10
)
SELECT survey_staging3.current_role, 
	salary,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY survey_staging3.current_role),2) percentage_of_respondents
FROM survey_staging3
JOIN meaningful_roles
    ON survey_staging3.current_role = meaningful_roles.current_role
GROUP BY current_role, salary
ORDER BY current_role, salary_min
;

-- Follow up
-- What is the estimated average salary across current roles with sufficient sample sizes?
WITH meaningful_roles AS (
    SELECT current_role
    FROM survey_staging3
    GROUP BY current_role
    HAVING COUNT(*) >= 10
)
SELECT
    survey_staging3.current_role,
    COUNT(*) respondent_count,
    ROUND(AVG(salary_midpoint), 2) estimated_average_salary
FROM survey_staging3
JOIN meaningful_roles
    ON survey_staging3.current_role = meaningful_roles.current_role
GROUP BY current_role
ORDER BY estimated_average_salary DESC
;



-- Does the reported difficulty of breaking into data differ across current roles?
WITH meaningful_roles AS (
    SELECT current_role
    FROM survey_staging3
    GROUP BY current_role
    HAVING COUNT(*) >= 10
)
SELECT survey_staging3.current_role,
    difficulty_breaking_into_data,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY survey_staging3.current_role),2) percentage_of_respondents
FROM survey_staging3
JOIN meaningful_roles
    ON survey_staging3.current_role = meaningful_roles.current_role
GROUP BY current_role, difficulty_breaking_into_data
ORDER BY current_role
;

-- Follow up
-- What percentage of respondents in each of the sufficient sized current role reported difficulty breaking into data?
WITH meaningful_roles AS (
    SELECT current_role
    FROM survey_staging3
    GROUP BY current_role
    HAVING COUNT(*) >= 10
)
SELECT survey_staging3.current_role,
    COUNT(*) respondent_count,
    SUM(
        CASE
            WHEN difficulty_breaking_into_data IN ('Difficult', 'Very Difficult')
            THEN 1
            ELSE 0
        END
    ) difficult_respondents,
    ROUND(
        SUM(
            CASE
                WHEN difficulty_breaking_into_data IN ('Difficult', 'Very Difficult')
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),2) difficulty_percentage
FROM survey_staging3
JOIN meaningful_roles
    ON survey_staging3.current_role = meaningful_roles.current_role
GROUP BY current_role
ORDER BY difficulty_percentage DESC
;


-- How does gender representation vary across industries?

-- First check: Which industries have sufficient sample sizes for meaningful analysis?
SELECT industry,
    COUNT(*) respondent_count
FROM survey_staging3
GROUP BY industry
HAVING COUNT(*) >= 10
ORDER BY respondent_count DESC
;

-- How does gender representation vary across industries with sufficient sample sizes?
WITH meaningful_industries AS (
    SELECT industry
    FROM survey_staging3
    GROUP BY industry
    HAVING COUNT(*) >= 10
)
SELECT survey_staging3.industry,
    gender,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY industry),2) percentage_of_respondents
FROM survey_staging3
JOIN meaningful_industries
    ON survey_staging3.industry = meaningful_industries.industry
GROUP BY industry, gender
ORDER BY industry
;


-- How does salary vary across education levels?
SELECT highest_education,
    salary,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY highest_education),2) percentage_of_respondents
FROM survey_staging3
GROUP BY highest_education, salary
ORDER BY highest_education, salary_min
;

		
-- Follow up
-- How does salary vary across respondents who reported their highest level of education?
SELECT highest_education,
    salary,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY highest_education),2) percentage_of_respondents
FROM survey_staging3
WHERE highest_education IS NOT NULL
GROUP BY highest_education, salary
ORDER BY highest_education, salary_min
;


-- Follow up
-- What is the estimated average salary across education levels with sufficient sample sizes?
SELECT highest_education,
    COUNT(*) respondent_count,
    ROUND(AVG(salary_midpoint), 2) estimated_average_salary
FROM survey_staging3
WHERE highest_education IS NOT NULL
GROUP BY highest_education
HAVING COUNT(*) >= 10
ORDER BY estimated_average_salary DESC
;



-- Does salary satisfaction vary across salary ranges?
SELECT salary,
    COUNT(*) respondent_count,
    ROUND(AVG(salary_happiness), 2) average_salary_happiness
FROM survey_staging3
WHERE salary_happiness IS NOT NULL
GROUP BY salary
ORDER BY salary_min
;

-- Follow up
-- How does salary satisfaction vary across salary ranges with sufficient sample sizes?
SELECT salary,
    COUNT(*) respondent_count,
    ROUND(AVG(salary_happiness), 2) average_salary_happiness
FROM survey_staging3
WHERE salary_happiness IS NOT NULL
GROUP BY salary
HAVING COUNT(*) >= 10
ORDER BY salary_min
;



-- What is the estimated average salary across countries with sufficient sample sizes?
SELECT residing_country,
    COUNT(*) respondent_count,
    ROUND(AVG(salary_midpoint), 2) estimated_average_salary
FROM survey_staging3
GROUP BY residing_country
HAVING COUNT(*) >= 10
ORDER BY estimated_average_salary DESC;



-- How does industry representation vary across countries?
WITH meaningful_countries AS (
    SELECT residing_country
    FROM survey_staging3
    GROUP BY residing_country
    HAVING COUNT(*) >= 10
)
SELECT survey_staging3.residing_country,
    industry,
    COUNT(*) respondent_count,
    ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY residing_country),2) percentage_of_respondents
FROM survey_staging3
JOIN meaningful_countries
    ON survey_staging3.residing_country = meaningful_countries.residing_country
GROUP BY residing_country, industry
ORDER BY residing_country, percentage_of_respondents DESC
;

-- Follow up
-- What are the top 3 industries represented within each country?
WITH meaningful_countries AS (
    SELECT residing_country
    FROM survey_staging3
    GROUP BY residing_country
    HAVING COUNT(*) >= 10
),
country_industry_distribution AS (
    SELECT survey_staging3.residing_country,
        industry,
        COUNT(*) respondent_count,
        ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(PARTITION BY residing_country),2) percentage_of_respondents
    FROM survey_staging3
    JOIN meaningful_countries
        ON survey_staging3.residing_country = meaningful_countries.residing_country
    GROUP BY residing_country, industry
),
ranked_industries AS (
    SELECT *,
		ROW_NUMBER() OVER(PARTITION BY residing_country ORDER BY respondent_count DESC) industry_rank
    FROM country_industry_distribution
)
SELECT residing_country,
    industry,
    respondent_count,
    percentage_of_respondents
FROM ranked_industries
WHERE industry_rank <= 3
ORDER BY residing_country, industry_rank
;



-- What is each respondent's overall happiness score based on their available responses?
SELECT respondent_id,
    ROUND(
		(COALESCE(salary_happiness, 0) +
		COALESCE(worklife_balance_happiness, 0) +
		COALESCE(coworker_happiness, 0) +
		COALESCE(management_happiness, 0) +
		COALESCE(upward_mobility_happiness, 0) +
		COALESCE(learning_happiness, 0))
		/
		( (salary_happiness IS NOT NULL) +
		(worklife_balance_happiness IS NOT NULL) +
		(coworker_happiness IS NOT NULL) +
		(management_happiness IS NOT NULL) +
		(upward_mobility_happiness IS NOT NULL) +
		(learning_happiness IS NOT NULL) ), 2) overall_happiness
FROM survey_staging3
;


-- How does overall happiness vary across current roles with sufficient sample sizes?
WITH respondent_happiness AS (
    SELECT respondent_id,
        current_role,
        ROUND(
		(COALESCE(salary_happiness, 0) +
		COALESCE(worklife_balance_happiness, 0) +
		COALESCE(coworker_happiness, 0) +
		COALESCE(management_happiness, 0) +
		COALESCE(upward_mobility_happiness, 0) +
		COALESCE(learning_happiness, 0))
		/
		( (salary_happiness IS NOT NULL) +
		(worklife_balance_happiness IS NOT NULL) +
		(coworker_happiness IS NOT NULL) +
		(management_happiness IS NOT NULL) +
		(upward_mobility_happiness IS NOT NULL) +
		(learning_happiness IS NOT NULL) ), 2) overall_happiness
    FROM survey_staging3
),
meaningful_roles AS (
    SELECT current_role
    FROM survey_staging3
    GROUP BY current_role
    HAVING COUNT(*) >= 10
)
SELECT respondent_happiness.current_role,
    COUNT(*) respondent_count,
    ROUND(AVG(overall_happiness), 2) average_overall_happiness
FROM respondent_happiness
JOIN meaningful_roles
    ON respondent_happiness.current_role = meaningful_roles.current_role
GROUP BY current_role
ORDER BY average_overall_happiness DESC;





-- KEY FINDINGS
-- The survey respondents who switched careers into data were more likely to report difficulty breaking into data than those who didn't.
-- Data Scientists reported the highest estimated average salary (~$86K), followed by Data Engineers (~$61K) and Data Analysts (~$55K) among roles with at least 10 respondents.
-- Student/Looking/None respondents reported the highest difficulty breaking into data (45.56%), followed by Data Scientists (40.74%), while Data Engineers reported the lowest (18.42%).
-- Male respondents were the majority across all industries analyzed, with Healthcare showing the highest female representation at 37.65%.
-- Respondents with a Master’s degree had the highest estimated average salary at about $61.2K, compared with $48.9K for Bachelor’s, $47.7K for High School, and $43.0K for Associate degree holders.
-- Salary satisfaction generally increased with salary, rising from 2.86/10 for respondents earning $0–40K to 8.15/10 for those earning $150–225K.
-- Among countries with sufficient sample sizes, respondents in the United States had the highest estimated average salary at about $77.7K, followed by Canada at $67.8K, while Nigeria had the lowest at about $21.9K.
-- Technology was among the top three industries in every country analyzed and was the leading industry in Canada, Germany, India, Nigeria, and the United Kingdom.
-- Among roles with sufficient sample sizes, Data Scientists reported the highest average overall happiness at 6.12/10, while Student/Looking/None respondents reported the lowest at 3.70/10.
