
create table covid19_muckrock.page_exceptions (
    page_id         integer primary key 
        references covid19_muckrock.pages,
    exception_type  text not null 
        check (exception_type in ('langdetect', 'spellcheck')),
    comments        text
    );