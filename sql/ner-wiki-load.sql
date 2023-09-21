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
update covid19_muckrock.ner_load 
   set wiki_id2 = NULL 
   where wiki_id2 in ('No Wiki', 'HL100001');

-- moved to single insert
--insert into covid19_muckrock.entities(wikidata_id, entity)
--select distinct wiki_id2, item_label
--   from covid19_muckrock.ner_load
--   where wiki_id2 is not null;
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



-- Create index on wiki_id
create index on covid19_muckrock.ner_load(wiki_id);
-- Update item_label in cases where we know it but it is missing
update covid19_muckrock.ner_load n 
   set item_label = (select distinct item_label 
                        from covid19_muckrock.ner_load i
                        where i.wiki_id = n.wiki_id and 
                              i.item_label is not null) 
   where wiki_id is NOT NULL and item_label is NULL;

-- 24442 rows
select count(*) from ner_load where wiki_id is NOT NULL and item_label is NULL;


-- Assumes previous content of entities and entity_pages has been deleted
create table covid19_muckrock.wikidata_updates_temp (
    id          int generated always as identity primary key,
    entity      text,
    wikidata_id text,
    redirect    text);
\copy wikidata_updates_temp(entity, wikidata_id, redirect) from 'data/doccovid4_pers1.csv' delimiter ',' csv header
-- and pers2 as well
delete from covid19_muckrock.wikidata_updates_temp 
   where wikidata_id = 'NIL'; 


create or replace view covid19_muckrock.ner_load_enttype_select as
select item_label, wiki_id, enttype, count(*) cnts,
       rank() over (partition by item_label, wiki_id 
                    order by count(*) desc) ranking,
       row_number() over (partition by item_label, wiki_id 
                          order by count(*) desc) row_ranking              
    from ner_load 
    where wiki_id is not null
    group by item_label, wiki_id, enttype
    order by item_label, wiki_id, cnts desc;

insert into covid19_muckrock.entities(entity, enttype, wikidata_id)
select distinct coalesce(item_label, entity), enttype, wiki_id
   from covid19_muckrock.ner_load_enttype_select
   where row_ranking = 1;


select count(*) 
   from (select wiki_id
            from ner_load
            where wiki_id is not null
            group by wiki_id
            having count(distinct coalesce(item_label, entity)) >1) n 

with eb (select item_label, enttype, wiki_id 
            from ner_load 
            where wiki_id is not null and
                  item_label = 'Maryland Aviation Administration'
            group by item_label, enttype, wiki_id
            order by cnts desc

            
where item_label = 'Maryland Aviation Administration' group by item_label, enttype, wiki_id;




select count(*), count(distinct n.id), count(distinct w.wikidata_id) 
   from ner_load n join wikidata_updates_temp w on (n.entity = w.entity)
   where n.wiki_id is null;

select * from entities where entity in (select entity from wikidata_updates_temp
   group by entities
   having count(entity) > 1);

-- small number missing
select wikidata_id from wikidata_updates_temp except select wikidata_id from wikidata_items;

-- Fill in the blank cases
-- select /* n.id, n.entity, i.item_label, i.wikidata_id, i.instance_of */ count(*)
--   from covid19_muckrock.ner_load n join 
--        covid19_muckrock.wikidata_items i on (i.item_label = n.entity)
--   where  n.wiki_id is null
--   order by n.id, i.wikidata_id;
update covid19_muckrock.ner_load n
   set wiki_id = (select w.wikidata_id 
                     from covid19_muckrock.wikidata_items w
                     where w.item_label = n.entity)
   where wiki_id is null and
         exists (select 1
                    from covid19_muckrock.wikidata_items w2
                     where w2.item_label = n.entity);



create index on ner_load(wiki_id);

select count(*) from 
    (select count(n.id)
       from covid19_muckrock.ner_load n join 
        covid19_muckrock.wikidata_aliases a on (n.entity = a.item_label)
                                    join
        covid19_muckrock.wikidata_items i on (i.wikidata_id = a.wikidata_id)
       where  n.wiki_id is null
       group by n.id
       having count(*) > 1) n;





select count(*) total_alias_matches, count(*) filter(where n.entity = i.item_label) fill_in_the_blank_matches
   from covid19_muckrock.ner_load n join 
        covid19_muckrock.wikidata_aliases a on (n.entity = a.item_label)
                                    join
        covid19_muckrock.wikidata_items i on (i.wikidata_id = a.wikidata_id)
   where  n.wiki_id is null;


select n.id, n.entity, i.item_label, i.wikidata_id, i.instance_of       -- count(*)
   from covid19_muckrock.ner_load n join 
        covid19_muckrock.wikidata_aliases a on (n.entity = a.item_label)
                                    join
        covid19_muckrock.wikidata_items i on (i.wikidata_id = a.wikidata_id)
   where  n.wiki_id is null
   order by n.id, i.wikidata_id;

-- update ner_load set wiki_id =  regexp_replace(wiki_id, '\s+$', '');
--
-- No Wiki: we've checked and there's not currently a wikid data id, but we think this string represents an entity
-- NIL: we've not yet checked this entity. It might not even be an entity.

-- entites
--
insert into entities(entity)
    select distinct entity from ner_load;
update entities e 
    set wiki_id = (select min(wiki_id)
                    from ner_load
                    where wiki_id != 'NIL' and
                          entity = e.entity),
        enttype = (select enttype 
                    from ner_load
                    where entity = e.entity
                    group by enttype
                    order by count(enttype) desc
                    limit 1);                          
alter table entities alter column enttype set not null;

with l (file, uc, pc, entity, enttype, estart, eend) as
       (select file, position('_' in file),  position('.' in file),
               entity, enttype, estart, eend
            from ner_load)
insert into entity_pages(entity_id, page_id, etext, etype, estart, eend)
select e.entity_id, p.page_id, l.entity, l.enttype, l.estart, l.eend   
    from l join pages p on (p.dc_id = substr(file, 1, uc-1)::int and
                            p.pg = substr(file, uc+1, pc-uc-1)::int)
           join entities e on (e.entity = l.entity);


-- collapse on wiki ID
--