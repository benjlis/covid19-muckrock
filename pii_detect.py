import datetime
import psycopg2
import aiosql
import crim

# db-related configuration
conn = psycopg2.connect("")
stmts = aiosql.from_path("sql/py.sql", "psycopg2")


def store_pii(doc_id, pg, pii_type, pii_list, body):
    start_pos = 0
    for p in pii_list:
        start_idx = body.find(p, start_pos)
        end_idx = start_idx + len(p)
        start_pos = end_idx
        # print(f'{pii_type}, {p}, {start_idx}, {end_idx}')
        stmts.add_pii(conn, id=doc_id, pg=pg, pii_type=pii_type,
                      pii_text=p, start_idx=start_idx, end_idx=end_idx) 


def detect_store_pii(doc_id, pg, body):
    store_pii(doc_id, pg, 'email_address', crim.emails(body), body)
    store_pii(doc_id, pg, 'phone_number', crim.phones(body), body)
    store_pii(doc_id, pg, 'ssn', crim.ssn_numbers(body), body)
    store_pii(doc_id, pg, 'ban', crim.iban_numbers(body), body)
    store_pii(doc_id, pg, 'credit_card', crim.credit_cards(body), body)
    store_pii(doc_id, pg, 'street_address', crim.street_addresses(body), body)
    store_pii(doc_id, pg, 'zipcode', crim.zip_codes(body), body)

pgs = stmts.get_page_list(conn)
for p in pgs:
    now = datetime.datetime.now().strftime('%m-%d %H:%M:%S')
    cnt, doc_id, pg, body =  p
    print(f'{cnt}, {now}, {doc_id}, {pg}')
    detect_store_pii(doc_id, pg, body)   
    conn.commit()      # for performance only commit after every doc