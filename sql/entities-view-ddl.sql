create or replace view covid19_muckrock.entities_view as
select entity_id, e.wikidata_id, entity, enttype, instance_of,
       e.created, e.updated
    from covid19_muckrock.entities e join 
         covid19_muckrock.wikidata_items w
            on (e.wikidata_id = w.wikidata_id)
    order by entity, e.wikidata_id;
grant select on covid19_muckrock.entities_view to c19ro;