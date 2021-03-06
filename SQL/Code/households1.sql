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

--rozkład głosów dla top 5 kandydatów - czas dojazdu do pracy
with candidates as
(
select candidate,
sum(votes) as all_votes
from results_households rh
group by candidate
order by 2 desc
limit 5
)
, percentyle as 
(
select 
percentile_disc(0.1) within group(order by time_to_work) as p_10,
percentile_disc(0.25) within group(order by time_to_work) as p_25,
percentile_disc(0.5) within group(order by time_to_work) as p_50,
percentile_disc(0.75) within group(order by time_to_work) as p_75,
percentile_disc(0.9) within group(order by time_to_work) as p_90
from results_households rh
)
, sumy as
(
select distinct 
rh.candidate,
sum(rh.votes) filter(where time_to_work<p.p_10) as p10,
sum(rh.votes) filter(where time_to_work>=p.p_10 and time_to_work <p.p_25) as p10_25,
sum(rh.votes) filter(where time_to_work>=p.p_25 and time_to_work <p.p_50) as p25_50,
sum(rh.votes) filter(where time_to_work>=p.p_50 and time_to_work <p.p_75) as p50_75,
sum(rh.votes) filter(where time_to_work>=p.p_75 and time_to_work <p.p_90) as p75_90,
sum(rh.votes) filter(where time_to_work>= p.p_90) as p90
from results_households rh
join candidates c on rh.candidate=c.candidate
cross join percentyle p
group by rh.candidate
)
select 
c.candidate,
round(s.p10::decimal/c.all_votes *100,2) as per10,
round(s.p10_25::decimal/c.all_votes *100,2) as per10_25,
round(s.p25_50::decimal/c.all_votes *100,2) as per25_50,
round(s.p50_75::decimal/c.all_votes *100,2) as per50_75,
round(s.p75_90::decimal/c.all_votes *100,2) as per75_90,
round(s.p90::decimal/c.all_votes *100,2) as per90
from candidates c
join sumy s on c.candidate=s.candidate;


--rozkład głosów dla top 5 kandydatów - ilość mieszkańców na 1 milę kw

select 
unnest(array[0.5,0.75,0.9,0.95,0.99]) as kwantyle,
unnest(percentile_disc(array[0.5,0.75,0.9,0.95,0.99]) within group(order by pop_per_sq_mile)) as czas
from results_households rh;


with candidates as
(
select candidate,
sum(votes) as all_votes
from results_households rh
group by candidate
order by 2 desc
limit 5
)
, percentyle as 
(
select 
percentile_disc(0.5) within group(order by pop_per_sq_mile) as p_10,
percentile_disc(0.75) within group(order by pop_per_sq_mile) as p_25,
percentile_disc(0.9) within group(order by pop_per_sq_mile) as p_50,
percentile_disc(0.95) within group(order by pop_per_sq_mile) as p_75,
percentile_disc(0.99) within group(order by pop_per_sq_mile) as p_90
from results_households rh
)
, sumy as
(
select distinct 
rh.candidate,
sum(rh.votes) filter(where pop_per_sq_mile<p.p_10) as p10,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_10 and pop_per_sq_mile <p.p_25) as p10_25,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_25 and pop_per_sq_mile <p.p_50) as p25_50,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_50 and pop_per_sq_mile <p.p_75) as p50_75,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_75 and pop_per_sq_mile <p.p_90) as p75_90,
sum(rh.votes) filter(where pop_per_sq_mile>= p.p_90) as p90
from results_households rh
join candidates c on rh.candidate=c.candidate
cross join percentyle p
group by rh.candidate
)
select 
c.candidate,
round(s.p10::decimal/c.all_votes *100,2) as per10,
round(s.p10_25::decimal/c.all_votes *100,2) as per10_25,
round(s.p25_50::decimal/c.all_votes *100,2) as per25_50,
round(s.p50_75::decimal/c.all_votes *100,2) as per50_75,
round(s.p75_90::decimal/c.all_votes *100,2) as per75_90,
round(s.p90::decimal/c.all_votes *100,2) as per90
from candidates c
join sumy s on c.candidate=s.candidate;

--rozkład głosów ze zmienionym podziałem liczby mieszkańców
select 
unnest(array[0.1,0.25,0.5,0.75,0.9]) as kwantyle,
unnest(percentile_disc(array[0.1,0.25,0.5,0.75,0.9]) within group(order by pop_per_sq_mile)) as czas
from results_households rh;


