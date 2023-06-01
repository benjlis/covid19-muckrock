create table covid19_muckrock.metadata(
	 dc_id 	 	     		int	 primary key,
	 canonical_url 	 		text not null,
	 created_at 	 		timestamp with time zone not null,
	 lang    	 	 		text not null,
	 organization 	    	text not null,
	 original_extension  	text not null,
	 page_count 	    	int  not null,
	 slug 	            	text not null,
	 title 	            	text not null,
	 updated_at 	    	timestamp with time zone not null,
	 userinfo 	        	text not null
);

-- dropped columns
--	  access: private, public on DC; ignore as all will be public by go live
-- 	  asset_url: two values functionally dependent on access
--    data: contains tags, possibly revisit later
--    description: empty column  
--    edit_access: boolean; not valuable for metadata, ask Muckrock why FALSE for many docs
--	  file_hash: not relevant,
--	  noindex: always false, not relevant
--	  page_spec: possibly revisit
--    projects: revisit, talk to Matt..multiples see relevance
--    publish_at: always null
--    published_url: always null
--    related_article: always null
--    revision_control: always false
--    source: always blank
--    status: always 'success'

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