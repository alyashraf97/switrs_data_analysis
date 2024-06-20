CREATE MATERIALIZED VIEW public.collision_statistics_mv AS
SELECT
  COUNT(*) AS total_collisions,
  SUM(CASE WHEN killed_victims > 0 THEN 1 ELSE 0 END) AS fatal_collisions,
  SUM(killed_victims) AS total_fatalities,
  SUM(injured_victims) AS total_injuries,
  AVG(party_count) AS average_parties_involved,
  COUNT(DISTINCT case_id) AS unique_cases,
  SUM(CASE WHEN alcohol_involved IS NOT NULL THEN 1 ELSE 0 END) AS alcohol_related_collisions,
  SUM(CASE WHEN pedestrian_collision = 1 THEN 1 ELSE 0 END) AS pedestrian_collisions,
  SUM(CASE WHEN bicycle_collision = 1 THEN 1 ELSE 0 END) AS bicycle_collisions,
  SUM(CASE WHEN motorcycle_collision = 1 THEN 1 ELSE 0 END) AS motorcycle_collisions,
  SUM(CASE WHEN truck_collision = 1 THEN 1 ELSE 0 END) AS truck_collisions,
  SUM(CASE WHEN tow_away = 1 THEN 1 ELSE 0 END) AS tow_away_incidents,
  SUM(CASE WHEN hit_and_run <> '' THEN 1 ELSE 0 END) AS hit_and_run_incidents,
  SUM(CASE WHEN weather_1 <> '' THEN 1 ELSE 0 END) AS weather_related_collisions
FROM
  public.collisions;

-- To refresh the materialized view, you can use the following command:
-- REFRESH MATERIALIZED VIEW public.collision_statistics_mv;
 
 
CREATE MATERIALIZED VIEW public.collision_victim_stats_mv AS
SELECT
  CASE
    WHEN injured_victims BETWEEN 0 AND 1 THEN '0-1'
    WHEN injured_victims BETWEEN 2 AND 4 THEN '2-4'
    WHEN injured_victims BETWEEN 5 AND 9 THEN '5-9'
    WHEN injured_victims >= 10 THEN '10+'
    ELSE 'Unknown' -- for NULL or other cases
  END AS injury_bucket,
  COUNT(*) AS total_collisions,
  SUM(killed_victims) AS total_fatalities,
  SUM(injured_victims) AS total_injuries
FROM
  public.collisions
GROUP BY
  injury_bucket;

-- To refresh the materialized view, you can use the following command:
-- REFRESH MATERIALIZED VIEW public.collision_buckets_mv;

 
 CREATE MATERIALIZED VIEW public.collisions_victim_count_mv AS
SELECT
  injured_victims,
  COUNT(*) AS total_injury_cases,
  SUM(CASE WHEN killed_victims > 0 THEN 1 ELSE 0 END) AS fatal_cases_with_injuries,
  SUM(killed_victims) AS total_fatalities_with_injuries
FROM
  public.collisions
WHERE
  injured_victims IS NOT NULL
GROUP BY
  injured_victims
ORDER BY
  injured_victims;

-- To refresh the materialized view, you can use the following command:
-- REFRESH MATERIALIZED VIEW public.victim_count_mv;
 
 
CREATE MATERIALIZED VIEW public.weather_conditions_mv AS
SELECT
  weather_1 as weather_condition,
  COUNT(*) AS total_cases,
  SUM(CASE WHEN injured_victims IS NOT NULL THEN injured_victims ELSE 0 END) AS total_injuries,
  SUM(CASE WHEN killed_victims IS NOT NULL THEN killed_victims ELSE 0 END) AS total_fatalities,
  ROUND((SUM(CASE WHEN injured_victims IS NOT NULL THEN injured_victims ELSE 0 END)::NUMERIC / COUNT(*)), 2) AS injury_ratio,
  ROUND((SUM(CASE WHEN killed_victims IS NOT NULL THEN killed_victims ELSE 0 END)::NUMERIC / COUNT(*)), 2) AS fatality_ratio
FROM
  public.collisions
GROUP BY
  weather_1;

