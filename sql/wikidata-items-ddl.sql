create table covid19_muckrock.wikidata_items_stage (
    WikidataID          text,
    itemLabel           text,
    instanceofa         text,
    instancesofa        text);
\copy covid19_muckrock.wikidata_items_stage from "../data/std_name.csv" header csv

create table covid19_muckrock.wikidata_items (
    wikidata_id         text  primary key,
    item_label          text  not null,
    instance_of         text
);
grant select on covid19_muckrock.wikidata_items to c19ro;
insert into wikidata_items
select wikidataid, itemlabel, instancesofa 
from covid19_muckrock.wikidata_items_stage;