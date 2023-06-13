-- name: get-doc-download-list
-- Get list of all pdfs that can be processed
select row_number() over (order by d.doc_id), 
       d.doc_id, d.pgtxt_prefix
    from covid19_muckrock.docs d;
