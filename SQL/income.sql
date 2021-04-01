-- pomocnicze zapytania -- 
select * from county_facts;
select * from primary_results;
select * from county_facts_dictionary;

select * from primary_results
where county = 'Autauga'
order by votes desc;

	-- unikalni kandydaci
select distinct(candidate) 
from primary_results; 
-- koniec pomocniczych zapytań --

/* create extension tablefunc;
select * 
from crosstab('select candidate, state, sum(votes) FROM primary_results group by 1,2')
as 
final_results(candidate text, Alabama numeric); */

-- ogólna liczba głosów per kandydat -- 
select distinct(candidate), sum(votes)
from primary_results
group by candidate
order by 2 desc;

-- suma głosów --
select sum(votes)
from primary_results;

-- kolejność kandydatów w poszczególnych stanach -- 
create view v_wygrani_stany as 
select state, 
       candidate, 
       sum(votes) as suma_glosow, 
       row_number() over (partition by state order by sum(votes) DESC) as kolejnosc
from primary_results
group by candidate, state
order by state, sum(votes) desc;

select * from v_wygrani_stany;

-- dwa pierwsze miejsca w każdym stanie --  
with pomocnicza_12 as (
select state, 
       candidate, 
       sum(votes) as suma_glosow, 
       row_number() over (partition by state order by sum(votes) DESC) as kolejnosc
from primary_results
group by state, candidate
order by state, sum(votes) desc)
select state, candidate, suma_glosow, kolejnosc
from pomocnicza_12 
where kolejnosc IN (1,2); 

-- stany, w których wygrał Donald Trump --
create view v_winner_dt as (
with pomocnicza_dt as (
select state, 
       candidate, 
       sum(votes) as suma_glosow, 
       row_number() over (partition by state order by sum(votes) DESC) as kolejnosc
from primary_results
group by state, candidate
order by state, sum(votes) desc)
select state, candidate, suma_glosow, kolejnosc
from pomocnicza_dt
where kolejnosc = 1 and candidate ilike 'Donald Trump');

select * from v_winner_dt;

-- połączenie tabel - wygrane stany Donalda Trumpa i county_facts -- 
select * 
from county_facts as cf 
inner join v_winner_dt as wdt 
on cf.area_name=wdt.state;

-- stany, w których wygrała Hillary Clinton --
create view v_winner_hc as (
with pomocnicza_hc as (
select state, 
       candidate, 
       sum(votes) as suma_glosow, 
       row_number() over (partition by state order by sum(votes) DESC) as kolejnosc
from primary_results
group by state, candidate
order by state, sum(votes) desc)
select state, candidate, suma_glosow, kolejnosc
from pomocnicza_hc
where kolejnosc = 1 and candidate ilike 'Hillary Clinton');

select * from v_winner_hc;

	-- PRZEJŚCIE DO TABELI COUNTY_FACTS --

