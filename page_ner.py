import spacy
import psycopg2
import aiosql
import sys

# spaCy related configuraton
nlp = spacy.load("en_core_web_lg")
EXCLUDED_ENTITY_TYPES=['DATE', 'TIME', 'CARDINAL', 'ORDINAL', 'QUANTITY']

# db-related configuration
conn = psycopg2.connect("")
conn.set_session(autocommit=True)
stmts = aiosql.from_path("sql/py.sql", "psycopg2")

def ner(text):
    doc = nlp(text)
    return doc.ents

def save_ner(conn, stmts, page_id, entity):
    # find if entity exists
    entity_id = stmts.get_entity_id_by_name(conn, name=entity.text)
    if not entity_id:
        entity_id =  stmts.add_entity(conn, entity=entity.text, 
                                            enttype=entity.label_)
        # print(f'creating new entity: {entity.text}, {entity.label_}')
    stmts.add_entity_page(conn, entity_id=entity_id, page_id=page_id, 
                                 etext=entity.text, 
                                 etype=entity.label_, 
                                 estart=entity.start_char, 
                                 eend=entity.end_char)
    # print(f'adding entity_page: {entity_id}, {page_id}')
    # print(f'   {entity.text}, {entity.label_}, {entity.start_char}, {entity.end_char}')

    
def page_ner(conn, stmts, page_id):
    text = stmts.get_page_body(conn, page_id=page_id)
    # print(text)
    entities = ner(text)
    for ent in entities:
        if ent.label_ not in EXCLUDED_ENTITY_TYPES:
            # print (ent.text, ent.label_, ent.start_char, ent.end_char)
            save_ner(conn, stmts, page_id, ent)


# test_pages - I was using 162481, 116656

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <entity_id>")
        sys.exit(1)
    # db-related configuration
    conn = psycopg2.connect("")
    conn.set_session(autocommit=True)
    stmts = aiosql.from_path("sql/py.sql", "psycopg2")
    page_id = sys.argv[1]
    page_ner(conn, stmts, page_id)
