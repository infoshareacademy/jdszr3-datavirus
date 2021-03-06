/* Wszyscy kandydaci z liczba glosow i zajetym miejscem*/
select 
		candidate 
,		party 
,		sum(votes) as suma_głosów
,		row_number () over ( order by sum(votes) desc) as miejsce
from primary_results pr 
group by candidate, party
order by suma_głosów desc;
--Hillary Clinton, Donald Trump, Bernie Sanders

/* Głosy na Republikanów i Demokratow lacznie */
select 
		party 		
,		sum(votes)
,       row_number () over ( order by sum(votes)desc)
from primary_results pr
 group by  party; 
--Republikanie  29.098.686  , Demokraci 27.660.501


/*Podział głosów w poszczególnych stanach  */
select 
		state 
,		party 		
,		sum(votes)
,       row_number () over ( partition by state order by sum(votes)desc)
from primary_results pr
 group by state, party
order by state ; 
--Wyniki stanow i row_number


/* % udzial glosow z podzialem na stany i partie */

with stan_glosy as
(select 
		state 
,		sum(votes) as suma_glosow
from primary_results pr 
group by state 
order by suma_glosow desc)
select 
		pr.state 
,		pr.party 		
,		sum(pr.votes)
,		round(sum(pr.votes)::decimal /sg.suma_glosow *100, 2) as procent_glosow_w_danym_stanie
from primary_results pr
join stan_glosy sg on pr.state = sg.state
 group by pr.state, party, sg.suma_glosow
order by state ; 
-- Maine to 100% na Dekomratow, WAszyngton 95% Republikanie,  Colorado 100% Demokraci 

 




/* Suma fraction_votes z podzialem na miejsce w kolejnosci */
select 
		state 
,		sum(fraction_votes) as suma_fraction_votes
,		row_number () over (order by sum(fraction_votes)desc)
from primary_results pr 
group by state
order by sum(fraction_votes) desc;
--Suma Fraction votes najwieksza w Massachusetts 688.115, Texas 486.652  , Vermon 481.316 . Reszta ponizej 416.000



/* Wyniki sumy glosowan z podzialem na stany i kandydatow */
select 
		pr.candidate 
,		sum(pr.votes) 
,		cf.state_abbreviation 
,		row_number () over (partition by cf.state_abbreviation order by sum(pr.votes)desc)
from primary_results pr 
join county_facts cf on pr.fips = cf.fips
group by rollup (candidate, cf.state_abbreviation);
--Row number over partition by ladnie przedstawia wyniki kandydatow z podzialem na stany 

/* W ilu regionach( fips)  głosy otrzymali kandydaci */ 
select 
		pr.candidate 
,		count(fips)
from primary_results pr 
group by rollup (pr.candidate)
order by count(fips) desc;
--Hillary Clinton, Berni Sanders najwiecej, pozniej Ten Cruz i Donald Trump

/* min, avg, max highschool */ 

select 
		min(edu635213) as min_highschool
,		avg(edu635213) as avg_highschool
,		max(edu635213) as max_highschool
from county_facts cf; 
-- min 45 , avg 84  , max 99


/* stworzenie widoku dla tabeli z danymi primary_results oraz dwoma kolumnami dot. wyksztalcenia*/ 

CREATE VIEW public.v_edukacja
AS SELECT pr.candidate,
    pr.county,
    pr.fips,
    pr.fraction_votes,
    pr.party,
    pr.state,
    pr.state_abbreviation,
    pr.votes,
    cf.edu635213 AS "Highschool",
    cf.edu685213 AS "Bachelor"
   FROM primary_results pr
     JOIN county_facts cf ON pr.fips = cf.fips;



select * from v_edukacja ve ;


/* min, avg, max z podziałem na kandydatów*/
select 	
		ve.candidate 
,		min("Highschool") as min_highschool		
,		avg("Highschool") as avg_highschool
,		max("Highschool") as max_highschool
from v_edukacja ve
group by ve.candidate
order by avg("Highschool") desc ;




/* min, avg, max dla partii pod wzgledem wyksztalcenia highschool */
select 
		ve.party 
,		min("Highschool") as min_highschool		
,		avg("Highschool") as avg_highschool
,		max("Highschool") as max_highschool
from v_edukacja ve 
group by ve.party ;
-- min 45 , avg 83.6 do 84.2  , max 99 dla Republikan i Demokratow  . Korzysc dla Demokratow

/* min, avg, max dla stanu pod wzgledem wyksztalcenia highschool */

select  
		ve.state 
,		min("Highschool") as min_highschool		
,		avg("Highschool") as avg_highschool
,		max("Highschool") as max_highschool
from v_edukacja ve 
group by ve.state
order by avg_highschool desc ;
--Wyoming, New Hampshire, Nebraska avg miala najwyzsze w okolicach 91%

/* percentyle dla highschool */ 

select 
		 min ("Highschool") 
,		 percentile_disc(0.25) within group  (order by "Highschool") as  p_25
,		percentile_disc(0.5) within group  (order by "Highschool") as  p_5
,		percentile_disc(0.75) within group  (order by "Highschool") as  p_75
,		max("Highschool")
from v_edukacja ve ;



/* percentyle dla populacji */ 
select 
		min (cf.pop010210) 
,		percentile_disc(0.25) within group  (order by cf.pop010210) as  p_25
,		percentile_disc(0.5)  within group  (order by cf.pop010210) as  p_50
,		percentile_disc(0.75) within group  (order by cf.pop010210) as  p_75
,		percentile_disc(0.85) within group  (order by cf.pop010210) as  p_85
,		percentile_disc(0.95) within group  (order by cf.pop010210) as  p_95
,		percentile_disc(0.98) within group  (order by cf.pop010210) as  p_98
,		max(cf.pop010210)
from county_facts cf 



