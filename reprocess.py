import aiosql
import psycopg2
import boto3
import argparse
from   pdf_s3download import get_pdf
from   ocrmypdf import ocr
from   page_ner import page_ner
from   pii_detect import detect_store_pii
import pdftotext

PDF_DOWNLOAD_DIR="tmp/"

# db-related configuration
conn = psycopg2.connect("")
conn.set_session(autocommit=True)
stmts = aiosql.from_path("sql/py.sql", "psycopg2")


def store_reprocessed_page(page_id, text):
    text = text.replace('\x00', '') 
    word_cnt = len(text.split())
    char_cnt = len(text)
    lines= text.split(chr(10))
    #line_cnt = len(lines)
    max_line_length = len(max(lines, key=len))
    stmts.store_reprocessed_page(conn, page_id=page_id,
                                       body=text, 
                                       char_cnt=char_cnt,
                                       word_cnt=word_cnt,
                                       max_line_length=max_line_length) 
    

def reprocess_ner(page_id, text):
    stmts.delete_entity_page(conn, page_id=page_id)
    page_ner(page_id)


def reprocess_pii_detect(doc_id, pg, text):
    stmts.delete_pii(conn, doc_id=doc_id, pg=pg)
    detect_store_pii(conn, stmts, doc_id, pg, text)
    stmts.add_pii_npp_page(conn, stmts, doc_id=doc_id, pg=pg)


def reprocess_page_exception(page_id, text):
    pass


for cnt, doc_id, title, url in stmts.get_doc_exception_list(conn):
    print(f'** DOCUMENT: {cnt}. {title} ({doc_id}): {url}')
    pdf_filename = get_pdf(doc_id)
    for cnt, pg, page_id, exception, body in \
        stmts.get_docpage_exception_list(conn, doc_id=doc_id):
        print(f'**** PAGE: {cnt}. pg:{pg}  exception_type: {exception}')
        print(f'Text Before Reprocessing: \n{body}\n')
        print(f'OCRing Page:')
        # ocrmypdf --force-ocr --pages 261 --clean  --deskew --output-type pdf  sitka.pdf ocr.pdf
        ocr(input_file=pdf_filename, output_file=pdf_filename,
            pages=str(pg), force_ocr=True, clean=True, output_type='pdf')
        with open(pdf_filename, "rb") as f:
            pdf = pdftotext.PDF(f, physical=True)
        print(f'Text After Reprocessing: \n{pdf[pg-1]}\n')
        store_reprocessed_page(page_id, pdf[pg-1])
        reprocess_ner(page_id, pdf[pg-1])
        reprocess_pii_detect(doc_id, pg, pdf[pg-1])
        reprocess_page_exception(page_id, pdf[pg-1])

    