-- To refresh the materialized view, you can use the following command:
-- REFRESH MATERIALIZED VIEW public.weather_conditions_mv;\
 
 
CREATE MATERIALIZED VIEW victim_sex_mv AS
SELECT
  CASE
    WHEN victim_sex IN ('male', 'female') THEN victim_sex
    ELSE 'Others'
  END AS victim_sex_category,
  SUM(count) AS total_count
FROM (
  SELECT victim_sex, COUNT(*) as count
  FROM victims
  GROUP BY victim_sex
) AS sub_counts
GROUP BY victim_sex_category
ORDER BY total_count DESC;


create materialized view collision_violations_mv as
select
	pcf_violation_category as violation,
	count(*) as violation_count
from 
	collisions
where
	pcf_violation_category is not null 
group by
	violation
order by 
	violation_count
desc;



create materialized view collision_county_mv as
select
	county_location as county,
	count(*) as incident_count
from 
	collisions
where
	county_location is not null 
group by
	county_location 
order by 
	incident_count
desc;


CREATE MATERIALIZED VIEW collision_numeric_fields_mv AS
SELECT
  case_id
  distance,
  postmile,
  latitude,
  longitude,
  tow_away,
  killed_victims,
  injured_victims,
  party_count,
  pedestrian_collision,
  bicycle_collision,
  motorcycle_collision,
  truck_collision,
  alcohol_involved,
  severe_injury_count,
  other_visible_injury_count,
  complaint_of_pain_injury_count,
  pedestrian_killed_count,
  pedestrian_injured_count,
  bicyclist_killed_count,
  bicyclist_injured_count,
  motorcyclist_killed_count,
  motorcyclist_injured_count
FROM
  collisions

  
create materialized view collision_crash_severity_mv as
select
	collision_severity as severity,
	count(*) as count
from
	collisions
group by severity
order by count desc;


create materialized view collision_locations_mv as
select
	latitude,
	longitude
from
	collisions
where 
	latitude is not null
and
	longitude is not null
AND LENGTH(SUBSTRING(CAST(latitude AS TEXT) FROM '\.\d+')) >= 6
AND LENGTH(SUBSTRING(CAST(longitude AS TEXT) FROM '\.\d+')) >= 6;


create materialized view collision_primary_factor_mv as
select	
	primary_collision_factor as primary_factor,
	count(*) as count
from
	collisions
where primary_collision_factor is not null
group by primary_factor
order by count desc;


create materialized view parties_at_fault_by_make_mv as
select
	vehicle_make as make,
	count(*) as count
from parties
where at_fault = 1
and vehicle_make is not null
group by make
order by count desc



create materialized view parties_at_fault_by_age_mv as
select
	party_age as age,
	count(*) as count
from parties
where party_age is not null
group by age
order by count desc


CREATE MATERIALIZED VIEW parties_at_fault_by_age_buckets_mv AS
SELECT
    age_bucket,
    COUNT(*) AS count,
    age_bucket_index
