# import time
import os
import requests

# get access and refresh tokens
DC_USER = os.getenv('MR_USER')
DC_PSWD = os.getenv('MR_PSWD')
access_endpoint = "https://accounts.muckrock.com/api/token/"
params = {'username': DC_USER, 'password': DC_PSWD}
response = requests.post(access_endpoint, data = params )
refresh_token = response.json()["refresh"]
access_token = response.json()["access"]

if __name__ == '__main__':
    print (f'{access_token=} \n{refresh_token=}')