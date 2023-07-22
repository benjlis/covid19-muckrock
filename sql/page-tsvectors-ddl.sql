create table covid19_muckrock.page_tsvectors (
    page_id         integer primary key 
                        references covid19_muckrock.pages,
    full_text       tsvector not null
    );

insert into covid19_muckrock.page_tsvectors
    select page_id, to_tsvector('english'::regconfig, body::text)
        from covid19_muckrock.docpages
        where exception = 'N';

create index on covid19_muckrock.page_tsvectors using gin (full_text);