FROM (
    SELECT
        party_age,
        CASE
            WHEN party_age BETWEEN 0 AND 4 THEN '0-4'
            WHEN party_age BETWEEN 5 AND 9 THEN '5-9'
            WHEN party_age BETWEEN 10 AND 14 THEN '10-14'
            WHEN party_age BETWEEN 15 AND 19 THEN '15-19'
            WHEN party_age BETWEEN 20 AND 24 THEN '20-24'
            WHEN party_age BETWEEN 25 AND 29 THEN '25-29'
            WHEN party_age BETWEEN 30 AND 34 THEN '30-34'
            WHEN party_age BETWEEN 35 AND 39 THEN '35-39'
            WHEN party_age BETWEEN 40 AND 44 THEN '40-44'
            WHEN party_age BETWEEN 45 AND 49 THEN '45-49'
            WHEN party_age BETWEEN 50 AND 54 THEN '50-54'
            WHEN party_age BETWEEN 55 AND 59 THEN '55-59'
            WHEN party_age BETWEEN 60 AND 64 THEN '60-64'
            WHEN party_age BETWEEN 65 AND 69 THEN '65-69'
            WHEN party_age BETWEEN 70 AND 74 THEN '70-74'
            WHEN party_age BETWEEN 75 AND 79 THEN '75-79'
            WHEN party_age BETWEEN 80 AND 84 THEN '80-84'
            WHEN party_age BETWEEN 85 AND 89 THEN '85-89'
            WHEN party_age >= 90 THEN '90+'
            ELSE 'Unknown' -- For any ages that might not fit the specified ranges
        END AS age_bucket,
        CASE
            WHEN party_age BETWEEN 0 AND 4 THEN 1
            WHEN party_age BETWEEN 5 AND 9 THEN 2
            WHEN party_age BETWEEN 10 AND 14 THEN 3
            WHEN party_age BETWEEN 15 AND 19 THEN 4
            WHEN party_age BETWEEN 20 AND 24 THEN 5
            WHEN party_age BETWEEN 25 AND 29 THEN 6
            WHEN party_age BETWEEN 30 AND 34 THEN 7
            WHEN party_age BETWEEN 35 AND 39 THEN 8
            WHEN party_age BETWEEN 40 AND 44 THEN 9
            WHEN party_age BETWEEN 45 AND 49 THEN 10
            WHEN party_age BETWEEN 50 AND 54 THEN 11
            WHEN party_age BETWEEN 55 AND 59 THEN 12
            WHEN party_age BETWEEN 60 AND 64 THEN 13
            WHEN party_age BETWEEN 65 AND 69 THEN 14
            WHEN party_age BETWEEN 70 AND 74 THEN 15
            WHEN party_age BETWEEN 75 AND 79 THEN 16
            WHEN party_age BETWEEN 80 AND 84 THEN 17
            WHEN party_age BETWEEN 85 AND 89 THEN 18
            WHEN party_age >= 90 THEN 19
            ELSE 20 -- For any ages that might not fit the specified ranges
        END AS age_bucket_index
    FROM parties
    WHERE party_age IS NOT NULL
) AS subquery
GROUP BY age_bucket, age_bucket_index
ORDER BY age_bucket_index;



select COUNT(id) from victims

select distinct victim_degree_of_injury from victims

create materialized view victim_injury_mv as
select
	victim_degree_of_injury as injury,
	count(*) as count
from victims
group by injury
order by count desc


select distinct primary_road from collisions


create materialized view collision_road_mv as
select
	primary_road as road_p,
	secondary_road as road_s,
	county_location as county,
	count(*) as count
from collisions
group by road_p, road_s, county
order by count desc;


CREATE MATERIALIZED VIEW collision_monthly_stats AS
SELECT
  EXTRACT(YEAR FROM collision_date::DATE) AS year,
  EXTRACT(MONTH FROM collision_date::DATE) AS month,
  COUNT(*) AS collision_count,
  SUM(injured_victims) AS total_injuries,
  SUM(killed_victims) AS total_fatalities
FROM
  collisions
GROUP BY
  year,
  month;

 
 CREATE MATERIALIZED VIEW collision_yearly_stats AS
SELECT
  EXTRACT(YEAR FROM collision_date::DATE) AS year,
  COUNT(*) AS collision_count,
  SUM(injured_victims) AS total_injuries,
  SUM(killed_victims) AS total_fatalities
FROM
  collisions
GROUP BY
  year;
 
create materialized view collision_severity_mv AS
SELECT
	COUNT(collision_severity) AS count,
	collision_severity 
FROM collisions 
where Collision_severity != 'N'
GROUP BY collision_severity 
ORDER BY count DESC


CREATE MATERIALIZED VIEW collision_day_of_week_stats AS
SELECT
  EXTRACT(DOW FROM collision_date::DATE) AS day_of_week,
  CASE
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 0 THEN 'Sunday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 1 THEN 'Monday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 2 THEN 'Tuesday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 3 THEN 'Wednesday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 4 THEN 'Thursday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 5 THEN 'Friday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 6 THEN 'Saturday'
  END AS day_name,
  COUNT(*) AS collision_count,
  SUM(injured_victims) AS total_injuries,
  SUM(killed_victims) AS total_fatalities
FROM
  collisions
GROUP BY
  day_of_week, day_name;


