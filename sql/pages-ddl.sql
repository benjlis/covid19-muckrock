create table covid19_muckrock.pages (
    dc_id           integer     not null
                    references  covid19_muckrock.metadata,
    pg              integer     not null,
    word_cnt        integer     not null,
    char_cnt        integer     not null,
    body            text,
    primary key (dc_id, pg)
    );