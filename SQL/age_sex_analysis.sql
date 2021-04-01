--analiza
--spr listy kandydatow i partii
select distinct pr.candidate,
	   pr.party 
from primary_results pr
order by 2, 1; 
--przygotowanie widoku dla wybranego obszaru danych demograficznych
create view v_wyniki_z_danymi_demogr as
select pr.state as stan,
	   pr.county as county,
	   pr.fips as fips,
	   pr.party as partia,
	   pr.candidate as kandydat,
	   pr.votes as glosy_po_county,
	   cf.age135214 as ods_wieku_ponizej_5,
	   cf.age295214 as ods_wieku_ponizej_18,
	   cf.age775214 as ods_wieku_powyzej_65,
	   cf.sex255214 as ods_kobiet
from primary_results pr
join county_facts cf on pr.fips = cf.fips; 
select * from v_wyniki_z_danymi_demogr; 
--spr sumy glosow po stanie
create view v_wyniki_po_stanach as
select pr.state as stan,
	   pr.candidate as kandydat,
	   sum(pr.votes) as suma_glosow,
	   avg(fraction_votes) as srednia_frakcji,
	   row_number() over(partition by pr.state order by sum(pr.votes) desc) as ranking
from primary_results pr
group by 1, 2
order by 1, 3 desc;
--wygrani po stanach
create view v_wygrani_po_stanach as 
select * 
from v_wyniki_po_stanach
where ranking = 1;
select * from v_wygrani_po_stanach vwps; 
--wygrani po stanach z ods >65, ods<18, ods<5 i ods kobiet
create view v_wygrani_z_atrybutami as
select stan,
	   kandydat,
	   suma_glosow,
	   cf.age135214 as ods_wieku_ponizej_5,
	   cf.age295214 as ods_wieku_ponizej_18,
	   cf.age775214 as ods_wieku_powyzej_65,
	   cf.sex255214 as ods_kobiet
from v_wygrani_po_stanach vwps
join county_facts cf on cf.area_name = vwps.stan;  
--srednie dla stanow po wieku oraz plci
select kandydat,
	   sum(suma_glosow) as lacznie_gl_per_kandydat,
	   round(avg(ods_wieku_ponizej_5),2) as sr_wiek_pon_5,
	   round(avg(ods_wieku_ponizej_18),2) as sr_wiek_pon_18,
	   round(avg(ods_wieku_powyzej_65),2) as sr_wiek_pow_65,
	   round(avg(ods_kobiet),2) as sr_ods_kobiet
from v_wygrani_z_atrybutami
group by 1; 
--przygotowanie widoku z wiekiem i ods kobiet po stanie
create view v_wiek_plec_po_stanie as
select fips,
	   area_name as stan,
	   age135214 as ods_ponizej_5,
	   age295214 as ods_ponizej_18,
	   age775214 as ods_powyzej_65,
	   sex255214 as ods_kobiet
from county_facts cf
where fips > 0 and state_abbreviation = ''; 
--spr min, max i avg wieku i plci po stanie
select min(ods_ponizej_5) as min_ods_ponizej_5,
	   round(avg(ods_ponizej_5),2) as sr_ods_ponizej_5,
	   max(ods_ponizej_5) as max_ods_ponizej_5,
	   min(ods_ponizej_18) as min_ods_ponizej_18,
	   round(avg(ods_ponizej_18),2) as sr_ods_ponizej_18,
	   max(ods_ponizej_18) as max_ods_ponizej_18,
	   min(ods_powyzej_65) as min_ods_powyzej_65,
	   round(avg(ods_powyzej_65),2) as sr_ods_powyzej_65,
	   max(ods_powyzej_65) as max_ods_powyzej_65,
	   min(ods_kobiet) as min_ods_kobiet,
	   round(avg(ods_kobiet),2) as sr_ods_kobiet,
	   max(ods_kobiet) as max_ods_kobiet
from v_wiek_plec_po_stanie; 
--ponizej 5: min - 4.9, avg - 6.23, max - 8.6
--ponizej 18: min - 17.5, avg - 22.9, max - 30.7
--powyzej 65: min - 9.4, avg - 14.76, max - 19.1
--ods kobiet: min - 47.4, avg - 50.6, max - 52.6
--spr sumy glosow po county
create view v_wyniki_po_county as
select pr.county as county,
	   pr.fips as nr_fips,
	   pr.candidate as kandydat,
	   sum(pr.votes) as suma_glosow,
	   row_number() over(partition by pr.county order by sum(pr.votes) desc) as ranking
