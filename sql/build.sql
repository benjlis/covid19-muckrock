create schema if not exists covid19_muckrock;
\i metadata-stage-ddl.sql
\i metadata-stage-load.sql
\i metadata-ddl.sql
\i metadata-load.sql
\i pages-ddl.sql
-- grants
grant usage on schema covid19_muckrock to c19ro;
grant select on all tables in schema covid19_muckrock to c19ro;
