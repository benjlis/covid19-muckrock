create table covid19_muckrock.pages (
    page_id         integer generated always as identity primary key,
    dc_id           integer     not null
                    references  covid19_muckrock.metadata,
    pg              integer     not null,
    word_cnt        integer     not null,
    char_cnt        integer     not null,
    downloaded      timestamp with time zone not null default now(),
    body            text        not null,
    body_md5        text        not null generated always as (md5(body)) stored,
    unique (dc_id, pg)
    );