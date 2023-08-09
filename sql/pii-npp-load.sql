insert into covid19_muckrock.pii(dc_id, pg, pii_type, pii_text,
                                 start_idx, end_idx)
select p.dc_id, p.pg, 'name', etext, estart, eend
   from covid19_muckrock.entity_pages ep 
        join covid19_muckrock.pages p on (ep.page_id = p.page_id)
        join covid19_muckrock.entities e on (ep.entity_id = e.entity_id)
   where etype = 'PERSON' and
         wiki_id is NULL;