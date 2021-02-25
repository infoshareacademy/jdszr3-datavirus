--stworzenie widoku dla wybranych współczynników dotyczących sytuacji mieszkaniowej
create view county_facts_households as
select 
fips,
area_name,
state_abbreviation,
PST045214 as population_2014,
SEX255214 as female,
100-SEX255214 as male,
LFE305213 as time_to_work,
HSG010214 as house_units,
HSD410213 as households,
HSD310213 as p_per_households,
HSG445213 as homeownership,
100-HSG445213 as non_homeownership,
LND110210 as land_area,
POP060210 as pop_per_sq_mile
from county_facts cf;

--stworzenie tabeli na potrzeby przeprowadzenia analizy
-- powstałej z połączenia wyników i współczynników
create table results_households as
select pr.*,
area_name,
population_2014,
female,
 male,
time_to_work,
 house_units,
 households,
 p_per_households,
 homeownership,
 non_homeownership,
 land_area,
 pop_per_sq_mile
from primary_results pr
join county_facts_households cfh on pr.fips=cfh.fips;


  /* Wstępna analiza danych*/
--top 5 stanów z największą i najmniejszą populacją
select  distinct state,
sum(population_2014) over (partition by state)
from results_households rh
group by state, population_2014
order by 2 desc
limit 5;

select  distinct state,
sum(population_2014) over (partition by state)
from results_households rh
group by state, population_2014
order by 2
limit 5;

--Rozkład głosów ze względu na czas dojazdu do pracy

--sprawdzenie kwantyli dla czasu dojazdu
select 
unnest(array[0.1,0.25,0.5,0.75,0.9]) as kwantyle,
unnest(percentile_disc(array[0.1,0.25,0.5,0.75,0.9]) within group(order by time_to_work)) as czas
from results_households rh;
--5 kandydatów z największą liczbą głosów
create or replace view candidate as
select candidate,
sum(votes) as all_votes
from results_households rh
group by candidate
order by 2 desc
limit 5;


--rozkład głosów dla kwantyla 0.1
with p0_10 as(
select 
rh.candidate,
round(sum(votes)::decimal/c.all_votes *100,2) as perc_0_10
from results_households rh
join candidate c on rh.candidate=c.candidate
where time_to_work < (select percentile_disc(0.1) within group(order by time_to_work) from results_households rh)
group by rh.candidate, c.all_votes)
, p10_25 as(  --rozkład głosów dla przedziału 0.1-0.25
select 
rh.candidate,
round(sum(votes)::decimal/c.all_votes *100,2) as perc_10_25
from results_households rh
join candidate c on rh.candidate=c.candidate
where time_to_work >= (select percentile_disc(0.1) within group(order by time_to_work) from results_households rh) 
and time_to_work <
(select percentile_disc(0.25) within group(order by time_to_work) from results_households rh) 
group by rh.candidate, c.all_votes)
, p25_50 as (--rozkład głosów dla przedziału 0.25-0.5
select 
rh.candidate,
round(sum(votes)::decimal/c.all_votes *100,2) as perc_25_50
from results_households rh
join candidate c on rh.candidate=c.candidate
where time_to_work >= (select percentile_disc(0.25) within group(order by time_to_work) from results_households rh) 
and time_to_work <
(select percentile_disc(0.5) within group(order by time_to_work) from results_households rh) 
group by rh.candidate, c.all_votes)
, p50_75 as (--rozkład głosów dla przedziału 0.5-0.75
select 
rh.candidate,
round(sum(votes)::decimal/c.all_votes *100,2) as perc_50_75
from results_households rh
join candidate c on rh.candidate=c.candidate
where time_to_work >= (select percentile_disc(0.5) within group(order by time_to_work) from results_households rh) 
and time_to_work <
(select percentile_disc(0.75) within group(order by time_to_work) from results_households rh) 
group by rh.candidate, c.all_votes)
, p75_90 as ( --rozkład głosów dla przedziału 0.75-0.9
select 
rh.candidate,
round(sum(votes)::decimal/c.all_votes *100,2) as perc_75_90
from results_households rh
join candidate c on rh.candidate=c.candidate
where time_to_work >= (select percentile_disc(0.75) within group(order by time_to_work) from results_households rh) 
and time_to_work <
(select percentile_disc(0.9) within group(order by time_to_work) from results_households rh) 
group by rh.candidate, c.all_votes)
, p_90 as (--rozkład głosów dla kwantyla 0.9
select 
rh.candidate,
round(sum(votes)::decimal/c.all_votes *100,2) as perc_90
from results_households rh
join candidate c on rh.candidate=c.candidate
where time_to_work >= (select percentile_disc(0.9) within group(order by time_to_work) from results_households rh)
group by rh.candidate, c.all_votes
)
select 
p0_10.*,
p10_25.perc_10_25,
p25_50.perc_25_50,
p50_75.perc_50_75,
p75_90.perc_75_90,
p_90.perc_90
from p0_10
join p10_25 on p0_10.candidate=p10_25.candidate
join p25_50 on p0_10.candidate=p25_50.candidate
join p50_75 on p0_10.candidate=p50_75.candidate
join p75_90 on p0_10.candidate=p75_90.candidate
join p_90 on p0_10.candidate=p_90.candidate;



















