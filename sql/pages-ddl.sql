create table covid19_muckrock.pages (
    page_id         integer generated always as identity primary key,
    dc_id           integer     not null
                    references  covid19_muckrock.metadata,
    pg              integer     not null,
    word_cnt        integer     not null,
    char_cnt        integer     not null,
    downloaded      timestamp with time zone not null default now(),
    reprocessed     timestamp with time zone,
    body            text        not null,
    body_md5        text        not null 
        generated always as (md5(body)) stored,
    line_cnt        integer     not null 
        generated always as 
            coalesce(array_length(string_to_array(body, chr(10)), 1), 0) stored,
    max_line_length integer     not null,       
    unique (dc_id, pg)
    );