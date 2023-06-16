create table covid19_muckrock.pages (
    dc_id           integer     not null
                    references  covid19_muckrock.metadata,
    pg              integer     not null,
    word_cnt        integer     not null,
    char_cnt        integer     not null,
    downloaded      timestamp with time zone not null default now(),
    body            text,
    primary key (dc_id, pg)
    );