-- tabela: stany wygrane przez Trumpa i USA--
select  fips, 
        area_name, 
        state_abbreviation, 
        PST045214 as "Population, 2014 estimate",
        PST040210 as "Population, 2010 (April 1) estimates base",
		PST120214 as "Population, percent change - April 1, 2010 to July 1, 2014",
		POP010210 as "Population, 2010",
		AGE135214 as "Persons under 5 years, percent, 2014",
		AGE295214 as "Persons under 18 years, percent, 2014",
		AGE775214 as "Persons 65 years and over, percent, 2014",
		SEX255214 as "Female persons, percent, 2014",
		RHI125214 as "White alone, percent, 2014",
		RHI225214 as "Black or African American alone, percent, 2014",
		RHI325214 as "American Indian and Alaska Native alone, percent, 2014",
		RHI425214 as "Asian alone, percent, 2014",
		RHI525214 as "Native Hawaiian and Other Pacific Islander alone, percent, 2014",
		RHI625214 as "Two or More Races, percent, 2014",
		RHI725214 as "Hispanic or Latino, percent, 2014",
		RHI825214 as "White alone, not Hispanic or Latino, percent, 2014",
		POP715213 as "Living in same house 1 year & over, percent, 2009-2013",
		POP645213 as "Foreign born persons, percent, 2009-2013",
		POP815213 as "Language other than English spoken at home, pct age 5+, 2009-2013",
		EDU635213 as "High school graduate or higher, percent of persons age 25+, 2009-2013",
		EDU685213 as "Bachelor's degree or higher, percent of persons age 25+, 2009-2013",
		VET605213 as "Veterans, 2009-2013",
		LFE305213 as "Mean travel time to work (minutes), workers age 16+, 2009-2013",
		HSG010214 as "Housing units, 2014",
		HSG445213 as "Homeownership rate, 2009-2013",
		HSG096213 as "Housing units in multi-unit structures, percent, 2009-2013",
		HSG495213 as "Median value of owner-occupied housing units, 2009-2013",
		HSD410213 as "Households, 2009-2013",
		HSD310213 as "Persons per household, 2009-2013",
		INC910213 as "Per capita money income in past 12 months (2013 dollars), 2009-2013",
		INC110213 as "Median household income, 2009-2013",
		PVY020213 as "Persons below poverty level, percent, 2009-2013",
		BZA010213 as "Private nonfarm establishments, 2013",
		BZA110213 as "Private nonfarm employment,  2013",
		BZA115213 as "Private nonfarm employment, percent change, 2012-2013",
		NES010213 as "Nonemployer establishments, 2013",
		SBO001207 as "Total number of firms, 2007",
		SBO315207 as "Black-owned firms, percent, 2007",
		SBO115207 as "American Indian- and Alaska Native-owned firms, percent, 2007",
		SBO215207 as "Asian-owned firms, percent, 2007",
		SBO515207 as "Native Hawaiian- and Other Pacific Islander-owned firms, percent, 2007",
		SBO415207 as "Hispanic-owned firms, percent, 2007",
		SBO015207 as "Women-owned firms, percent, 2007",
		MAN450207 as "Manufacturers shipments, 2007 ($1,000)",
		WTN220207 as "Merchant wholesaler sales, 2007 ($1,000)",
		RTN130207 as "Retail sales, 2007 ($1,000)",
		RTN131207 as "Retail sales per capita, 2007",
		AFN120207 as "Accommodation and food services sales, 2007 ($1,000)",
		BPS030214 as "Building permits, 2014",
		LND110210 as "Land area in square miles, 2010",
		POP060210 as "Population per square mile, 2010"
from county_facts as cf 
inner join v_winner_dt as wdt 
on cf.area_name=wdt.state
union 
select * from county_facts cf2
where cf2.fips = 0
order by fips desc;

