-- metadata view
drop view if exists covid19_muckrock.docpages;
create view covid19_muckrock.docpages as
select d.*, p.pg, p.word_cnt, p.char_cnt, p.downloaded, p.body 
    from covid19_muckrock.docs d join covid19_muckrock.pages p 
        on (d.dc_id = p.dc_id);

