drop view if exists covid19_muckrock.dq_sparse_docs;
create or replace view covid19_muckrock.dq_sparse_docs as
select doc_id, title, pg_cnt, count(pg) pg_cnt_sparse, 
       count(pg) filter (where word_cnt = 0) pg_cnt_0word,
       count(pg) filter (where word_cnt = 1) pg_cnt_1word,
       round(count(pg)/pg_cnt::numeric, 2) ratio,
       canonical_url, pdf_url
    from covid19_muckrock.docpages
    where word_cnt <= 1
    group by doc_id, title, pg_cnt, canonical_url, pdf_url
    order by count(pg)/pg_cnt::float desc, pg_cnt desc;

drop view if exists covid19_muckrock.dq_sparse_docpages;
create or replace view covid19_muckrock.dq_sparse_docpages as
select *
    from covid19_muckrock.docpages
    where word_cnt <= 1
    order by doc_id, pg;


drop view if exists covid19_muckrock.dq_body_md5_duplicates;
create or replace view covid19_muckrock.dq_body_md5_duplicates as
select body_md5, count(body_md5) copies
   from covid19_muckrock.pages
   group by body_md5
   having count(body_md5) > 1;

drop view if exists covid19_muckrock.dq_docpages_duplicates;
create or replace view covid19_muckrock.dq_docpages_duplicates as
select dp.*, dup.copies
   from covid19_muckrock.docpages dp join dq_body_md5_duplicates dup
      on (dp.body_md5 = dup.body_md5)
   order by dp.body_md5, dp.doc_id, dp.pg;

