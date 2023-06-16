-- metadata view
drop view if exists covid19_muckrock.docs;
create view covid19_muckrock.docs  as
select dc_id, dc_id doc_id, title, page_count pg_cnt, lang doc_lang, original_extension, 
    created_at, updated_at, organization, userinfo username, slug,  
    canonical_url,
	asset_url || 'documents/' || dc_id || '/' || slug || '.pdf' pdf_url,
    'https://api.www.documentcloud.org/files/documents/' || dc_id || 
    '/pages/' || slug || '-p' pgtxt_prefix
from covid19_muckrock.metadata;