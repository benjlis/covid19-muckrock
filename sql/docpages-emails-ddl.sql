drop view if exists covid19_muckrock.docpages_emails;
create or replace view covid19_muckrock.docpages_emails as
select d.doc_id, d.pg, d.title doc_title, d.pg_cnt, d.body, 
       e.email_id, e.processed, e.subject, e.sent, 
       e.from_email, e.to_emails, e.cc_emails, e.bcc_emails,
       e.attachments, e.importance, e.header_unprocessed,
       e.header_begin_ln, e.header_end_ln, e.page_id, d.canonical_url
    from covid19_muckrock.docpages d join covid19_muckrock.emails e
                                        on (d.page_id = e.page_id);
--\copy (select * from covid19_muckrock.docpages_emails) to '../tmp/docpages-emails.csv' header csv

