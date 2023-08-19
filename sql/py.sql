-- name: get-doc-download-list
-- Get all docs whose text needs downloading
select row_number() over (order by d.doc_id), 
       d.doc_id, d.pg_cnt, d.pgtxt_prefix
    from covid19_muckrock.docs d
    where not exists (select 1
                        from covid19_muckrock.pages p
                        where p.dc_id = d.dc_id);

-- name: get-doc-exception-list
-- Get all docs with at least one page exception
select row_number() over (order by d.doc_id), 
       d.doc_id, d.title, d.s3_pdf_url
    from covid19_muckrock.docs d
    where exists (select 1
                        from covid19_muckrock.docpages dp
                        where d.doc_id = dp.doc_id and 
                              dp.exception = 'Y' and
                              dp.reprocessed is null and
                              dp.exception_type != 
                                       'compressed_margins')
    limit 10;

-- name: get-docpage-exception-list
-- Get all docs with at least one page exception
select row_number() over (order by dp.doc_id), 
       dp.pg, dp.page_id, dp.exception_type, dp.body
    from covid19_muckrock.docpages dp
    where dp.doc_id = :doc_id and 
          dp.exception = 'Y' and
          dp.exception_type != 'compressed_margins' and
          dp.reprocessed is null
    order by dp.pg;

-- name: get-doc-pdf-filename$
select pdf_filename
    from covid19_muckrock.docs
    where doc_id = :doc_id;

-- name: get-doc-pdf-list
select row_number() over (order by d.doc_id), 
       d.doc_id, api_pdf_url
    from covid19_muckrock.docs d
    where not exists (select 1
                        from covid19_muckrock.pdfs p
                        where p.dc_id = d.dc_id);

-- name: get-page-list
-- Gets all pages
select row_number() over (order by p.dc_id), 
       p.dc_id, p.pg, p.body, p.page_id
    from covid19_muckrock.pages p
    order by p.dc_id, p.pg;

-- name: get-page-body$
select body
    from covid19_muckrock.pages
    where page_id = :page_id;

-- name: add-page!
-- Add page of text to database
insert into covid19_muckrock.pages(dc_id, pg, word_cnt, char_cnt, body)
values (:id, :pg, :word_cnt, :char_cnt, :body);

-- name: store-reprocessed-page!
-- Update page body and related attributes when page is reprocessed.
update covid19_muckrock.pages
   set body =     :body,
       char_cnt = :char_cnt,
       word_cnt = :word_cnt,
       max_line_length = :max_line_length,
       reprocessed = now()
   where page_id = :page_id;

-- name: add-page-exception!
-- Add page exception to database   
insert into covid19_muckrock.page_exceptions(page_id, exception_type, comments)
values (:page_id, 'langdetect', :comments);

-- name:delete-page-exception!
-- Delete page exception from database
delete from covid19_muckrock.page_exceptions where page_id = :page_id;

-- name: add-pii!
-- Add pii element to database
insert into covid19_muckrock.pii(dc_id, pg, pii_type, pii_text, start_idx, end_idx)
values (:id, :pg, :pii_type, :pii_text, :start_idx, :end_idx);

-- name: add-pii-npp-page!
-- Add non-public persons at page level
insert into covid19_muckrock.pii(dc_id, pg, pii_type, pii_text, 
                                 start_idx, end_idx)
select p.dc_id, p.pg, 'name', ep.etext, ep.estart, ep.eend
    from covid19_muckrock.entity_pages ep 
        join covid19_muckrock.entities e 
            on (ep.entity_id = e.entity_id)
        join covid19_muckrock.pages p 
            on (ep.page_id = p.page_id)
    where p.dc_id = :doc_id and
          p.pg = :pg and
          ep.etype = 'PERSON' and
          e.wiki_id is NULL;

-- name: delete-pii!
-- Delete pii element from database
delete from covid19_muckrock.pii where dc_id=:doc_id and pg=:pg;

-- name: add-pdf!
-- Add pdf metadata to database
insert into covid19_muckrock.pdfs(dc_id, size, filename, pg_cnt, 
               version, title, author, subject, 
               keywords, creator, producer, 
               created, 
               modified, 
               trapped, encryption, xml_metadata, s3_uploaded)
values (:id, :size, :filename, :pg_cnt, 
               :version, :title, :author, :subject,
               :keywords, :creator, :producer, 
               to_timestamp(:created, 'YYYYMMDDHH24MISSTZH'),
               to_timestamp(:modified, 'YYYYMMDDHH24MISSTZH'), 
               :trapped, :encryption, :xml_metadata, :s3_uploaded);

-- name: add-email!
-- Add email metadata to database
insert into covid19_muckrock.emails (page_id, header_begin_ln, 
   header_end_ln, subject, sent, from_email, to_emails, cc_emails, 
   bcc_emails, attachments, importance, header_unprocessed) 
values (:page_id, :header_begin_ln, :header_end_ln, :subject, :sent, 
   :from_email, :to_emails, :cc_emails, :bcc_emails, :attachments, 
   :importance, :header_unprocessed);

-- name: add-entity<!
insert into covid19_muckrock.entities(entity, enttype)
values (:entity, :enttype) returning entity_id;

-- name: add-entity-page!
insert into covid19_muckrock.entity_pages(entity_id, page_id, etext, 
                                          etype, estart, eend)
values (:entity_id, :page_id, :etext, :etype, :estart, :eend);

-- name: delete-entity-page!
delete from covid19_muckrock.entity_pages where page_id = :page_id;

-- name: get-entity-id-by-name^
select entity_id
   from covid19_muckrock.entities
   where entity = :name;

-- name: add-page-tsvector!
insert into covid19_muckrock.page_tsvectors(page_id, full_text)
select page_id, to_tsvector('english'::regconfig, body::text)
   from covid19_muckrock.docpages
   where page_id = :page_id and exception = 'N';  