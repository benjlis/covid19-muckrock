create table covid19_muckrock.entities (
    entity_id   integer primary key generated always as identity,
    wikidata_id text    not null unique
        references covid19_muckrock.wikidata_items,
    entity      text    not null,
    enttype     text    not null,
    created     timestamp with time zone not null default now(),
    updated     timestamp with time zone not null default now()
    );

create table covid19_muckrock.entity_pages (
    ei_id      integer primary key generated always as identity,
    entity_id  integer references entities not null,
    page_id    integer references pages not null,
    etext      text not null,
    etype      text not null,
    estart     integer not null,
    eend       integer not null,
    created    timestamp with time zone not null default now(),
    updated    timestamp with time zone not null default now()
    );
-- add indices on upon completing load:
-- create index on entity_pages(entity_id);
-- create index on entity_pages(page_id);
