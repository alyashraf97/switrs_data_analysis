-- public.case_ids definition

-- Drop table

-- DROP TABLE public.case_ids;

CREATE TABLE public.case_ids (
	case_id numeric NULL,
	db_year numeric NULL
);


-- public.collisions definition

-- Drop table

-- DROP TABLE public.collisions;

CREATE TABLE public.collisions (
	case_id numeric NULL,
	jurisdiction int8 NULL,
	officer_id varchar(255) NULL,
	reporting_district varchar(255) NULL,
	chp_shift varchar(255) NULL,
	population varchar(255) NULL,
	county_city_location int8 NULL,
	county_location varchar(255) NULL,
	special_condition int8 NULL,
	beat_type varchar(255) NULL,
	chp_beat_type varchar(255) NULL,
	city_division_lapd varchar(255) NULL,
	chp_beat_class varchar(255) NULL,
	beat_number varchar(255) NULL,
	primary_road varchar(255) NULL,
	secondary_road varchar(255) NULL,
	distance float4 NULL,
	direction varchar(255) NULL,
	"intersection" int8 NULL,
	weather_1 varchar(255) NULL,
	weather_2 varchar(255) NULL,
	state_highway_indicator int8 NULL,
	caltrans_county varchar(255) NULL,
	caltrans_district int8 NULL,
	state_route int8 NULL,
	route_suffix varchar(255) NULL,
	postmile_prefix varchar(255) NULL,
	postmile float4 NULL,
	location_type varchar(255) NULL,
	ramp_intersection varchar(255) NULL,
	side_of_highway varchar(255) NULL,
	tow_away int8 NULL,
	collision_severity varchar(255) NULL,
	killed_victims int8 NULL,
	injured_victims int8 NULL,
	party_count int8 NULL,
	primary_collision_factor varchar(255) NULL,
	pcf_violation_code varchar(255) NULL,
	pcf_violation_category varchar(255) NULL,
	pcf_violation int8 NULL,
	pcf_violation_subsection varchar(255) NULL,
	hit_and_run varchar(255) NULL,
	type_of_collision varchar(255) NULL,
	motor_vehicle_involved_with varchar(255) NULL,
	pedestrian_action varchar(255) NULL,
	road_surface varchar(255) NULL,
	road_condition_1 varchar(255) NULL,
	road_condition_2 varchar(255) NULL,
	lighting varchar(255) NULL,
	control_device varchar(255) NULL,
	chp_road_type varchar(255) NULL,
	pedestrian_collision int8 NULL,
	bicycle_collision int8 NULL,
	motorcycle_collision int8 NULL,
	truck_collision int8 NULL,
	not_private_property int8 NULL,
	alcohol_involved int8 NULL,
	statewide_vehicle_type_at_fault varchar(255) NULL,
	chp_vehicle_type_at_fault varchar(255) NULL,
	severe_injury_count int8 NULL,
	other_visible_injury_count int8 NULL,
	complaint_of_pain_injury_count int8 NULL,
	pedestrian_killed_count int8 NULL,
	pedestrian_injured_count int8 NULL,
	bicyclist_killed_count int8 NULL,
	bicyclist_injured_count int8 NULL,
	motorcyclist_killed_count int8 NULL,
	motorcyclist_injured_count int8 NULL,
	primary_ramp varchar(255) NULL,
	secondary_ramp varchar(255) NULL,
	latitude float4 NULL,
	longitude float4 NULL,
	collision_date varchar(255) NULL,
	collision_time varchar(255) NULL,
	process_date varchar(255) NULL
);


-- public.parties definition

-- Drop table

-- DROP TABLE public.parties;

CREATE TABLE public.parties (
	id numeric NULL,
	case_id numeric NULL,
	party_number int4 NULL,
	party_type varchar(50) NULL,
	at_fault int4 NULL,
	party_sex varchar(50) NULL,
	party_age int4 NULL,
	party_sobriety varchar(255) NULL,
	party_drug_physical varchar(255) NULL,
	direction_of_travel varchar(255) NULL,
	party_safety_equipment_1 varchar(255) NULL,
	party_safety_equipment_2 varchar(255) NULL,
	financial_responsibility varchar(255) NULL,
	hazardous_materials varchar(255) NULL,
	cellphone_in_use int4 NULL,
	cellphone_use_type varchar(255) NULL,
	school_bus_related varchar(255) NULL,
	oaf_violation_code varchar(255) NULL,
	oaf_violation_category varchar(255) NULL,
	oaf_violation_section int4 NULL,
	oaf_violation_suffix varchar(255) NULL,
	other_associate_factor_1 varchar(255) NULL,
	other_associate_factor_2 varchar(255) NULL,
	party_number_killed int4 NULL,
	party_number_injured int4 NULL,
	movement_preceding_collision varchar(255) NULL,
	vehicle_year int4 NULL,
	vehicle_make varchar(255) NULL,
	statewide_vehicle_type varchar(255) NULL,
	chp_vehicle_type_towing varchar(255) NULL,
	chp_vehicle_type_towed varchar(255) NULL,
	party_race varchar(255) NULL
);


-- public.victims definition

-- Drop table

-- DROP TABLE public.victims;

CREATE TABLE public.victims (
	id int8 NULL,
	case_id numeric NULL,
	party_number numeric NULL,
	victim_role varchar(255) NULL,
	victim_sex varchar(50) NULL,
	victim_age int4 NULL,
	victim_degree_of_injury varchar(255) NULL,
	victim_seating_position varchar(255) NULL,
	victim_safety_equipment_1 varchar(255) NULL,
	victim_safety_equipment_2 varchar(255) NULL,
	victim_ejected varchar(255) NULL
);




