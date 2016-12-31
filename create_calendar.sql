create table project_a.dim_calendar
(
greg_d date primary key,
greg_d_i int,
greg_d_n varchar(20),
cal_wk_beg_d date,
cal_wk_end_d date,
cal_wk_i int,
cal_mo_beg_d date,
cal_mo_end_d date,
cal_mo_i int,
cal_mo_n varchar(20),
cal_yr_i int
);


/*
To populate greg_d on the calendar table you will need to create a dummy table with 10 values.
Do a self cross join of the dummy table until it meets your date range as the the number of rows
returned will be 10 to the power of n. Each self cross join below will increase the power of n by 1.
So in the example below, the number of rows that will be returned is 10 to the power of 5 or 100K rows.
(10, 100, 1000, 10000, 100000). The 11327 is used as a filter to determine how many days do we want
the date range to expand from '2010-01-01'.
*/

CREATE TABLE project_a.ints ( i tinyint );
 
INSERT INTO project_a.ints VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
 
INSERT INTO project_a.dim_Calendar (greg_d)
SELECT DATE('2010-01-01') + INTERVAL a.i*10000 + b.i*1000 + c.i*100 + d.i*10 + e.i DAY
FROM project_a.ints a 
JOIN project_a.ints b 
JOIN project_a.ints c 
JOIN project_a.ints d 
JOIN project_a.ints e
WHERE (a.i*10000 + b.i*1000 + c.i*100 + d.i*10 + e.i) <= 11327
ORDER BY 1;



UPDATE project_a.dim_calendar
set 
greg_d_i = dayofyear(greg_d),
greg_d_n = dayname(greg_d),
/*cal_wk_beg_d ,
cal_wk_end_d ,*/
cal_wk_i = week(greg_d, 2), /*2 indicates 1st week starts on a Sunday/*
/*cal_mo_beg_d ,
cal_mo_end_d ,*/
cal_mo_i = month(greg_d),
cal_mo_n = monthname(greg_d),
cal_yr_i = year(greg_d);




/*Update cal_mo_beg_d and cal_mo_end_d*/

update project_a.dim_calendar dc,
(
select min(greg_d) as cal_mo_beg_d, max(greg_d) as cal_mo_end_d, cal_mo_i, cal_yr_i
from project_a.dim_calendar
group by cal_mo_i, cal_yr_i
) X

set dc.cal_mo_beg_d = x.cal_mo_beg_d,
	dc.cal_mo_end_d = x.cal_mo_end_d
where dc.cal_mo_i = x.cal_mo_i
and dc.cal_yr_i = x.cal_yr_i;


/*Update cal_wk_beg_d and cal_wk_end_d*/

update project_a.dim_calendar dc,
(
select 
greg_d as cal_wk_beg_d,  
DATE_ADD(greg_d, INTERVAL 6 DAY) as cal_wk_end_d, 
cal_wk_i, cal_yr_i
from project_a.dim_calendar
where greg_d_n = 'Sunday'
group by greg_d, cal_wk_i, cal_yr_i
) X

set dc.cal_wk_beg_d = x.cal_wk_beg_d,
	dc.cal_wk_end_d = x.cal_wk_end_d
where dc.greg_d between x.cal_wk_beg_d and x.cal_wk_end_d;


/*Get sample records to validate*/ 

select * from project_a.dim_calendar
where cal_yr_i in (2015, 2016)
order by greg_d;
