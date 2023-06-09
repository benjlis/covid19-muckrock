import time
import os
import requests
import pandas as pd

# get access and refresh tokens
DC_USER = os.getenv('MR_USER')
DC_PSWD = os.getenv('MR_PSWD')
access_endpoint = "https://accounts.muckrock.com/api/token/"
params = {'username': DC_USER, 'password': DC_PSWD}
response = requests.post(access_endpoint, data = params )
refresh_token = response.json()["refresh"]
access_token = response.json()["access"]

# download metadata
DC_API = "https://api.www.documentcloud.org/api"
# download list of documents belonging to the project
DC_C19_project_id = "213211"
search_endpoint = f"{DC_API}/projects/{DC_C19_project_id}/documents/" 
headers = {'Authorization': f'Bearer {access_token}'}
docid_list = [] 
while search_endpoint:
    response = requests.get(search_endpoint, headers=headers)
    results = response.json()["results"]
    for r in results:
        docid_list.append(r["document"])
    search_endpoint = response.json()["next"]
print(len(docid_list))
# retrieve details for each document
EXPANSION = "?expand=user,organization,projects, sections, notes"
doc_list = []
i = 1
for d in docid_list:
    search_endpoint = f"{DC_API}/documents/{d}/{EXPANSION}"
    response = requests.get(search_endpoint, headers=headers)
    results = response.json()
    doc_list.append(results)
    print(f'{i}: {results}')
    i += 1
    time.sleep(.2)
# TODO: On 6/8 load there were two metadata records with newlines 
# embedded in a field. This breaks data load downstream. Manually 
# removed, but do so programatically going forward.
df = pd.DataFrame(doc_list)
print(df.head())
df.to_csv('tmp/muckrock-covid19.csv', index=False, header=True)
