-- analysis of sitka page exceptions
select count(*) 
    from docpages 
    where title = 'Sitka' and exception = 'Y';
--
select exception_type, count(exception_type) 
    from docpages 
    where title = 'Sitka' and exception = 'Y'
    group by exception_type;
--
select p.pii_type, count(p.pii_type)
    from docpages d join pii p 
        on (d.doc_id = p.dc_id and d.pg = p.pg) 
    where d.title = 'Sitka' and d.exception = 'Y'
    group by p.pii_type;
--
select ep.etype, count(ep.etype)
    from docpages d join entity_pages ep 
        on (d.page_id = ep.page_id) 
    where d.title = 'Sitka' and d.exception = 'Y'
    group by ep.etype;

-- detailed queries
--select p.*
--    from docpages d join pii p 
--        on (d.doc_id = p.dc_id and d.pg = p.pg) 
--    where d.title = 'Sitka' and d.exception = 'Y';
--
-- select ep.*
--    from docpages d join entity_pages ep 
--        on (d.page_id = ep.page_id) 
--    where d.title = 'Sitka' and d.exception = 'Y';
--   