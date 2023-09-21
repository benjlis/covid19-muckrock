create table covid19_muckrock.ner_load (
    id      integer primary key,
    file    text    not null,
    wiki_id text,
    enttype text    not null,
    entity  text    not null,
    estart  integer not null,
    eend    integer not null,
    indx    text,
    wiki_id2 text,
    item_label text);
\copy ner_load from 'data/doccovid4.csv' delimiter ',' csv header
-- Update wiki_id, wiki_id2 to NULL if it doesn't contain a valid value
update covid19_muckrock.ner_load 
   set wiki_id = NULL 
   where wiki_id in ('NIL', 'No Wiki', 'HL100001');

-- Create index on wiki_id
create index on covid19_muckrock.ner_load(wiki_id);

-- Populate entities based on wiki_id in ner_load
insert into covid19_muckrock.entities(wikidata_id, entity, enttype)
select distinct wiki_id, w.item_label,
       case when w.instance_of = 'human'        then 'PERSON'
            when w.instance_of = 'human population'  then 'PERSON'
            when w.instance_of like '%agency%'  then 'ORG'
            when w.instance_of like '%city%'    then 'GPE'
            when w.instance_of like 'county%'   then 'GPE'
            when w.instance_of like 'province%' then 'GPE'
            when w.instance_of like 'commune%'   then 'GPE'
            when w.instance_of like 'municipality%'  then 'GPE'
            when w.instance_of like 'parish%'   then 'GPE'
            when w.instance_of in   ('state', 'U.S. state','nation',
                                     'sovereign state')   then 'GPE'
            when w.instance_of like 'state of%'   then 'GPE'
            when w.instance_of like '%country%' then 'GPE'
            when w.instance_of like '%government' then 'GPE'
            when w.instance_of like '%police%' then 'ORG'
            when w.instance_of like '%court%' then 'ORG'
            when w.instance_of like '%school district%' then 'ORG'
            when w.instance_of like '%university%' then 'ORG'
            when w.instance_of like '%organization%' then 'ORG'
            when w.instance_of like '%department%' then 'ORG'
            when w.instance_of like '%company%' then 'ORG'
            when w.instance_of like '%administration%' then 'ORG'
            when w.instance_of like '%service%' then 'ORG'
            when w.instance_of like '%commission%' then 'ORG'
            when w.instance_of like '%office%' then 'ORG'
            when w.instance_of like '%ministry%' then 'ORG'
            when w.instance_of like '%corporation%' then 'ORG'
            when w.instance_of like '%association%' then 'ORG'
            when w.instance_of like '%institution%' then 'ORG'
            when w.instance_of like '%society' then 'ORG'
            when w.instance_of like '%newspaper' then 'ORG'
            when w.instance_of in ('foundation','business',
                                   'political party') then 'ORG'
            when w.instance_of like '%region%' then 'LOC'
            when w.instance_of in ('island','peninsula','continent',
                                   'subcontinent','river','sea', 'ocean',
                                   'desert', 'archipelago', 
                                   'human settlement') then 'LOC'
            when w.instance_of like '%airport%' then 'FAC'
            when w.instance_of like 'port%' then 'FAC'
            else '**TBD**'
       end
   from covid19_muckrock.ner_load n 
   join covid19_muckrock.wikidata_items w
      on n.wiki_id = w.wikidata_id
   where wiki_id is not null;

-- where we don't have a mapping take the most freq occuring enttype
-- in ner_load
update covid19_muckrock.entities e
   set updated = now(),
       enttype = (select n.enttype 
                     from (select enttype, count(*) 
                               from covid19_muckrock.ner_load n
                               where n.wiki_id = e.wikidata_id
                               group by enttype
                               order by count(*) desc 
                               limit 1) n)
   where enttype = '**TBD**';
-- Some of these are good some are not! discuss how to fix


-- Load additional data from Ray
create table covid19_muckrock.wikidata_updates_temp (
    id          int generated always as identity primary key,
    entity      text,
    wikidata_id text,
    redirect    text);
\copy wikidata_updates_temp(entity, wikidata_id, redirect) from 'data/doccovid4_pers1.csv' delimiter ',' csv header
-- and pers2 as well
delete from covid19_muckrock.wikidata_updates_temp 
   where wikidata_id = 'NIL'; 

-- further updates
select count(*) updates,
       count(i.wikidata_id)             item_in_db,
       count(*) - count(i.wikidata_id)  item_not_in_db 
   from covid19_muckrock.wikidata_updates_temp u left join
        covid19_muckrock.wikidata_items i 
         on (u.wikidata_id = i.wikidata_id);
-- must load wikidata items first
-- also consider restricting certain instance_of, e.g., Andrew - Q18042461