CREATE MATERIALIZED VIEW collision_day_time_stats AS
SELECT
  EXTRACT(DOW FROM collision_date::DATE) AS day_of_week,
  CASE
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 0 THEN 'Sunday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 1 THEN 'Monday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 2 THEN 'Tuesday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 3 THEN 'Wednesday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 4 THEN 'Thursday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 5 THEN 'Friday'
    WHEN EXTRACT(DOW FROM collision_date::DATE) = 6 THEN 'Saturday'
  END AS day_name,
  FLOOR(EXTRACT(HOUR FROM collision_time::TIME) / 2) * 2 AS time_of_day_bin,
  COUNT(*) AS collision_count,
  SUM(injured_victims) AS total_injuries,
  SUM(killed_victims) AS total_fatalities
FROM
  collisions
GROUP BY
  day_of_week, day_name, time_of_day_bin;


select COUNT(*) from collision_road_mv


select distinct victim_ejected from victims


UPDATE victims
SET victim_ejected = CASE
  WHEN victim_ejected IN ('fully ejected', 'F', 'f') THEN 'Fully Ejected'
  WHEN victim_ejected IN ('not ejected', 'N', 'n') THEN 'Not Ejected'
  WHEN victim_ejected IN ('partially ejected', 'P', 'p') THEN 'Partially Ejected'
  ELSE 'Unknown'
END;



CREATE MATERIALIZED VIEW victim_ejection_probabilities AS
SELECT
  victim_seating_position,
  victim_safety_equipment_1,
  victim_safety_equipment_2,
  (SUM(CASE WHEN victim_ejected IN ('Partially Ejected', 'Fully Ejected') THEN 1 ELSE 0 END)::float /
  COUNT(*)) AS p_ejected_and_equipment,
  (COUNT(*) FILTER (WHERE victim_seating_position IS NOT NULL AND victim_safety_equipment_1 IS NOT NULL AND victim_safety_equipment_2 IS NOT NULL)::float /
  (SELECT COUNT(*) FROM victims)) AS p_equipment,
  (SUM(CASE WHEN victim_ejected IN ('Partially Ejected', 'Fully Ejected') THEN 1 ELSE 0 END)::float /
  (SELECT COUNT(*) FROM victims)) AS p_ejected_given_equipment
FROM victims
GROUP BY victim_seating_position, victim_safety_equipment_1, victim_safety_equipment_2;


CREATE MATERIALIZED VIEW ejection_probability_safety1 AS
SELECT
  victim_seating_position,
  victim_safety_equipment_1,
  SUM(CASE WHEN victim_ejected IN ('Partially Ejected', 'Fully Ejected') THEN 1 ELSE 0 END)::float / COUNT(*) AS p_ejected_given_safety1,
  COUNT(*)::float / (SELECT COUNT(*) FROM victims) AS p_safety1,
  SUM(CASE WHEN victim_ejected IN ('Partially Ejected', 'Fully Ejected') THEN 1 ELSE 0 END)::float / (SELECT COUNT(*) FROM victims) AS p_ejected
FROM victims
GROUP BY victim_seating_position, victim_safety_equipment_1;



select distinct victim_safety_equipment_1 from victims



CREATE OR REPLACE FUNCTION switrs_get_categorical_variables()
RETURNS TABLE(column_name text, column_value text) AS $$
DECLARE
  rec record;
