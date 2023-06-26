\copy (select * from covid19_muckrock.pii_summary) to '../tmp/pii-summmary.csv' header csv
\copy (select * from covid19_muckrock.pii_docs_ext) to '../tmp/pii-docs-ext.csv' header csv
\copy (select * from covid19_muckrock.pii_top_emails) to '../tmp/pii-top-emails.csv' header csv
\copy (select * from covid19_muckrock.pii_top_phones) to '../tmp/pii-top-phones.csv' header csv
\copy (select * from covid19_muckrock.pii_top_zips) to '../tmp/pii-top-zips.csv' header csv
\copy (select * from covid19_muckrock.pii_top_addresses) to '../tmp/pii-addresses.csv' header csv
-- \copy (select * from covid19_muckrock.pii_details where pii_type = 'ssn') to '../tmp/pii-ssn.csv' header csv