from primary_results pr
group by 1, 2, 3
order by 1, 4 desc;
--wygrani po county
create view v_wygrani_po_county as 
select * 
from v_wyniki_po_county
where ranking = 1; 
--przygotowanie widoku z wiekiem i ods kobiet po county
create view v_wiek_plec_po_county as
select fips,
	   area_name as county,
	   age135214 as ods_ponizej_5,
	   age295214 as ods_ponizej_18,
	   age775214 as ods_powyzej_65,
	   sex255214 as ods_kobiet
from county_facts cf
where fips > 0 and state_abbreviation <> ''; 
--widok wygrani po county z atrybutami
create view v_wygrani_po_county_z_atrybutami as
select vwpc.county as county,
	   kandydat,
	   suma_glosow,
	   ods_ponizej_5,
	   ods_ponizej_18,
	   ods_powyzej_65,
	   ods_kobiet 
from v_wygrani_po_county vwpc 
join v_wiek_plec_po_county vwppc on vwpc.nr_fips = vwppc.fips; 
--spr min, max i avg wieku i plci po county
select min(ods_ponizej_5) as min_ods_ponizej_5,
	   round(avg(ods_ponizej_5),2) as sr_ods_ponizej_5,
	   max(ods_ponizej_5) as max_ods_ponizej_5,
	   min(ods_ponizej_18) as min_ods_ponizej_18,
	   round(avg(ods_ponizej_18),2) as sr_ods_ponizej_18,
	   max(ods_ponizej_18) as max_ods_ponizej_18,
	   min(ods_powyzej_65) as min_ods_powyzej_65,
	   round(avg(ods_powyzej_65),2) as sr_ods_powyzej_65,
	   max(ods_powyzej_65) as max_ods_powyzej_65,
	   min(ods_kobiet) as min_ods_kobiet,
	   round(avg(ods_kobiet),2) as sr_ods_kobiet,
	   max(ods_kobiet) as max_ods_kobiet
from v_wiek_plec_po_county; 
--ponizej 5: min - 0, avg - 5.89, max - 13.7
--ponizej 18: min - 0, avg - 22.53, max - 42
--powyzej 65: min - 0, avg - 17.57, max - 52.9
--ods kobiet: min - 0, avg - 49.9, max - 56.8
--spr, w ktorym county ods = 0 
select * from v_wiek_plec_po_county vwppc
where ods_ponizej_5 = 0;
--Kalawao County ma ods<5 i <18 rowny 0 - do spr, Bedford city ma wszystkie 0 - do spr i uzupelnienia
--Kalawo County, Hawaje, sprawdzone i poprawnie jest 0%
--uzupelnienie Bedford o dane z census.gov
update county_facts 
set age135214 = 4.6, age295214 = 19.7, age775214 = 21.8, sex255214 = 50.8
where lower(area_name) = 'bedford city';
--spr min, max i avg wieku i plci po county po aktualizacji dla Bedford
select min(ods_ponizej_5) as min_ods_ponizej_5,
	   round(avg(ods_ponizej_5),2) as sr_ods_ponizej_5,
	   max(ods_ponizej_5) as max_ods_ponizej_5,
	   min(ods_ponizej_18) as min_ods_ponizej_18,
	   round(avg(ods_ponizej_18),2) as sr_ods_ponizej_18,
	   max(ods_ponizej_18) as max_ods_ponizej_18,
	   min(ods_powyzej_65) as min_ods_powyzej_65,
	   round(avg(ods_powyzej_65),2) as sr_ods_powyzej_65,
	   max(ods_powyzej_65) as max_ods_powyzej_65,
	   min(ods_kobiet) as min_ods_kobiet,
	   round(avg(ods_kobiet),2) as sr_ods_kobiet,
	   max(ods_kobiet) as max_ods_kobiet
from v_wiek_plec_po_county; 
--ponizej 5: min - 0, avg - 5.89, max - 13.7
--ponizej 18: min - 0, avg - 22.55 max - 42
--powyzej 65: min - 4.1, avg - 17.57, max - 52.9
--ods kobiet: min - 30.1, avg - 49.92, max - 56.8
--srednie po county po wygranym
select vwpc.kandydat as wygrany,
	   sum(vwpc.suma_glosow) as suma_glosow, 
	   round(avg(ods_ponizej_5),2) as sredni_ods_ponizej_5_po_county,
	   round(avg(ods_ponizej_18),2) as sredni_ods_ponizej_18_po_county,
	   round(avg(ods_powyzej_65),2) as sredni_ods_powyzej_65_po_county,
	   round(avg(ods_kobiet),2) as sredni_ods_kobiet_po_county
