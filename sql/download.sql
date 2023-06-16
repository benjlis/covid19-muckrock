-- name: get-doc-download-list
-- Get list of all pdfs that can be processed
select row_number() over (order by d.doc_id), 
       d.doc_id, d.pg_cnt, d.pgtxt_prefix
    from covid19_muckrock.docs d;
    -- where doc_id = 23824253;

-- name: add-page!
-- Add page of text to database
insert into covid19_muckrock.pages(dc_id, pg, word_cnt, char_cnt, body)
values (:id, :pg, :word_cnt, :char_cnt, :body);