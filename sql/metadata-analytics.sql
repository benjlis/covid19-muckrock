select count(dc_id) doc_cnt, sum(page_count) pg_cnt 
    from covid19_muckrock.metadata;
--
select organization, count(dc_id) doc_cnt, sum(page_count) pg_cnt
    from covid19_muckrock.metadata 
    group by organization
    order by pg_cnt desc;
--
select original_extension, count(dc_id) doc_cnt, sum(page_count) pg_cnt
    from covid19_muckrock.metadata 
    group by original_extension
    order by pg_cnt desc;