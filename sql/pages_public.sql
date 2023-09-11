create table covid19_muckrock.pages_public (
    page_id         integer primary key 
                        references covid19_muckrock.pages,
    body            text not null,
    full_text       tsvector not null
    );
-- update covid19_muckrock.pages_public
--    set full_text = to_tsvector('english'::regconfig, body::text);
create index on covid19_muckrock.pages_public using gin (full_text);