-- cases where the pg
select doc_id, pg_cnt, count(*) dpg_cnt
   from covid19_muckrock. docpages
   group by doc_id, pg_cnt
   having pg_cnt != count(*);