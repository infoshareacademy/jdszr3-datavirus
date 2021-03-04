--country_facts_dictionary--
CREATE TABLE county_facts_dictionary(
    column_name TEXT,
    description TEXT);
    
  --country_facts--
   CREATE TABLE county_facts (
    fips INTEGER ,
    area_name TEXT,
    state_abbreviation TEXT,
    PST045214 INTEGER,
    PST040210 INTEGER,
    PST120214 NUMERIC,
    POP010210 INTEGER,
    AGE135214 NUMERIC,
    AGE295214 NUMERIC,
    AGE775214 NUMERIC,
    SEX255214 NUMERIC,
    RHI125214 NUMERIC,
    RHI225214 NUMERIC,
    RHI325214 NUMERIC,
    RHI425214 NUMERIC,
    RHI525214 NUMERIC,
    RHI625214 NUMERIC,
    RHI725214 NUMERIC,
    RHI825214 NUMERIC,
    POP715213 NUMERIC,
    POP645213 NUMERIC,
    POP815213 NUMERIC,
    EDU635213 NUMERIC,
    EDU685213 NUMERIC,
    VET605213 INTEGER,
    LFE305213 NUMERIC,
    HSG010214 INTEGER,
    HSG445213 NUMERIC,
    HSG096213 NUMERIC,
    HSG495213 INTEGER,
    HSD410213 INTEGER,
    HSD310213 NUMERIC,
    INC910213 INTEGER,
    INC110213 INTEGER,
    PVY020213 NUMERIC,
    BZA010213 INTEGER,
    BZA110213 INTEGER,
    BZA115213 NUMERIC,
    NES010213 INTEGER,
    SBO001207 INTEGER,
    SBO315207 NUMERIC,
    SBO115207 NUMERIC,
    SBO215207 NUMERIC,
    SBO515207 NUMERIC,
    SBO415207 NUMERIC,
    SBO015207 NUMERIC,
    MAN450207 INTEGER,
    WTN220207 INTEGER,
    RTN130207 INTEGER,
    RTN131207 INTEGER,
    AFN120207 INTEGER,
    BPS030214 INTEGER,
    LND110210 NUMERIC,
    POP060210 NUMERIC);
    
  --primary_facts--
   CREATE TABLE primary_results (
    state TEXT,
    state_abbreviation TEXT,
    county TEXT,
    fips INTEGER,
    party TEXT,
    candidate TEXT,
    votes INTEGER,
    fraction_votes NUMERIC); 
   
  --sprawdzenie czy występują jakieś wartości nullowe w county_facts_dictionary
 select * from county_facts_dictionary cfd 
 where column_name is null
or description is null;

--sprawdzenie czy stępują jakieś wartości nulowe w primary_results --> stan Hew Hamphire dla columny fiips - 100 wierszy
select * from primary_results pr 
where state is null
or state_abbreviation is null 
or county is null 
or fips is null 
or party is null 
or candidate is null 
or votes is null 
or fraction_votes is null;

--sprawdzenie czy występują jakieś wiersze, które nie wystąpią po połączeniu tabel primary_results i county_facts
select state, count(state) 
from primary_results pr
where (not exists (select fips from county_facts cf where pr.fips=cf.fips)) or fips is null
group by cube(state)
order by 1;

  /*z powodu nie odpowiadających sobie column w obu tabelach stany te zostaną pominięte w analizie*/
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 