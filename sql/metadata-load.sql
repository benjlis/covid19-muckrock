insert into metadata(
	dc_id, canonical_url, created_at, lang, organization, 
	original_extension, page_count, slug, title, updated_at, userinfo) 
select id::int, canonical_url, created_at::timestamp with time zone, language, organization, /* json extraction */
       original_extension, page_count::int, slug, title, updated_at::timestamp with time zone, userinfo
	from covid19_muckrock.metadata_stage;

-- extract elements out of json
update metadata set organization = replace(organization, 'False', 'false');
update metadata set organization = replace(organization, '''', '"')::jsonb ->> 'name';
update metadata set userinfo = replace(userinfo, 'True', 'true');
update metadata set userinfo = replace(userinfo, 'False', 'false');
update metadata set userinfo = replace(userinfo, '''', '"')::jsonb ->> 'name';

-- select replace(organization, '''', '"')::jsonb ->> 'name' from metadata;
-- select replace(userinfo, '''', '"')::jsonb from metadata limit 5;