from v_wygrani_po_county vwpc
join v_wiek_plec_po_county vwppc on vwppc.fips = vwpc.nr_fips 
group by wygrany; 
--spr korelacji miedzy liczba glosow a wiekiem i plcia
select corr(glosy_po_county, ods_wieku_ponizej_5) as korelacja_glosy_wiek_ponizej_5,
	   corr(glosy_po_county, ods_wieku_ponizej_18) as korelacja_glosy_wiek_ponizej_18,
	   corr(glosy_po_county, ods_wieku_powyzej_65) as korelacja_glosy_wiek_powyzej_65,
	   corr(glosy_po_county, ods_kobiet) as korelacja_glosy_ods_kobiet
from v_wyniki_z_danymi_demogr vwzdd;
--brak istotnej korelacji
--ciekawostki
--outliersi i kto tam wygral
--min ods<5 rz po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_wieku_ponizej_5 = (select min(vwza2.ods_wieku_ponizej_5) from v_wygrani_z_atrybutami vwza2) ; 
--3 stany Maine, New Hamshire, Vermont 4.9% - wygrany: bernie sanders
--min ods<18 rz po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_wieku_ponizej_18 = (select min(vwza2.ods_wieku_ponizej_18) from v_wygrani_z_atrybutami vwza2) ; 
--Vermont 19.4% wygrany: bernie sanders
--min ods<5 po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_ponizej_5 = (select min(vwpcza2.ods_ponizej_5) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Sumter 2%, wygrany: donald trump
--min ods<18 po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_ponizej_18 = (select min(vwpcza2.ods_ponizej_18) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Sumter 7.4%, wygrany: donald trump
--max ods<5 rz po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_wieku_ponizej_5 = (select max(vwza2.ods_wieku_ponizej_5) from v_wygrani_z_atrybutami vwza2) ; 
--Utah 8.6% wygrany: ted cruz
--max ods<18 rz po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_wieku_ponizej_18 = (select max(vwza2.ods_wieku_ponizej_18) from v_wygrani_z_atrybutami vwza2) ; 
--Utah 30.7% wygrany: ted cruz
--max ods<5 po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_ponizej_5 = (select max(vwpcza2.ods_ponizej_5) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Todd 13% wygrany: bernie sanders
--max ods<18 po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_ponizej_18 = (select max(vwpcza2.ods_ponizej_18) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Todd 40.4%, wygrany: bernie sanders
--min ods>65 rz po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_wieku_powyzej_65 = (select min(vwza2.ods_wieku_powyzej_65) from v_wygrani_z_atrybutami vwza2) ; 
--Alaska 9.4% wygrany: ted cruz
--min ods>65 po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_powyzej_65 = (select min(vwpcza2.ods_powyzej_65) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Chattahoochee 4.1 wygrany: hillary clinton
--max ods>65 rz po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_wieku_powyzej_65 = (select max(vwza2.ods_wieku_powyzej_65) from v_wygrani_z_atrybutami vwza2) ; 
--Florida 19.1% wygrany: hillary clinton
--max ods>65 po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_powyzej_65 = (select max(vwpcza2.ods_powyzej_65) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Sumter 52.9 wygrany: donald trump
--min ods kobiet po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_kobiet = (select min(vwza2.ods_kobiet) from v_wygrani_z_atrybutami vwza2) ; 
--Alaska 47.4% wygrany: ted cruz
--min ods kobiet po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_kobiet = (select min(vwpcza2.ods_kobiet) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Concho 30.1 wygrany: ted cruz
--max ods kobiet po stanie
select * 
from v_wygrani_z_atrybutami vwza
where ods_kobiet = (select max(vwza2.ods_kobiet) from v_wygrani_z_atrybutami vwza2) ; 
--Delaware 51.6% wygrany: hillary clinton
--max ods kobiet po county
select *
from v_wygrani_po_county_z_atrybutami
where ods_kobiet = (select max(vwpcza2.ods_kobiet) from v_wygrani_po_county_z_atrybutami vwpcza2); 
--Summers 55.2 wygrany: bernie sanders