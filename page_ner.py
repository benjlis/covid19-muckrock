import spacy


text ="""
I think the New York Jets win the AFC East in 2023, as Aaron Rodgers is a difference maker 
"""

nlp = spacy.load("en_core_web_lg")
doc = nlp(text)
for ent in doc.ents:
    print (ent.text, ent.label_, ent.start_char, ent.end_char)