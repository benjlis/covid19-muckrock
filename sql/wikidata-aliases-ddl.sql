create table covid19_muckrock.wikidata_aliases_stage (
    WikidataID          text,
    itemLabel           text,
    sitelinks           text);
\copy covid19_muckrock.wikidata_aliases_stage from 'data/aliases.csv' header csv

create table covid19_muckrock.wikidata_aliases (
    wikidata_alias_id   integer generated always as identity,
    wikidata_id         text  not null references covid19_muckrock.wikidata_items,
    item_label          text  not null
);
grant select on covid19_muckrock.wikidata_aliases to c19ro;
insert into covid19_muckrock.wikidata_aliases(wikidata_id, item_label)
select wikidataid, itemlabel 
from covid19_muckrock.wikidata_aliases_stage
where itemlabel is not null and wikidataid not in ('No Wiki', 'HL100001');