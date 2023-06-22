create table if not exists covid19_muckrock.pii 
    (pii_id      int generated always as identity primary key,
     dc_id       int not null,
     pg          int not null,
     pii_type    text not null references covid19_muckrock.pii_types,
     pii_text    text not null,
     start_idx   int not null,
     end_idx     int not null, 
     foreign key (dc_id, pg) references covid19_muckrock.pages);