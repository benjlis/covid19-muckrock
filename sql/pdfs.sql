drop table if exists covid19_muckrock.pdfs;
create table covid19_muckrock.pdfs(
    dc_id           int	 primary key 
        references covid19_muckrock.metadata,
    downloaded      timestamp with time zone not null default now(),
    size            integer     not null,
    filename        text        not null,
    pg_cnt          integer     not null,    
    version         text        not null,
    title           text,
    author          text,
    subject         text,
    keywords        text,
    creator         text,
    producer        text,
    created         timestamp with time zone,
    modified        timestamp with time zone,
    trapped         text,
    encryption      text,
    xml_metadata    text,
    s3_uploaded     boolean      not null
    );