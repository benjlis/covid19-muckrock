\copy (select * from covid19_muckrock.dq_sparse_docs) to '../tmp/dq-sparse-docs.csv' header csv
\copy (select * from covid19_muckrock.dq_sparse_docpages) to '../tmp/dq-sparse-docpages.csv' header csv
\copy (select * from covid19_muckrock.dq_pages_duplicates) to '../tmp/dq-pages-duplicates.csv' header csv
\copy (select * from covid19_muckrock.dq_docs_duplicates) to '../tmp/dq-docs-duplicates.csv' header csv
