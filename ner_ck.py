import sys
import psycopg2
import aiosql
import page_ner

if len(sys.argv) != 3:
    print("Usage: python ner_ck.py <doc_id> <pg>")
    sys.exit(1)
else:
    doc_id = int(sys.argv[1])
    pg = int(sys.argv[2])
# db-related configuration
conn = psycopg2.connect("")
stmts = aiosql.from_path("sql/py.sql", "psycopg2")

body = stmts.get_doc_pg_body(conn, doc_id=doc_id, pg=pg)
ents = page_ner.ner(body)
print(f'NER for {doc_id}_{pg}:')
print('entity, entity_type, start, end')
for e in ents:
    if e.label_ not in page_ner.EXCLUDED_ENTITY_TYPES:
        print(f'{e.text}, {e.label_}, {e.start_char}, {e.end_char}')
print(f'\nBODY of {doc_id}_{pg}:')
print(body)