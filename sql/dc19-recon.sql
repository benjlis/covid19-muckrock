select count(*) from covid19.covid19_files;
select count(*) from covid19.covid19_files 
   where source_url like '%documentcloud%';
select count(*) from covid19.covid19_files 
   where source_url like '%digitalocean%';
select count(*) from covid19_muckrock.metadata m, covid19.covid19_files c
   where  c.source_url like '%' || m.dc_id::text || '%';   