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