BEGIN
  FOR rec IN 
    SELECT 
      table_name,
      column_name AS col_name 
    FROM 
      information_schema.columns 
    WHERE 
      table_schema = 'public' 
    AND 
      table_name IN 
        ('collisions',
        'victims',
        'parties') 
    AND 
      column_name IN 
        ('county_city_location',
        'county_location',
        'weather_1',
        'location_type',
        'collision_severity',
        'primary_collision_factor',
        'pcf_violation_category',
        'hit_and_run',
        'type_of_collision',
        'motor_vehicle_involved_with',
        'pedestrian_action',
        'road_surface',
        'road_condition_1',
        'lighting',
        'control_device',
        'statewide_vehicle_type_at_fault',
        'party_type',
        'party_sex',
        'party_sobriety',
        'party_drug_physical',
        'party_safety_equipment_1',
        'cellphone_use_type',
        'oaf_violation_category',
        'movement_preceding_collision',
        'vehicle_make',
        'statewide_vehicle_type',
        'chp_vehicle_type_towing',
        'party_race',
        'victim_role',
        'victim_sex',
        'victim_degree_of_injury',
        'victim_seating_position',
        'victim_safety_equipment_1',
        'victim_ejected') 
    AND 
      data_type NOT IN 
        ('integer',
        'bigint',
        'smallint', 
        'decimal', 
        'numeric', 
        'real', 
        'double precision', 
        'serial', 
        'bigserial') 
  LOOP
    RETURN QUERY 
      EXECUTE 
        'SELECT ''' 
        || rec.col_name 
        || ''' AS column_name, ' 
        || quote_ident(rec.col_name) 
        || ' AS column_value FROM ' 
        || quote_ident(rec.table_name) 
        || ' WHERE ' 
        || quote_ident(rec.col_name) 
        || ' IS NOT NULL;';
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Then, create the materialized view from the function:
CREATE MATERIALIZED VIEW categorical_variables AS
SELECT * FROM switrs_get_categorical_variables();





CREATE OR REPLACE FUNCTION switrs_get_categorical_variables() RETURNS TABLE(categorical_column text, categorical_value text) AS $$
DECLARE
  rec record;
BEGIN
  FOR rec IN SELECT table_name, column_name AS table_column_name
  FROM information_schema.columns
  WHERE table_schema = 'public'
  AND table_name IN ('collisions', 'victims', 'parties')
  AND column_name IN ('county_city_location', 'county_location', 'weather_1', 'location_type', 'collision_severity', 'primary_collision_factor', 'pcf_violation_category', 'hit_and_run', 'type_of_collision', 'motor_vehicle_involved_with', 'pedestrian_action', 'road_surface', 'road_condition_1', 'lighting', 'control_device', 'statewide_vehicle_type_at_fault', 'party_type', 'party_sex', 'party_sobriety', 'party_drug_physical', 'party_safety_equipment_1', 'cellphone_use_type', 'oaf_violation_category', 'movement_preceding_collision', 'vehicle_make', 'statewide_vehicle_type', 'chp_vehicle_type_towing', 'party_race', 'victim_role', 'victim_sex', 'victim_degree_of_injury', 'victim_seating_position', 'victim_safety_equipment_1', 'victim_ejected')
  AND data_type NOT IN ('integer', 'bigint', 'smallint', 'decimal', 'numeric', 'real', 'double precision', 'serial', 'bigserial')
  LOOP
    RETURN QUERY EXECUTE 'SELECT ''' || rec.table_column_name || ''' AS categorical_column, CAST(' || quote_ident(rec.table_column_name) || ' AS text) AS categorical_value FROM ' || quote_ident(rec.table_name) || ' WHERE ' || quote_ident(rec.table_column_name) || ' IS NOT NULL;';
  END LOOP;
END;
$$ LANGUAGE plpgsql;



CREATE MATERIALIZED VIEW categorical_variables AS
SELECT * FROM switrs_get_categorical_variables();







create materialized view categorical_variable_tab_col as
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('collisions', 'victims', 'parties')
AND column_name IN ('county_city_location', 'county_location', 'weather_1', 'location_type', 'collision_severity', 'primary_collision_factor', 'pcf_violation_category', 'hit_and_run', 'type_of_collision', 'motor_vehicle_involved_with', 'pedestrian_action', 'road_surface', 'road_condition_1', 'lighting', 'control_device', 'statewide_vehicle_type_at_fault', 'party_type', 'party_sex', 'party_sobriety', 'party_drug_physical', 'party_safety_equipment_1', 'cellphone_use_type', 'oaf_violation_category', 'movement_preceding_collision', 'vehicle_make', 'statewide_vehicle_type', 'chp_vehicle_type_towing', 'party_race', 'victim_role', 'victim_sex', 'victim_degree_of_injury', 'victim_seating_position', 'victim_safety_equipment_1', 'victim_ejected')
AND data_type NOT IN ('integer', 'bigint', 'smallint', 'decimal', 'numeric', 'real', 'double precision', 'serial', 'bigserial');


select * from categorical_variable_tab_col


CREATE OR REPLACE FUNCTION create_individual_category_views()
RETURNS void AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT table_name, column_name FROM categorical_variable_tab_col
    LOOP
        EXECUTE format($fmt$
            CREATE MATERIALIZED VIEW %I AS
            SELECT DISTINCT %I AS category
            FROM %I
        $fmt$, 'categories_' || r.table_name || '_' || r.column_name || '_mv', r.column_name, r.table_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- To use the function to create the views
SELECT create_individual_category_views();




CREATE OR REPLACE FUNCTION create_joint_probability_mv(
    table_name TEXT,
    column1 TEXT,
    column2 TEXT
)
RETURNS VOID AS $$
DECLARE
    view_name TEXT;
    short_table_name TEXT;
    short_column1 TEXT;
    short_column2 TEXT;
BEGIN
    -- Shorten the table and column names to ensure the view name length is within limits
    short_table_name := LEFT(table_name, 10);
    short_column1 := LEFT(column1, 10);
    short_column2 := LEFT(column2, 10);
    
    -- Construct the materialized view name
    view_name := format('jp_%s_%s_%s_mv', short_table_name, short_column1, short_column2);
    
    -- Drop the materialized view if it already exists
    EXECUTE format('DROP MATERIALIZED VIEW IF EXISTS %I', view_name);
    
    -- Create the materialized view with the joint probability calculations
    EXECUTE format(
        'CREATE MATERIALIZED VIEW %I AS
         SELECT %I AS value1, %I AS value2, COUNT(*)::FLOAT / (SELECT COUNT(*) FROM %I) AS joint_probability
         FROM %I
         GROUP BY %I, %I',
        view_name, column1, column2, table_name, table_name, column1, column2
    );
END;
$$ LANGUAGE plpgsql;



SELECT create_joint_probability_mv('collisions', 'collision_severity', 'primary_collision_factor');

SELECT create_joint_probability_mv('collisions', 'hit_and_run', 'type_of_collision');

SELECT create_joint_probability_mv('collisions', 'weather_1', 'road_surface');

SELECT create_joint_probability_mv('collisions', 'lighting', 'control_device');

SELECT create_joint_probability_mv('parties', 'party_sobriety', 'party_drug_physical');

SELECT create_joint_probability_mv('victims', 'victim_degree_of_injury', 'victim_safety_equipment_1');



CREATE OR REPLACE FUNCTION create_conditional_probability_mv(
    table_name TEXT,
    column1 TEXT,
    column2 TEXT
)
RETURNS VOID AS $$
DECLARE
    view_name TEXT;
    short_table_name TEXT;
    short_column1 TEXT;
    short_column2 TEXT;
BEGIN
    -- Shorten the table and column names to ensure the view name length is within limits
    short_table_name := LEFT(table_name, 10);
    short_column1 := LEFT(column1, 10);
    short_column2 := LEFT(column2, 10);
    
    -- Construct the materialized view name
    view_name := format('cp_%s_%s_given_%s_mv', short_table_name, short_column1, short_column2);
    
    -- Drop the materialized view if it already exists
    EXECUTE format('DROP MATERIALIZED VIEW IF EXISTS %I', view_name);
    
    -- Create the materialized view with the conditional probability calculations
    EXECUTE format(
        'CREATE MATERIALIZED VIEW %I AS
         SELECT %I AS value1, %I AS value2,
                COUNT(*)::FLOAT / SUM(COUNT(*)) OVER (PARTITION BY %I) AS conditional_probability
         FROM %I
         GROUP BY %I, %I',
        view_name, column1, column2, column2, table_name, column1, column2
    );
END;
$$ LANGUAGE plpgsql;







SELECT create_conditional_probability_mv('collisions', 'collision_severity', 'primary_collision_factor');

SELECT create_conditional_probability_mv('collisions', 'hit_and_run', 'type_of_collision');

SELECT create_conditional_probability_mv('collisions', 'weather_1', 'road_surface');

SELECT create_conditional_probability_mv('collisions', 'lighting', 'control_device');

SELECT create_conditional_probability_mv('parties', 'party_sobriety', 'party_drug_physical');

SELECT create_conditional_probability_mv('victims', 'victim_degree_of_injury', 'victim_safety_equipment_1');



































































 
 