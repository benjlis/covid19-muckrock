import datetime
import psycopg2
import aiosql
import pgparse

# db-related configuration
conn = psycopg2.connect("")
conn.set_session(autocommit=True)
stmts = aiosql.from_path("sql/py.sql", "psycopg2")

pgs = stmts.get_page_list(conn)
for p in pgs:
    now = datetime.datetime.now().strftime('%m-%d %H:%M:%S')
    cnt, doc_id, pg, body, page_id =  p
    pg_parse = pgparse.parse(body)
    if isinstance(pg_parse, pgparse.Email):
        h = pg_parse.header
        print(f'{cnt}, {now}, {doc_id}, {pg}')
        stmts.add_email(conn, page_id=page_id, 
                        header_begin_ln=h.begin_ln,
                        header_end_ln=h.end_ln, 
                        subject=h.subject,
                        sent=h.date, 
                        from_email=h.from_email, 
                        to_emails=h.to, 
                        cc_emails=h.cc,
                        bcc_emails=h.bcc, 
                        attachments=h.attachments, 
                        importance=h.importance, 
                        header_unprocessed= h.unprocessed)