with candidates as
(
select candidate,
sum(votes) as all_votes
from results_households rh
group by candidate
order by 2 desc
limit 5
)
, percentyle as 
(
select 
percentile_disc(0.1) within group(order by pop_per_sq_mile) as p_10,
percentile_disc(0.25) within group(order by pop_per_sq_mile) as p_25,
percentile_disc(0.5) within group(order by pop_per_sq_mile) as p_50,
percentile_disc(0.75) within group(order by pop_per_sq_mile) as p_75,
percentile_disc(0.9) within group(order by pop_per_sq_mile) as p_90
from results_households rh
)
, sumy as
(
select distinct 
rh.candidate,
sum(rh.votes) filter(where pop_per_sq_mile<p.p_10) as p10,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_10 and pop_per_sq_mile <p.p_25) as p10_25,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_25 and pop_per_sq_mile <p.p_50) as p25_50,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_50 and pop_per_sq_mile <p.p_75) as p50_75,
sum(rh.votes) filter(where pop_per_sq_mile>=p.p_75 and pop_per_sq_mile <p.p_90) as p75_90,
sum(rh.votes) filter(where pop_per_sq_mile>= p.p_90) as p90
from results_households rh
join candidates c on rh.candidate=c.candidate
cross join percentyle p
group by rh.candidate
)
select 
c.candidate,
round(s.p10::decimal/c.all_votes *100,2) as per10,
round(s.p10_25::decimal/c.all_votes *100,2) as per10_25,
round(s.p25_50::decimal/c.all_votes *100,2) as per25_50,
round(s.p50_75::decimal/c.all_votes *100,2) as per50_75,
round(s.p75_90::decimal/c.all_votes *100,2) as per75_90,
round(s.p90::decimal/c.all_votes *100,2) as per90
from candidates c
join sumy s on c.candidate=s.candidate;

--rozkład głosów dla top 5 kandydatów - ilość mieszkańców w na gosp dom
with candidates as
(
select candidate,
sum(votes) as all_votes
from results_households rh
group by candidate
order by 2 desc
limit 5
)
, percentyle as 
(
select 
percentile_disc(0.1) within group(order by p_per_households) as p_10,
percentile_disc(0.25) within group(order by p_per_households) as p_25,
percentile_disc(0.5) within group(order by p_per_households) as p_50,
percentile_disc(0.75) within group(order by p_per_households) as p_75,
percentile_disc(0.9) within group(order by p_per_households) as p_90
from results_households rh
)
, sumy as
(
select distinct 
rh.candidate,
sum(rh.votes) filter(where p_per_households<p.p_10) as p10,
sum(rh.votes) filter(where p_per_households>=p.p_10 and p_per_households <p.p_25) as p10_25,
sum(rh.votes) filter(where p_per_households>=p.p_25 and p_per_households <p.p_50) as p25_50,
sum(rh.votes) filter(where p_per_households>=p.p_50 and p_per_households <p.p_75) as p50_75,
sum(rh.votes) filter(where p_per_households>=p.p_75 and p_per_households <p.p_90) as p75_90,
sum(rh.votes) filter(where p_per_households>= p.p_90) as p90
from results_households rh
join candidates c on rh.candidate=c.candidate
cross join percentyle p
group by rh.candidate
)
select 
c.candidate,
round(s.p10::decimal/c.all_votes *100,2) as per10,
round(s.p10_25::decimal/c.all_votes *100,2) as per10_25,
round(s.p25_50::decimal/c.all_votes *100,2) as per25_50,
round(s.p50_75::decimal/c.all_votes *100,2) as per50_75,
round(s.p75_90::decimal/c.all_votes *100,2) as per75_90,
round(s.p90::decimal/c.all_votes *100,2) as per90
from candidates c
join sumy s on c.candidate=s.candidate;

--rozkład głosów dla top 5 kandydatów - właściciele domów
with candidates as
(
select candidate,
sum(votes) as all_votes
from results_households rh
group by candidate
order by 2 desc
limit 5
)
, percentyle as 
(
select 
percentile_disc(0.1) within group(order by homeownership) as p_10,
percentile_disc(0.25) within group(order by homeownership) as p_25,
percentile_disc(0.5) within group(order by homeownership) as p_50,
percentile_disc(0.75) within group(order by homeownership) as p_75,
percentile_disc(0.9) within group(order by homeownership) as p_90
from results_households rh
)
, sumy as
(
select distinct 
rh.candidate,
sum(rh.votes) filter(where homeownership<p.p_10) as p10,
sum(rh.votes) filter(where homeownership>=p.p_10 and homeownership <p.p_25) as p10_25,
sum(rh.votes) filter(where homeownership>=p.p_25 and homeownership <p.p_50) as p25_50,
sum(rh.votes) filter(where homeownership>=p.p_50 and homeownership <p.p_75) as p50_75,
sum(rh.votes) filter(where homeownership>=p.p_75 and homeownership <p.p_90) as p75_90,
sum(rh.votes) filter(where homeownership>= p.p_90) as p90
from results_households rh
join candidates c on rh.candidate=c.candidate
cross join percentyle p
group by rh.candidate
)
select 
c.candidate,
round(s.p10::decimal/c.all_votes *100,2) as per10,
round(s.p10_25::decimal/c.all_votes *100,2) as per10_25,
round(s.p25_50::decimal/c.all_votes *100,2) as per25_50,
round(s.p50_75::decimal/c.all_votes *100,2) as per50_75,
round(s.p75_90::decimal/c.all_votes *100,2) as per75_90,
round(s.p90::decimal/c.all_votes *100,2) as per90
from candidates c
join sumy s on c.candidate=s.candidate;















