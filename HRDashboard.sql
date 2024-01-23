-- TABLE JOINS

SELECT *
FROM Absenteeism_at_work a
left join compensation c
on a.ID = c.ID 
left join Reasons r
on a.Reason_for_absence = r.Number;

-- Find the healthiest employees
SELECT *
FROM Absenteeism_at_work
WHERE Social_drinker = 0 AND Social_smoker = 0
and Body_mass_index <25
and Absenteeism_time_in_hours < 
(SELECT AVG(Absenteeism_time_in_hours)
FROM Absenteeism_at_work)

--Compensation rate increase for non-smokers / budget 983,221
SELECT COUNT(*) as NonSmokers
FROM Absenteeism_at_work
WHERE Social_smoker = 0

--983221/(5*8*52*686) = 0.69 increase per hour/ $1435.2 per year 

--Optimize query
SELECT a.ID,
	   r.Reason,
	   month_of_absence,
	   body_mass_index,
	   CASE WHEN Body_mass_index <18.5 then 'Underweight'
			WHEN Body_mass_index between 18.5 and 25 then 'Healthy'
			WHEN Body_mass_index between 25 and 30 then 'Overweight'
			WHEN Body_mass_index >30 then 'Obese'
			ELSE 'Unknown' END as 'BMI_Category',
	   CASE WHEN Month_of_absence IN (12,1,2) Then 'Winter'
		    WHEN Month_of_absence IN (3,4,5) Then 'Spring'
			WHEN Month_of_absence IN (6,7,8) Then 'Summer'
			WHEN Month_of_absence IN (9,10,11) Then 'Fall'
			ELSE 'Unknown' END as Season_names,
		Month_of_absence,
		Day_of_the_week,
		Transportation_expense,
		Education,
		Son,
		Social_drinker,
		Social_smoker,
		Pet,
		Disciplinary_failure,
		Age,
		Work_load_Average_day,
		Absenteeism_time_in_hours
FROM Absenteeism_at_work a
left join compensation c
on a.ID = c.ID 
left join Reasons r
on a.Reason_for_absence = r.Number;