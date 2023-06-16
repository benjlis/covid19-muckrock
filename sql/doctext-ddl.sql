-- metadata view
drop view if exists covid19_muckrock.doctext;
create view covid19_muckrock.doctext as
select p.dc_id, sum(word_cnt) word_cnt, sum(char_cnt) char_cnt, 
       max(downloaded) downloaded, string_agg(body, chr(10) order by pg) body
    from covid19_muckrock.pages p
    group by p.dc_id;