drop view if exists covid19_muckrock.docpages_authorized cascade;
create or replace view covid19_muckrock.docpages_authorized as
select d.doc_id, d.title, d.pg_cnt, d.s3_pdf_url pdf_url,
       d.pg, d.page_id, d.body, d.full_text,
       d.dc_organization, d.dc_username
     from covid19_muckrock.docpages d
     where d.exception = 'N' and d.full_text is not null; 
grant select on covid19_muckrock.docpages_authorized to c19ro;