/*  najlepszych kandydatow na prezydenta pod wzgldem oddanych glosow */
select 
	candidate 
,	sum(votes) as wszystkie_glosy
from
v_edukacja ve 
group by candidate
order by 2 desc
limit 3
-- Hillary, Donald, Berni 


/* cross join sprawdzic jak laczy percentyle z votes */
  with percentyle as 
(
select 
		min ("Highschool") 
,		percentile_disc(0.25) within group  (order by "Highschool") as  p_25
,		percentile_disc(0.5) within group  (order by "Highschool") as  p_5
,		percentile_disc(0.75) within group  (order by "Highschool") as  p_75
,		max("Highschool")
from v_edukacja ve)
select
		votes
,		percentyle.*		
from v_edukacja ve
cross join percentyle 
where "Highschool" < percentyle.p_25
 ;




/* suma glosow dla p25, p25_50 , p50_75 , p75 */
 
with  wszystkie_glosy as
(
select 
	candidate 
,	sum(votes) as wszystkie_glosy 
from
v_edukacja ve 
group by candidate
order by 2 desc
limit 3)
, percentyle as 
(
select 
		min ("Highschool") 
,		percentile_disc(0.25) within group  (order by "Highschool") as  p_25
,		percentile_disc(0.5) within group  (order by "Highschool") as  p_5
,		percentile_disc(0.75) within group  (order by "Highschool") as  p_75
,		max("Highschool")
from v_edukacja ve
)
, glosy_p as 
(
select
	ve.candidate, 
	sum(ve.votes) filter (where "Highschool"< percentyle.p_25) as suma_25
,
	sum(ve.votes) filter (where "Highschool">= percentyle.p_25 and "Highschool" <percentyle.p_5) as suma_25_50
,
	sum(ve.votes) filter (where "Highschool">= percentyle.p_5 and "Highschool" <percentyle.p_75) as suma_50_75
,
	sum(ve.votes) filter (where "Highschool">= percentyle.p_75 ) as suma_75_wyzej
from v_edukacja ve
join wszystkie_glosy on ve.candidate = wszystkie_glosy.candidate
cross join percentyle 
group by ve.candidate
)
select 
		glosy_p.candidate 
,		glosy_p.suma_25 ::decimal /wg.wszystkie_glosy *100 as p25
,		glosy_p.suma_25_50 ::decimal /wg.wszystkie_glosy *100 as p25_50 
,		glosy_p.suma_50_75 ::decimal /wg.wszystkie_glosy *100 as p50_75
,		glosy_p.suma_75_wyzej ::decimal /wg.wszystkie_glosy *100 as p75 
from  glosy_p
join wszystkie_glosy wg  on glosy_p.candidate =wg.candidate 
 ;

--Berni    11.8  ,   15.4    , 35.9    ,36.7
--Donald   11.3  ,   18.2    , 36.0    ,34.3
--Hillary  15.9  ,   17.8    , 36.9    ,29.2

--wykres 


/* kandydaci DT, HC z podzialem na stany, plec, edukacje */ 

select 
		 pr.candidate in ('Donald Trump') as "Donald_Trump"
,		 pr.candidate in ( 'Hillary Clinton') as "Hillary_Clinton"
,		state 
,		cf.sex255214  as female
,		(100-cf.sex255214) as male
,		cf.edu635213 as "Highschool"
,		cf.edu685213 as "Bahelor"
from primary_results pr 
join county_fact cf  on pr.fips = cf.fips
group by candidate, state,  cf.sex255214 , cf.edu635213 , cf.edu685213 ;



/* Wyniki dla Bachelor */ 


/* suma glosow dla p25, p25_50 , p50_75 , p75 */
 
with  wszystkie_glosy as
(
select 
	candidate 
,	sum(votes) as wszystkie_glosy 
from
v_edukacja ve 
group by candidate
order by 2 desc
limit 3)
, percentyle as 
(
select 
		min ("Bachelor") 
,		percentile_disc(0.25) within group  (order by "Bachelor") as  p_25
,		percentile_disc(0.5) within group  (order by "Bachelor") as  p_5
,		percentile_disc(0.75) within group  (order by "Bachelor") as  p_75
,		max("Bachelor")
from v_edukacja ve
)
, glosy_p as 
(
select
	ve.candidate, 
	sum(ve.votes) filter (where "Bachelor" < percentyle.p_25) as suma_25
,
	sum(ve.votes) filter (where "Bachelor" >= percentyle.p_25 and "Bachelor" <percentyle.p_5) as suma_25_50
,
	sum(ve.votes) filter (where "Bachelor" >= percentyle.p_5 and "Bachelor" <percentyle.p_75) as suma_50_75
,
	sum(ve.votes) filter (where "Bachelor" >= percentyle.p_75 ) as suma_75_wyzej
from v_edukacja ve
join wszystkie_glosy on ve.candidate = wszystkie_glosy.candidate
cross join percentyle 
group by ve.candidate
)
select 
		glosy_p.candidate 
,		glosy_p.suma_25 ::decimal /wg.wszystkie_glosy *100 as p25
,		glosy_p.suma_25_50 ::decimal /wg.wszystkie_glosy *100 as p25_50 
,		glosy_p.suma_50_75 ::decimal /wg.wszystkie_glosy *100 as p50_75
,		glosy_p.suma_75_wyzej ::decimal /wg.wszystkie_glosy *100 as p75 
from  glosy_p
join wszystkie_glosy wg  on glosy_p.candidate =wg.candidate 
 ;

--Berni    3.5  ,   6.1    , 13.9    ,76.3
--Donald   6.7  ,  11.1    , 19.4    ,61.9
--Hillary  4.3  ,   6.0    , 14.3    ,75.2 
