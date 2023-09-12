create or replace view covid19_muckrock.docpages_pii as
select d.title, d.doc_id, d.pg, d.page_id, 
       pii.pii_type, pii.pii_text, pii.start_idx, pii.end_idx
    from covid19_muckrock.pii pii join covid19_muckrock.docpages d
        on (pii.dc_id = d.dc_id and pii.pg = d.pg)
    order by d.doc_id, d.pg;

\copy (select * from docpages_pii where title = 'Sitka') to 'tmp/sitka.csv' CSV header