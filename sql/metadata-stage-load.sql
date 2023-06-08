drop table if exists covid19_muckrock.metadata_stage_bckp;
create table covid19_muckrock.metadata_stage_bckp as 
	select * from covid19_muckrock.metadata_stage;
truncate table covid19_muckrock.metadata_stage;
\copy covid19_muckrock.metadata_stage(id, access, asset_url, canonical_url, created_at, data, description, edit_access, file_hash, noindex, language, organization, original_extension, page_count, page_spec, projects, publish_at, published_url, related_article, revision_control, slug, source, status, title, updated_at, userinfo) from 'csv2pg-muckrock-covid19.csv' DELIMITER ',' CSV HEADER;
