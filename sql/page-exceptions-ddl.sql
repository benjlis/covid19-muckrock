drop table if exists covid19_muckrock.page_exceptions;
create table covid19_muckrock.page_exceptions (
    page_id         integer primary key 
        references covid19_muckrock.pages,
    exception_type  text not null 
        check (exception_type in ('langdetect', 'spellcheck')),
    created         timestamp with time zone not null default now(), 
    comments        text
    );
\copy covid19_muckrock.page_exceptions(page_id, exception_type, comments) from 'tmp/page-exceptions-langdetect.csv' csv