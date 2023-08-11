-- temporarily saves the original Sitka values for QA purposes
-- note: this keeps everything when we only really need to keep the page_exceptions
create table covid19_muckrock.sitka_orig_pages_temp as
   select * from covid19_muckrock.pages
      where dc_id = (select doc_id 
                        from docs 
                        where title = 'Sitka');

create table covid19_muckrock.sitka_orig_pii_temp as
   select * from covid19_muckrock.pii
      where dc_id = (select doc_id 
                        from docs 
                        where title = 'Sitka');

create table covid19_muckrock.sitka_orig_entity_pages_temp as
   select * from covid19_muckrock.entity_pages
      where page_id in (select page_id 
                          from covid19_muckrock.sitka_orig_pages_temp);
                        


