import time
import os
import requests

# automatically throttle your requests to 10 per second to avoid going over the rate limit
DC_THROTTLE_INTERVAL = .1

# get access and refresh tokens
DC_USER = os.getenv('MR_USER')
DC_PSWD = os.getenv('MR_PSWD')
access_endpoint = "https://accounts.muckrock.com/api/token/"
params = {'username': DC_USER, 'password': DC_PSWD}
response = requests.post(access_endpoint, data=params)
refresh_token = response.json()["refresh"]
access_token = response.json()["access"]
headers = {'Authorization': f'Bearer {access_token}'}


def renew_api_token():
    time.sleep(DC_THROTTLE_INTERVAL)
    renew_endpoint = "https://accounts.muckrock.com/api/refresh/"
    params = {'refresh': refresh_token}
    r = requests.post(renew_endpoint, data=params)
    global access_token, headers
    access_token = r.json()["access"]
    headers = {'Authorization': f'Bearer {access_token}'}


def download_page_text(page_text_endpoint):
    time.sleep(DC_THROTTLE_INTERVAL)
    r = requests.get(page_text_endpoint, headers=headers)
    if (r.status_code == 403 or r.status_code == 429):
       print(f'renewing token: {r.status_code} on {page_text_endpoint}')       
       renew_api_token()
       r = requests.get(page_text_endpoint, headers=headers)
    r.raise_for_status()
    return r.text

def download_pdf(url, dfile):
    r = requests.get(url, headers=headers)
    r.raise_for_status()
    with open(dfile, 'wb') as f:
        f.write(r.content)
    return r.status_code

if __name__ == '__main__':
    # print (f'{access_token=} \n{refresh_token=}')
    # download_page_text('https://s3.documentcloud.org/documents/20488670/pages/sitka-p2.txt')
    # download_pdf('https://api.www.documentcloud.org/files/documents/23823940/hhs-march-2022-production.pdf',
    #             'tmp/test.pdf')
    download_pdf('https://s3.documentcloud.org/documents/6808332/MDHHS-Interim-Recommendations-for-COVID-19-Final.pdf',
                 'prob.pdf')
    # download_pdf('https://api.www.documentcloud.org/files/documents/6808332/MDHHS-Interim-Recommendations-for-COVID-19-Final.pdf',
    #               'prob.pdf')