-- analogicznie dla Hilary Clinton -- 
select  fips, 
        area_name, 
        state_abbreviation, 
        PST045214 as "Population, 2014 estimate",
        PST040210 as "Population, 2010 (April 1) estimates base",
		PST120214 as "Population, percent change - April 1, 2010 to July 1, 2014",
		POP010210 as "Population, 2010",
		AGE135214 as "Persons under 5 years, percent, 2014",
		AGE295214 as "Persons under 18 years, percent, 2014",
		AGE775214 as "Persons 65 years and over, percent, 2014",
		SEX255214 as "Female persons, percent, 2014",
		RHI125214 as "White alone, percent, 2014",
		RHI225214 as "Black or African American alone, percent, 2014",
		RHI325214 as "American Indian and Alaska Native alone, percent, 2014",
		RHI425214 as "Asian alone, percent, 2014",
		RHI525214 as "Native Hawaiian and Other Pacific Islander alone, percent, 2014",
		RHI625214 as "Two or More Races, percent, 2014",
		RHI725214 as "Hispanic or Latino, percent, 2014",
		RHI825214 as "White alone, not Hispanic or Latino, percent, 2014",
		POP715213 as "Living in same house 1 year & over, percent, 2009-2013",
		POP645213 as "Foreign born persons, percent, 2009-2013",
		POP815213 as "Language other than English spoken at home, pct age 5+, 2009-2013",
		EDU635213 as "High school graduate or higher, percent of persons age 25+, 2009-2013",
		EDU685213 as "Bachelor's degree or higher, percent of persons age 25+, 2009-2013",
		VET605213 as "Veterans, 2009-2013",
		LFE305213 as "Mean travel time to work (minutes), workers age 16+, 2009-2013",
		HSG010214 as "Housing units, 2014",
		HSG445213 as "Homeownership rate, 2009-2013",
		HSG096213 as "Housing units in multi-unit structures, percent, 2009-2013",
		HSG495213 as "Median value of owner-occupied housing units, 2009-2013",
		HSD410213 as "Households, 2009-2013",
		HSD310213 as "Persons per household, 2009-2013",
		INC910213 as "Per capita money income in past 12 months (2013 dollars), 2009-2013",
		INC110213 as "Median household income, 2009-2013",
		PVY020213 as "Persons below poverty level, percent, 2009-2013",
		BZA010213 as "Private nonfarm establishments, 2013",
		BZA110213 as "Private nonfarm employment,  2013",
		BZA115213 as "Private nonfarm employment, percent change, 2012-2013",
		NES010213 as "Nonemployer establishments, 2013",
		SBO001207 as "Total number of firms, 2007",
		SBO315207 as "Black-owned firms, percent, 2007",
		SBO115207 as "American Indian- and Alaska Native-owned firms, percent, 2007",
		SBO215207 as "Asian-owned firms, percent, 2007",
		SBO515207 as "Native Hawaiian- and Other Pacific Islander-owned firms, percent, 2007",
		SBO415207 as "Hispanic-owned firms, percent, 2007",
		SBO015207 as "Women-owned firms, percent, 2007",
		MAN450207 as "Manufacturers shipments, 2007 ($1,000)",
		WTN220207 as "Merchant wholesaler sales, 2007 ($1,000)",
		RTN130207 as "Retail sales, 2007 ($1,000)",
		RTN131207 as "Retail sales per capita, 2007",
		AFN120207 as "Accommodation and food services sales, 2007 ($1,000)",
		BPS030214 as "Building permits, 2014",
		LND110210 as "Land area in square miles, 2010",
		POP060210 as "Population per square mile, 2010"
from county_facts as cf 
inner join v_winner_hc as whc 
on cf.area_name=whc.state
union 
select * from county_facts cf2
where cf2.fips = 0
order by fips desc;

-- selekcja samych stanów w ramach tabeli CTE same_stany --
with same_stany as (
          select *
          from county_facts
          where fips::text ilike '%000'
          or fips = 0)
select * from same_stany;

-- wyciągnięcie z tabeli county_facts interesujących kolumn z pełnymi nazwami--
select 		area_name, 
			PST045214 as "Population, 2014 estimate",
		    round(((100-age295214)*pst045214/100),0) as "Persons above 18 years, nominal, 2014",
			INC910213 as "Income Per Capita", 
			INC110213 as "Median Household Income", 
			PVY020213 as "Population below poverty (%)", 
			BZA010213 as "Non-farm establishments", 
			BZA110213 as "Non-farm employment", 
			BZA115213 as "Non-farm employment 2013 vs 2012", 
			NES010213 as "Nonemployer establishments"
from county_facts
where fips::text ilike '%000'
or fips = 0;

-- dostosowanie powyższego zapytania jako tabela CTE pogrupowana po stanach --
with same_stany_kategorie as (
select 		area_name as state,
            PST045214 as population,
            100-age295214 as people_above_18_perc,
            round(avg(100-age295214) over (),1) as avg_people_above_18_perc,
            round(((100-age295214)*pst045214/100),0) as people_above_18,
            AGE775214 as people_above65,
		    INC910213 as income_per_capita,
			INC110213 as median_household_income, 
			PVY020213 as pop_below_poverty_perc, 
			round((PVY020213*PST045214/100),0) as pop_below_poverty_nominal,
			BZA010213 as non_farm_establishments, 
			BZA110213 as non_farm_employment, 
			NES010213 as nonemployer_establishments
from county_facts
where fips::text ilike '%000'
   or fips = 0)
