-- metadata view
drop view if exists covid19_muckrock.docpages cascade;
create or replace view covid19_muckrock.docpages as
select d.*, p.pg, p.page_id, p.body, pt.full_text, 
       p.downloaded, p.reprocessed, 
       p.line_cnt, p.max_line_length, p.word_cnt, p.char_cnt, 
       p.body_md5, 
       case when p.word_cnt <= 4        then 'Y'
            when max_line_length <= 8   then 'Y'
            when pe.page_id is not null then 'Y'
            else 'N'
       end exception, 
       case when p.word_cnt <= 4        then 'blank_sparse'
            when max_line_length <=8    then 'compressed_margins'
            when pe.page_id is not null then pe.exception_type
            else NULL
       end exception_type, 
       pe.comments exception_comments 
    from covid19_muckrock.docs d 
            join covid19_muckrock.pages p 
                                    on (d.dc_id = p.dc_id)
            left join covid19_muckrock.page_exceptions pe
                on (p.page_id = pe.page_id)
            left join covid19_muckrock.page_tsvectors pt
                on (p.page_id = pt.page_id);
grant select on covid19_muckrock.docpages to c19ro;
