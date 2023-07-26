import aiosql
import psycopg2
import boto3
import argparse

PDF_DOWNLOAD_DIR="tmp/"
S3_BUCKET="foiarchive-db-backups"
S3_OBJECT_PREFIX="covid19-muckrock-pdfs/"
# db-related configuration
conn = psycopg2.connect("")
stmts = aiosql.from_path("sql/py.sql", "psycopg2")


def download_s3(bucket, object_name, file_name):
    """Download a file from an S3 bucket

    :param file_name: Downloaded filename
    :param bucket: Bucket to download from
    :param object_name: S3 object name
    :return: True if file was uploaded, else False
    """
    # Upload the file
    s3_client = boto3.client('s3')
    try:
        s3_client.download_file(bucket, object_name, file_name)
    except Exception as e:
        print(e)
        return False
    return True


def get_pdf(id):
    filename = stmts.get_doc_pdf_filename(conn, doc_id=id)
    if filename:
        download_s3(S3_BUCKET,  
                    f'{S3_OBJECT_PREFIX}{filename}',
                    f'{PDF_DOWNLOAD_DIR}{filename}')
        return f'{PDF_DOWNLOAD_DIR}{filename}'
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Downloads PDF from S3 and stores in tmp')
    parser.add_argument('doc_id', type=int, help='ID associated with PDF')
    args = parser.parse_args()
    downloaded_pdf = get_pdf(args.doc_id)
    if downloaded_pdf:
        print(f'Downloaded {downloaded_pdf}')
    else:
        print('PDF file not found')