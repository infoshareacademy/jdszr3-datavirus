--Zestawienie county_facts_dictionary dla pkt 9-16 + 37-43 (rasa + wlasciciele firm)																							
create view v_race_owners as															
select 	* 																				
from 	county_facts_dictionary cfd 													
where 	column_name like 'RHI125214'													
or 		column_name like 'RHI225214'												    
or 		column_name like 'RHI325214'
or 		column_name like 'RHI425214'
or 		column_name like 'RHI525214'
or 		column_name like 'RHI625214'
or 		column_name like 'RHI725214'
or 		column_name like 'RHI825214'
or 		column_name like 'SBO001207'
or 		column_name like 'SBO315207'
or 		column_name like 'SBO115207'
or 		column_name like 'SBO215207'
or 		column_name like 'SBO515207'
or 		column_name like 'SBO415207'
or 		column_name like 'SBO015207';
--end

--Przygotowanie widoku county_facts pod katem pkt 9-16 + 37-43 (rasa + wlasciciele firm) wraz wyjasnieniem znaczenia porzadanych kolumn
create view v_race as
select 	fips
,		area_name
,		state_abbreviation 
,		PST045214 as "Population, 2014 estimate"
,	 	RHI125214 as "White alone, percent, 2014"
, 		RHI225214 as "Black or African American alone, percent, 2014"
, 		RHI325214 as "American Indian and Alaska Native alone, percent, 2014"
, 		RHI425214 as "Asian alone, percent, 2014"
, 		RHI525214 as "Native Hawaiian and Other Pacific Islander alone, percent, 2014"
, 		RHI625214 as "Two or More Races, percent, 2014"
, 		RHI725214 as "Hispanic or Latino, percent, 2014"
, 		RHI825214 as "White alone, not Hispanic or Latino, percent, 2014"
from 	county_facts cf;
--end

--Wyliczenie procentowego udzialu bialych przedsiebiorcow - przygotowanie widoku
create view v_owners_with_white as
select 	fips
,		area_name
,		state_abbreviation 
,		PST045214 as "Population, 2014 estimate"
, 		SBO001207 as "Total number of firms, 2007"
,		100 - SBO315207 - SBO115207 - SBO215207 - SBO515207 - SBO415207 as "White-owned firms, percent, 2007"  
, 		SBO315207 as "Black-owned firms, percent, 2007"
, 		SBO115207 as "American Indian- and Alaska Native-owned firms, percent, 2007"
, 		SBO215207 as "Asian-owned firms, percent, 2007"
, 		SBO515207 as "Native Hawaiian- and Other Pacific Islander-owned firms, percent, 2007"
, 		SBO415207 as "Hispanic-owned firms, percent, 2007"
from 	county_facts cf;
--end

--Sprawdzenie sumy glosow i sredniej frakcji po stanie by.Dagmara /zmodyfikowany (sum as "votes_sum", avg deleted, row_number deleted)
create view v_wyniki_po_stanach_v2 as
select 	pr.state
,	   	pr.candidate
,	   	sum(pr.votes) as "votes_sum"
from 	primary_results pr
group by 1, 2
order by 1, 3 desc;
--end

--Wygrani po stanach by Dagmara
create view v_wygrani_po_stanach as
select 	* 
from 	v_wyniki_po_stanach
where row_number = 1;
--end

--Test wstêpny - przygotowanie wskaznikow przedsiebiorczosci
select 	* 
,		round("White-owned firms, percent, 2007" / "White alone, percent, 2014", 2) as "business_index"
,		round((("White-owned firms, percent, 2007" / "White alone, percent, 2014")/100 * votes),2) as "business_index_points"
from 	v_race
join	v_owners_with_white oww on v_race.fips = oww.fips 
join	primary_results pr on v_race.fips = pr.fips 
order by round((("White-owned firms, percent, 2007" / "White alone, percent, 2014")/100 * votes),2) desc;
--end

--Wskazniki przedsiebiorczosci dla wszystkich ras - wersja koncowa 
create view v_business_index as 
select 	vr.area_name
,		vr."White alone, percent, 2014"
,		oww."White-owned firms, percent, 2007"
,		round("White-owned firms, percent, 2007" / "White alone, percent, 2014", 2) as "white_business_index"
,		vr."Black or African American alone, percent, 2014"
,		oww."Black-owned firms, percent, 2007"
,		round("Black-owned firms, percent, 2007" / "Black or African American alone, percent, 2014", 2) as "black_business_index"
,		vr."Asian alone, percent, 2014"
,		oww."Asian-owned firms, percent, 2007"
,		round("Asian-owned firms, percent, 2007" / "Asian alone, percent, 2014", 2) as "asian_business_index"
,		vr."Hispanic or Latino, percent, 2014"
,		oww."Hispanic-owned firms, percent, 2007"
,		round("Hispanic-owned firms, percent, 2007" / "Hispanic or Latino, percent, 2014", 2) as "latino_business_index"
from 	v_race vr
join	v_owners_with_white oww on vr.fips = oww.fips 
where   "White alone, percent, 2014" <> 0
and		"Black or African American alone, percent, 2014" <> 0
and		"Asian alone, percent, 2014" <> 0
and		"Hispanic or Latino, percent, 2014" <> 0
and 	vr.fips % 1000 = 0;
--end

--Przygotowanie zestawienia rankingu business_index
create view v_business_index_scores as
select 	area_name
,		white_business_index
,		black_business_index
,		asian_business_index
,		latino_business_index
from 	v_business_index;
--end

--Przygotowanie pomocniczego widoki przynaleznosci kandydatow do partii
create view v_party as
select	distinct candidate
,		party 
from	primary_results pr 
order by 1;
--end

--Zestawienie zwyciezcow w poszegolnych stanach z uwzglednieniem wskaznikow business_index i business_points
select 	ws.state
,		ws.candidate
,		pa.party
,		ws."sum"
--,		bi.white_business_index
,		round((bi.white_business_index  *  ws."sum" / 100), 2) as "white_business_points"
--,		bi.black_business_index
,		round((bi.black_business_index  *  ws."sum" / 100), 2) as "black_business_points"
--,		bi.asian_business_index
,		round((bi.asian_business_index  *  ws."sum" / 100), 2) as "asian_business_points"
--,		bi.latino_business_index
,		round((bi.latino_business_index  *  ws."sum" / 100), 2) as "latino_business_points"
from v_wygrani_po_stanach ws
join v_business_index_scores bi on ws.state = bi.area_name 
join party pa on pa.candidate = ws.candidate
order by 5 desc;




