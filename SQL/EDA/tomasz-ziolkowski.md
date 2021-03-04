--Który stan oddał najwięcej głosów
select
		pr.state 
,		pr.party 
,		sum(pr.votes)	
	from primary_results pr 
	group by rollup (pr.state, pr.party) 
	order by state asc, party 
;
--California, Texas, Florida

select
		pr.state 
,		pr.state_abbreviation 
,		pr.party 
,		sum(pr.votes)	
	from primary_results pr 
	group by pr.state, pr.state_abbreviation, pr.party 
	order by sum(pr.votes)desc, party 
	--order by state 
;


--Wyselekcjonowanie na którą partię najchętniej głosowano
select
			pr.party 
,			sum(pr.fraction_votes) as suma_glosów_frakcji
,			row_number () over (order by sum(pr.fraction_votes)desc )
from 
primary_results pr 
group by pr.party
;
-- REpublikan 29 098 686, Democrat 27 660 501


--Wyselekcjonowanie kandydatów z największą liczbą oddanych głosów
select 
			pr.candidate 
,			sum(pr.votes) as suma_glosow
,			sum(pr.fraction_votes) as suma_glosow_frakcji
,			pr.party 
,			row_number () over (order by sum(pr.votes)desc) as  kolejnosc
from primary_results pr 
group by pr.candidate, pr.party 
order by sum(pr.votes)desc, candidate;
--Hillary Clinton, Donald Trump
