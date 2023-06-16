import datetime
import psycopg2
import aiosql
import dcapi

# db-related configuration
conn = psycopg2.connect("")
conn.autocommit = True
stmts = aiosql.from_path("sql/download.sql", "psycopg2")

docs = stmts.get_doc_download_list(conn)
for d in docs:
    now = datetime.datetime.now().strftime('%m-%d %H:%M:%S')
    cnt, doc_id, pg_cnt, print_prefix =  d
    print(f'{cnt}, {now}, {doc_id}, {pg_cnt}')
    for p in range(pg_cnt):
        try:
            pg_text = dcapi.download_page_text(f'{print_prefix}{p+1}.txt')
            # prevent string literal cannot contain NUL (0x00) characters issue
            pg_text = pg_text.replace('\x00', '') 
            word_cnt = len(pg_text.split())
            char_cnt = len(pg_text)
            stmts.add_page(conn, id=doc_id, pg=p+1, word_cnt=word_cnt,
                           char_cnt=char_cnt, body=pg_text)            
        except Exception as e:
            print(e)
