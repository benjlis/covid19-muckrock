drop view if exists covid19_muckrock.pii_summary;
create view covid19_muckrock.pii_summary as 
select pii_type, count(pii_text) occurrences, 
                 count(distinct pii_text) unique_occurrences
    from covid19_muckrock.pii
    group by pii_type
    order by occurrences desc;


drop view if exists covid19_muckrock.pii_docs;
create view covid19_muckrock.pii_docs as 
select dc_id, 
       count(pii_text) occurrences, 
       count(distinct pii_text) unique_occurrences,
       count(pii_text) 
        filter (where pii_type = 'email_address') emails,
       count(distinct pii_text) 
        filter (where pii_type = 'email_address') unique_emails,
       count(pii_text)
        filter (where pii_type = 'phone_number') phones,
       count(distinct pii_text)
        filter (where pii_type = 'phone_number') unique_phones,
       count(pii_text)
        filter (where pii_type = 'zipcode') zipcode,
       count(distinct pii_text)
        filter (where pii_type = 'zipcode') unique_zipcode,
       count(pii_text)
        filter (where pii_type = 'street_address') street_address,
       count(distinct pii_text)
        filter (where pii_type = 'street_address') unique_street_address,
       count(pii_text)
        filter (where pii_type = 'credit_card') credit_card,
       count(distinct pii_text)
        filter (where pii_type = 'credit_card') unique_credit_card,
       count(pii_text)
        filter (where pii_type = 'ssn') ssn,
       count(distinct pii_text)
        filter (where pii_type = 'ssn') unique_ssn,
       count(pii_text)
        filter (where pii_type = 'ban') ban,
       count(distinct pii_text)
        filter (where pii_type = 'ban') unique_ban      
    from covid19_muckrock.pii
    group by dc_id;


drop view if exists covid19_muckrock.pii_docs_ext;
create view covid19_muckrock.pii_docs_ext as 
select doc_id, title, pg_cnt,
       occurrences, emails, phones, zipcode, street_address, credit_card, ssn, ban,
       unique_occurrences, unique_emails, unique_phones, unique_zipcode, unique_street_address,
       unique_credit_card, unique_ssn, unique_ban,
       original_extension, pdf_url
    from covid19_muckrock.docs d left join covid19_muckrock.pii_docs p on (d.dc_id = p.dc_id);


drop view if exists covid19_muckrock.pii_top_emails;
create view covid19_muckrock.pii_top_emails as 
select pii_text, count(pii_text) occurrences, count(distinct dc_id) docs
    from covid19_muckrock.pii
    where pii_type = 'email_address'
    group by pii_text 
    order by occurrences desc
    limit 50;


drop view if exists covid19_muckrock.pii_top_phones;
create view covid19_muckrock.pii_top_phones as 
select pii_text, count(pii_text) occurrences, count(distinct dc_id) docs
    from covid19_muckrock.pii
    where pii_type = 'phone_number'
    group by pii_text 
    order by occurrences desc
    limit 50;


drop view if exists covid19_muckrock.pii_top_zips;
create view covid19_muckrock.pii_top_zips as 
select pii_text, count(pii_text) occurrences, count(distinct dc_id) docs
    from covid19_muckrock.pii
    where pii_type = 'zipcode'
    group by pii_text 
    order by occurrences desc
    limit 50;


drop view if exists covid19_muckrock.pii_top_addresses;
create view covid19_muckrock.pii_top_addresses as 
select pii_text, count(pii_text) occurrences, count(distinct dc_id) docs
    from covid19_muckrock.pii
    where pii_type = 'street_address'
    group by pii_text 
    order by occurrences desc
    limit 50;


drop view if exists covid19_muckrock.pii_details;
create view covid19_muckrock.pii_details as 
select d.doc_id, d.title, d.pg_cnt, d.pdf_url,
       p.pg, p.pii_type, p.pii_text, p.start_idx, p.end_idx,
       p.detected, p.pii_id
    from covid19_muckrock.docs d join covid19_muckrock.pii p on (d.dc_id = p.dc_id)
    order by d.doc_id, p.pg;

