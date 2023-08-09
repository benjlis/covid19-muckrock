-- metadata view
-- drop view if exists covid19_muckrock.docs;
create or replace view covid19_muckrock.docs  as
select m.dc_id, m.dc_id doc_id, m.title, m.page_count pg_cnt, 
    m.lang doc_lang, m.original_extension, 
    m.created_at dc_created, m.updated_at dc_updated, 
    m.organization dc_organization, m.userinfo dc_username, 
    m.slug,  m.canonical_url,
	m.asset_url || 'documents/' || m.dc_id || '/' || m.slug || 
        '.pdf' pdf_url,
    'https://api.www.documentcloud.org/files/documents/' || m.dc_id ||
        '/' || m.slug || '.pdf'     api_pdf_url,
    'https://api.www.documentcloud.org/files/documents/' || m.dc_id || 
        '/pages/' || m.slug || '-p' pgtxt_prefix,
    'https://foiarchive-covid-19.s3.amazonaws.com/muckrock/' ||
        p.filename s3_pdf_url,
    p.version pdf_version, p.filename pdf_filename, p.title pdf_title,
    p.subject pdf_subject, p.keywords pdf_keywords,
    p.author pdf_author, p.creator pdf_creator, p.producer pdf_producer,
    p.created pdf_created, p.modified pdf_modified, 
    p.downloaded pdf_downloaded, p.encryption pdf_encryption,
    round(p.size/1024./1024., 3) pdf_size_mb, p.pg_cnt pdf_pg_cnt 
from covid19_muckrock.metadata m join covid19_muckrock.pdfs p 
    on (m.dc_id = p.dc_id)
where -- remove duplicates of 23823808, 20404047, 21080904 
      m.dc_id not in (23824236, 20404053, 21120835);