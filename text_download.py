import psycopg2
import aiosql

# db-related configuration
conn = psycopg2.connect("")
conn.autocommit = True
stmts = aiosql.from_path("sql/download.sql", "psycopg2")

docs = stmts.get_doc_download_list(conn)
for d in docs:
    print(d)