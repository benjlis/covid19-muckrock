import psycopg2
import aiosql
import langdetect
import csv


# langdetect configs
langdetect.DetectorFactory.seed = 0    # ensure consistent results
# db-related configuration
conn = psycopg2.connect("")
stmts = aiosql.from_path("sql/py.sql", "psycopg2")
 

pgs = stmts.get_page_list(conn)
with open('tmp/page-exceptions-langdetect.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    for p in pgs:
        cnt, doc_id, pg, body, page_id =  p
        try:
            lang = langdetect.detect_langs(body)
            if lang[0].__dict__['lang'] != 'en' or \
               lang[0].__dict__['prob'] <= .98: 
                print(f'{cnt}, {doc_id}, {pg}, {page_id}: {lang}')
                writer.writerow([page_id, 'langdetect', lang])
        except Exception as e:
            print(f'{cnt}, {doc_id}, {pg}, {page_id}: {e}')
            writer.writerow([page_id, 'langdetect', e])
