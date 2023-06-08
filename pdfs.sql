create table covid19_muckrock.pdfs (
    dc_id           integer     primary key
                    references  covid19_muckrock.metadata,
    pg_cnt          integer     not null,
    size            integer     not null
    );
comment on column covid19_muckrock.pdfs.size is 'Size of PDF in bytes';

create table covid19_muckrock.pdfpages (
    dc_id          integer     not null
                    references  covid19_muckrock.pdfs,
    pg              integer     not null,
    word_cnt        integer     not null,
    char_cnt        integer     not null,
    body            text,
    primary key (dc_id, pg)
    );