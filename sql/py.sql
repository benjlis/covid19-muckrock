-- name: get-doc-download-list
-- Get all docs whose text needs downloading
select row_number() over (order by d.doc_id), 
       d.doc_id, d.pg_cnt, d.pgtxt_prefix
    from covid19_muckrock.docs d
    where not exists (select 1
                                from covid19_muckrock.pages p
                                where p.dc_id = d.dc_id);

-- name: get-page-list
-- Gets all pages
select row_number() over (order by p.dc_id), 
       p.dc_id, p.pg, p.body, p.page_id
    from covid19_muckrock.pages p
    order by p.dc_id, p.pg;

-- name: add-page!
-- Add page of text to database
insert into covid19_muckrock.pages(dc_id, pg, word_cnt, char_cnt, body)
values (:id, :pg, :word_cnt, :char_cnt, :body);

-- name: add-pii!
-- Add pii element to database
insert into covid19_muckrock.pii(dc_id, pg, pii_type, pii_text, start_idx, end_idx)
values (:id, :pg, :pii_type, :pii_text, :start_idx, :end_idx);