select *
from same_stany_kategorie;

-- łączenie tabel - wskaźniki i wygrane stany Trumpa -- 
with same_stany_kategorie as (
select 		area_name as state,
            PST045214 as population,
            100-age295214 as people_above_18_perc,
		    round(((100-age295214)*pst045214/100),0) as people_above_18,
		    AGE775214 as people_above65,
		    INC910213 as income_per_capita, 
			INC110213 as median_household_income, 
			PVY020213 as pop_below_poverty_perc, 
			round((PVY020213*PST045214/100),0) as pop_below_poverty_nominal,
			BZA010213 as non_farm_establishments, 
			BZA110213 as non_farm_employment, 
			NES010213 as nonemployer_establishments
from county_facts
where fips::text ilike '%000'
   or fips = 0)
select *
from same_stany_kategorie as ssk
inner join v_winner_dt as wdt
on ssk.state=wdt.state;

-- łączenie tabel - wskaźniki i wygrane stany Clinton -- 
with same_stany_kategorie as (
select 		area_name as state,
            PST045214 as population,
            100-age295214 as people_above_18_perc,
		    round(((100-age295214)*pst045214/100),0) as people_above_18,
		    AGE775214 as people_above65,
		    INC910213 as income_per_capita, 
			INC110213 as median_household_income, 
			PVY020213 as pop_below_poverty_perc, 
			round((PVY020213*PST045214/100),0) as pop_below_poverty_nominal,
			BZA010213 as non_farm_establishments, 
			BZA110213 as non_farm_employment, 
			NES010213 as nonemployer_establishments
from county_facts
where fips::text ilike '%000'
   or fips = 0)
select *
from same_stany_kategorie as ssk
inner join v_winner_hc as whc
on ssk.state=whc.state;

-- kwartyle (Q1, Q3) oraz mediana dla kluczowych wskaźników - Donald Trump --
with same_stany_kategorie as (
select 		area_name as state,
            PST045214 as population,
            100-age295214 as people_above_18_perc,
		    round(((100-age295214)*pst045214/100),0) as people_above_18,
		    AGE775214 as people_above65,
		    INC910213 as income_per_capita, 
			INC110213 as median_household_income, 
			PVY020213 as pop_below_poverty_perc, 
			round((PVY020213*PST045214/100),0) as pop_below_poverty_nominal,
			BZA010213 as non_farm_establishments, 
			BZA110213 as non_farm_employment, 
			NES010213 as nonemployer_establishments
from county_facts
where fips::text ilike '%000')
select unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by people_above_18_perc)) as above18_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by people_above65)) as above65_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by income_per_capita)) as income_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by median_household_income)) as median_income_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by pop_below_poverty_perc)) as poverty_quartiles
from same_stany_kategorie as ssk
inner join v_winner_dt as wdt
on ssk.state=wdt.state;

-- kwartyle (Q1, Q3) oraz mediana dla kluczowych wskaźników - Hillary Clinton --
with same_stany_kategorie as (
select 		area_name as state,
            PST045214 as population,
            100-age295214 as people_above_18_perc,
		    round(((100-age295214)*pst045214/100),0) as people_above_18,
		    AGE775214 as people_above65,
		    INC910213 as income_per_capita, 
			INC110213 as median_household_income, 
			PVY020213 as pop_below_poverty_perc, 
			round((PVY020213*PST045214/100),0) as pop_below_poverty_nominal,
			BZA010213 as non_farm_establishments, 
			BZA110213 as non_farm_employment, 
			NES010213 as nonemployer_establishments
from county_facts
where fips::text ilike '%000')
select unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by people_above_18_perc)) as above18_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by people_above65)) as above65_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by income_per_capita)) as income_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by median_household_income)) as median_income_quartiles,
       unnest(percentile_disc(array[0.25, 0.5, 0.75]) within group (order by pop_below_poverty_perc)) as poverty_quartiles
from same_stany_kategorie as ssk
inner join v_winner_hc as whc
on ssk.state=whc.state;

--



