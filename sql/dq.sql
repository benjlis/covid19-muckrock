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

