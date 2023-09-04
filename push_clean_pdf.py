import aiosql
import psycopg2
from   pdf_s3download import get_pdf
from   pdf2s3 import upload_s3
import datetime
import os
from pathlib import Path



def main():
    start_time=datetime.datetime.now()
    S3_BUCKET='foiarchive-db-backups'
    S3_FOLDER='covid19-muckrock-pdfs-enhanced/'
    # db-related configuration
    conn = psycopg2.connect("")
    conn.set_session(autocommit=True)
    stmts = aiosql.from_path("sql/py.sql", "psycopg2")

    for cnt, doc_id, title, url in stmts.get_doc_noexception_list(conn):
        pdf_filename = get_pdf(doc_id)
        print(f'** DOCUMENT: {cnt}. {title} ({doc_id}): {url}')
        print(f'{datetime.datetime.now()}')
        s3_filename = Path(pdf_filename).name
        upload_s3(pdf_filename, S3_BUCKET, S3_FOLDER + s3_filename)
        os.remove(pdf_filename)
    end_time=datetime.datetime.now()
    print(f'start: {start_time}')
    print(f'  end: {end_time}')

if __name__ == "__main__":
    main()   
