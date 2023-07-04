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
   from covid19_muckrock.docpages dp join 
         covid19_muckrock.dq_body_md5_duplicates dup
      on (dp.body_md5 = dup.body_md5)
   order by dp.body_md5, dp.doc_id, dp.pg;

drop view if exists covid19_muckrock.dq_pages_duplicates;
create or replace view covid19_muckrock.dq_pages_duplicates as
select body_md5, doc_id, title, count(*) copies,
       array_agg(pg order by pg) pgs,
       char_cnt, substr(body, 1, 512) body_512,
       canonical_url, pdf_url 
from covid19_muckrock.dq_docpages_duplicates
group by body_md5, doc_id, title, char_cnt, substr(body, 1, 512), 
         canonical_url, pdf_url
order by body_md5, doc_id;


drop view if exists covid19_muckrock.dq_docs_duplicates;
create or replace view covid19_muckrock.dq_docs_duplicates as
with corpus_unique as (select body_md5 
                       from covid19_muckrock.pages 
                       group by body_md5 having count(*) = 1)
select d.doc_id, d.title, d.pg_cnt, 
       count(distinct d.body_md5)               doc_uniq_pg_cnt,
       count(cu.body_md5)                       corpus_uniq_pg_cnt,
       round(count(distinct cu.body_md5)/pg_cnt::numeric, 2) uniq_ratio,
       d.canonical_url, d.pdf_url
from covid19_muckrock.docpages d left join corpus_unique cu 
                                    on d.body_md5 = cu.body_md5
group by doc_id, title, pg_cnt, canonical_url, pdf_url
order by count(distinct cu.body_md5)/d.pg_cnt::numeric, d.pg_cnt desc, d.title, d.doc_id;
-- select doc_id, title, pg_cnt from docs where title in (select title from metadata group by title having count(*) > 1);


drop view if exists covid19_muckrock.dq_docs_page_exceptions;
create or replace view covid19_muckrock.dq_docs_page_exceptions as
select d.doc_id, d.title, d.pg_cnt, 
       count(d.exception) filter (where d.exception='Y') pg_cnt_exceptions,
       round(count(d.exception) 
         filter (where d.exception='Y')/pg_cnt::numeric, 2) exception_ratio,
       count(d.exception_comments) 
         filter (where d.exception_comments = 'No features in text.') 
            pg_cnt_no_text_features,
       d.canonical_url, d.pdf_url
from covid19_muckrock.docpages d
group by d.doc_id, d.title, d.pg_cnt, d.canonical_url, d.pdf_url
order by count(d.exception) filter (where exception='Y')/pg_cnt::numeric desc; 


