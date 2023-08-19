import aiosql
import psycopg2
import os
import dcapi
import boto3
import fitz


def convert_none(value):
    """Converts '' to None"""
    return value if value != '' else None 


def upload_s3(file_name, bucket, object_name=None):
    """Upload a file to an S3 bucket

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """
    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = os.path.basename(file_name)
    # Upload the file
    s3_client = boto3.client('s3')
    try:
        s3_client.upload_file(file_name, bucket, object_name)
    except Exception as e:
        print(e)
        return False
    return True


def upload_pdf_list(conn, stmts):
    S3_BUCKET="foiarchive-db-backups"
    S3_OBJECT_PREFIX="covid19-muckrock-pdfs/"
    #
    pgs = stmts.get_doc_pdf_list(conn)
    for p in pgs:    
        cnt, doc_id, pdf_url = p
        pdf_file = pdf_url.rsplit('/')[-1]
        dcapi.download_pdf(pdf_url, pdf_file)
        pdf_size = os.stat(pdf_file).st_size
        print(f'{cnt}. {doc_id}: {pdf_file}, {pdf_size}')
        with fitz.open(pdf_file) as d:
            metadata = d.metadata
            xml_metadata  = d.get_xml_metadata()
            pg_cnt = d.page_count
        print(metadata)
        s3_uploaded = upload_s3(pdf_file, S3_BUCKET, S3_OBJECT_PREFIX + pdf_file)
        if s3_uploaded:
            stmts.add_pdf(conn, id=doc_id, size=pdf_size, 
                          filename=pdf_file, pg_cnt=pg_cnt, 
                          version=metadata['format'],
                          title=convert_none(metadata['title']), 
                          author=convert_none(metadata['author']),
                          subject=convert_none(metadata['subject']),
                          keywords=convert_none(metadata['keywords']),
                          creator=convert_none(metadata['creator']), 
                          producer=convert_none(metadata['producer']),
                          created=convert_none(metadata['creationDate']\
                                               [2:19].replace('Z','-00')),
                          modified=convert_none(metadata['modDate']\
                                                [2:19].replace('Z','-00')),
                          trapped=convert_none(metadata['trapped']),
                          encryption=convert_none(metadata['encryption']),
                          xml_metadata=convert_none(xml_metadata),
                          s3_uploaded=s3_uploaded)
            conn.commit()        
        else:
            print ('error uploading to s3')
        os.remove(pdf_file)


if __name__ == "__main__":
    # conn = psycopg2.connect("")
    # stmts = aiosql.from_path("sql/py.sql", "psycopg2")
    # upload_pdf_list(conn, stmts)
    status=upload_s3('tmp/test.pdf', 
                     'foiarchive-db-backups', 
                      'covid19-muckrock-pdfs-enhanced/test.pdf')
    if status:
        print('success')
    else:
        print('failure')